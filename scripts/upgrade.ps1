# upgrade.ps1 — 通用升级器（v1.0 及以后）
#
# 依据两份 index 比对（旧版 vs 新版），决定每个文件是 新增 / 覆盖 / 跳过 / 重写。
# 默认只做 dry-run；加 -Apply 才真正改文件，且改前先备份。
#
# 安全规则：
#   1. 仅在"用户当前文件 == 旧版发布内容"时才覆盖（归一化哈希比较，容忍行尾/行尾空格差异）
#   2. 用户改过的文件 → 进 rewrites 清单，不覆盖
#   3. 删除 → 只列清单，永不自动执行
#   4. 改前备份到 <Vault>/.selfstudyos/backup/<时间戳>/，可 -Rollback
#
# 用法：
#   powershell -File scripts/upgrade.ps1 -VaultRoot "D:\...\MyVault" -NewIndex migrations\index-1.1.0.json
#   ... -Apply
#   ... -Rollback

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$VaultRoot,
    [string]$NewIndex = '',
    [string]$PackageRoot = '',
    [string]$OldIndex = '',
    [switch]$Apply,
    [switch]$Rollback,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'migrate-core.psm1') -Force

$VaultRoot = (Resolve-Path -LiteralPath $VaultRoot).Path
$stateDir  = Join-Path $VaultRoot '.selfstudyos'
$stateIdx  = Join-Path $stateDir 'index.json'
$backupRoot = Join-Path $stateDir 'backup'

function Get-NormSha([string]$full) {
    if ($full -notmatch '\.(md|txt|json|ps1|yml|yaml)$') { return $null }
    try {
        $t = [IO.File]::ReadAllText($full, [Text.Encoding]::UTF8)
        $t = $t.TrimStart([char]0xFEFF).Replace("`r`n","`n").Replace("`r","`n")
        $norm = (($t.Split("`n") | ForEach-Object { $_.TrimEnd() }) -join "`n")
        $h = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($norm))
        return ([BitConverter]::ToString($h).Replace('-','').ToLower())
    } catch { return $null }
}

# ---------- 回滚 ----------
if ($Rollback) {
    if (-not (Test-Path -LiteralPath $backupRoot)) { throw "没有找到备份目录: $backupRoot" }
    $latest = Get-ChildItem -LiteralPath $backupRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if (-not $latest) { throw '备份目录为空，无可回滚' }
    $mf = Join-Path $latest.FullName '_manifest.json'
    if (-not (Test-Path -LiteralPath $mf)) { throw "备份缺少 _manifest.json: $($latest.FullName)" }
    $m = Get-Content -LiteralPath $mf -Raw -Encoding UTF8 | ConvertFrom-Json
    $restored = 0; $removed = 0
    foreach ($b in @($m.backedUp)) {
        $dest = Join-Path $VaultRoot ($b.path -replace '/','\')
        $src  = Join-Path $latest.FullName ($b.backupRel -replace '/','\')
        if (Test-Path -LiteralPath $src) {
            $d = Split-Path $dest -Parent
            if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
            Copy-Item -LiteralPath $src -Destination $dest -Force
            $restored++
        }
    }
    foreach ($a in @($m.added)) {
        $p = Join-Path $VaultRoot ($a -replace '/','\')
        if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force; $removed++ }
    }
    Write-Host ("回滚完成：恢复 {0} 个文件，删除 {1} 个新增文件。备份：{2}" -f $restored, $removed, $latest.FullName) -ForegroundColor Green
    exit 0
}

# ---------- 版本检测 ----------
if (-not (Test-Path -LiteralPath $stateIdx)) {
    Write-Host '这个 Vault 里没有 .selfstudyos/index.json。' -ForegroundColor Yellow
    Write-Host '→ 它属于 v1.0 之前的版本（v0.3 时代），请改用：' -ForegroundColor Yellow
    Write-Host '   scripts/migrate-v0.3-to-v1.0.ps1 -VaultRoot <该Vault> -TemplateRoot <新模板> -Out <输出目录>' -ForegroundColor Yellow
    exit 3
}
$oldIdx = Get-Content -LiteralPath $stateIdx -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $NewIndex) {
    $repo = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $NewIndex = Join-Path $repo 'migrations\index-1.0.0.json'
}
if (-not (Test-Path -LiteralPath $NewIndex)) { throw "找不到新版 index: $NewIndex" }
$newIdx = Get-Content -LiteralPath $NewIndex -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $PackageRoot) {
    $repo = Split-Path -Parent (Split-Path -Parent $NewIndex)
    if ((Split-Path $repo -Leaf) -eq 'migrations') { $repo = Split-Path $repo -Parent }
    $PackageRoot = Join-Path $repo 'vault-template'
    if (-not (Test-Path -LiteralPath $PackageRoot)) {
        $PackageRoot = Join-Path (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) 'vault-template'
    }
}
if (-not (Test-Path -LiteralPath $PackageRoot)) { throw "找不到新版模板目录: $PackageRoot" }

Write-Host ''
Write-Host '=== SelfStudyOS 升级检查 ===' -ForegroundColor Cyan
Write-Host ("当前版本 : {0}" -f $oldIdx.version)
Write-Host ("目标版本 : {0}" -f $newIdx.version)
if ($oldIdx.version -eq $newIdx.version -and -not $Force) {
    Write-Host '已经是最新版本，无需升级。（要强制比对可加 -Force）' -ForegroundColor Green
    exit 0
}

if (-not $OldIndex) {
    $repoM = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $OldIndex = Join-Path $repoM ("migrations\index-" + $oldIdx.version + ".json")
}
if (-not (Test-Path -LiteralPath $OldIndex)) { throw ("找不到旧版发布索引: " + $OldIndex) }
$baseIdx = Get-Content -LiteralPath $OldIndex -Raw -Encoding UTF8 | ConvertFrom-Json
$oldMap = @{}
foreach ($f in $baseIdx.files) { $oldMap[$f.path] = $f }

# ---------- 规划 ----------
$plan = New-Object System.Collections.ArrayList
foreach ($nf in $newIdx.files) {
    $rel  = $nf.path
    $dest = Join-Path $VaultRoot ($rel -replace '/','\')
    $userExists = Test-Path -LiteralPath $dest

    if ((-not $userExists) -and ($nf.class -eq 'example')) {
        [void]$plan.Add([pscustomobject]@{ Action = 'skip'; Path = $rel; Note = '样例文件, 升级不新增' })
        continue
    }
    if (-not $userExists) {
        [void]$plan.Add([pscustomobject]@{ Action='add'; Path=$rel; Note='用户没有这个文件' })
        continue
    }
    if (-not $oldMap.ContainsKey($rel)) {
        [void]$plan.Add([pscustomobject]@{ Action='conflict-extra'; Path=$rel; Note='用户的同名文件不在旧版清单里（可能是自己建的）' })
        continue
    }
    $old = $oldMap[$rel]
    if ($nf.sha256 -eq $old.sha256) {
        [void]$plan.Add([pscustomobject]@{ Action='skip'; Path=$rel; Note='模板未变' })
        continue
    }
    # 模板变了：判断用户是否改过
    $userSha = Get-FileSha256 $dest
    $userNorm = Get-NormSha $dest
    $untouched = ($userSha -eq $old.sha256) -or ($old.PSObject.Properties.Name -contains 'normSha256' -and $userNorm -and $userNorm -eq $old.normSha256)
    if ($untouched) {
        [void]$plan.Add([pscustomobject]@{ Action='overwrite'; Path=$rel; Note='用户未改，可安全覆盖' })
    } else {
        [void]$plan.Add([pscustomobject]@{ Action='rewrite'; Path=$rel; Note='用户改过 → 需按模板合并，不覆盖' })
    }
}
foreach ($op in $oldIdx.files) {
    if ($op.class -ne 'owned') { continue }
    if (-not ($newIdx.files | Where-Object { $_.path -eq $op.path })) {
        [void]$plan.Add([pscustomobject]@{ Action='orphan'; Path=$op.path; Note='新版已移除 → 需你确认是否删除' })
    }
}

# ---------- 汇报 ----------
$groups = $plan | Group-Object Action
foreach ($g in ($groups | Sort-Object Name)) {
    Write-Host ''
    Write-Host ("[{0}] {1} 个" -f $g.Name, $g.Count) -ForegroundColor DarkGray
    $g.Group | Select-Object -First 12 | ForEach-Object { Write-Host ("   {0}   {1}" -f $_.Path, $_.Note) }
    if ($g.Count -gt 12) { Write-Host ("   ...（还有 {0} 个）" -f ($g.Count - 12)) -ForegroundColor DarkGray }
}

$toWrite = @($plan | Where-Object { $_.Action -in 'add','overwrite' })
Write-Host ''
Write-Host ("将写入 {0} 个文件；跳过 {1}；需重写 {2}；待确认删除 {3}；冲突 {4}" -f `
    $toWrite.Count,
    (@($plan | Where-Object { $_.Action -eq 'skip' }).Count),
    (@($plan | Where-Object { $_.Action -eq 'rewrite' }).Count),
    (@($plan | Where-Object { $_.Action -eq 'orphan' }).Count),
    (@($plan | Where-Object { $_.Action -eq 'conflict-extra' }).Count))

if (-not $Apply) {
    Write-Host ''
    Write-Host '（dry-run：未修改任何文件。确认后加 -Apply 执行）' -ForegroundColor Yellow
    exit 0
}

# ---------- 执行 ----------
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$bkDir = Join-Path $backupRoot $stamp
New-Item -ItemType Directory -Path $bkDir -Force | Out-Null
$backedUp = New-Object System.Collections.ArrayList
$added    = New-Object System.Collections.ArrayList

foreach ($p in $toWrite) {
    $dest = Join-Path $VaultRoot ($p.Path -replace '/','\')
    if ($p.Action -eq 'overwrite') {
        $bkRel = 'files/' + $p.Path
        $bkFull = Join-Path $bkDir ($bkRel -replace '/','\')
        $d = Split-Path $bkFull -Parent
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
        Copy-Item -LiteralPath $dest -Destination $bkFull -Force
        [void]$backedUp.Add([ordered]@{ path = $p.Path; backupRel = $bkRel })
    }
    $src = Join-Path $PackageRoot ($p.Path -replace '/','\')
    if (-not (Test-Path -LiteralPath $src)) { Write-Host ("跳过（新版包里没有该文件）：{0}" -f $p.Path) -ForegroundColor Yellow; continue }
    $dd = Split-Path $dest -Parent
    if (-not (Test-Path -LiteralPath $dd)) { New-Item -ItemType Directory -Path $dd -Force | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dest -Force
    if ($p.Action -eq 'add') { [void]$added.Add($p.Path) }
    $chk = Get-FileSha256 $dest
    $exp = ($newIdx.files | Where-Object { $_.path -eq $p.Path }).sha256
    if ($chk -ne $exp) { Write-Host ("校验失败：{0}" -f $p.Path) -ForegroundColor Red }
}
[IO.File]::WriteAllText((Join-Path $bkDir '_manifest.json'),
    (([ordered]@{ timestamp = $stamp; from = $oldIdx.version; to = $newIdx.version; backedUp = @($backedUp); added = @($added) }) | ConvertTo-Json -Depth 6),
    (New-Object Text.UTF8Encoding($false)))

# 更新本地 index
if (-not (Test-Path -LiteralPath $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
Copy-Item -LiteralPath $NewIndex -Destination $stateIdx -Force

# 迁移留档
$migDir = Join-Path $VaultRoot '99_Meta'
if (-not (Test-Path -LiteralPath $migDir)) { New-Item -ItemType Directory -Path $migDir -Force | Out-Null }
$log = @(
    "# 升级记录 $stamp",
    '',
    ("- 从 {0} 升级到 {1}" -f $oldIdx.version, $newIdx.version),
    ("- 写入 {0} 个文件（其中新增 {1}）" -f $toWrite.Count, $added.Count),
    ("- 备份目录：.selfstudyos/backup/{0}/" -f $stamp),
    ("- 回滚命令：powershell -File scripts/upgrade.ps1 -VaultRoot `"{0}`" -Rollback" -f $VaultRoot),
    '',
    '## 需人工处理',
    '',
    '### 需要按模板重写的文件',
    ''
) + (@($plan | Where-Object { $_.Action -eq 'rewrite' } | ForEach-Object { "- $($_.Path)" })) + @(
    '',
    '### 新版已移除、待你确认删除的文件',
    ''
) + (@($plan | Where-Object { $_.Action -eq 'orphan' } | ForEach-Object { "- $($_.Path)" })) + @(
    '',
    '### 冲突（同名但不在旧版清单里）',
    ''
) + (@($plan | Where-Object { $_.Action -eq 'conflict-extra' } | ForEach-Object { "- $($_.Path)" }))
[IO.File]::WriteAllText((Join-Path $migDir ("migration_{0}.md" -f $stamp)), ($log -join "`r`n"), (New-Object Text.UTF8Encoding($false)))

Write-Host ''
Write-Host ("升级完成：写入 {0} 个文件，备份在 .selfstudyos/backup/{1}/" -f $toWrite.Count, $stamp) -ForegroundColor Green
Write-Host ("需人工处理 {0} 项，详见 99_Meta/migration_{1}.md" -f ((@($plan | Where-Object { $_.Action -in 'rewrite','orphan','conflict-extra' })).Count), $stamp) -ForegroundColor Yellow