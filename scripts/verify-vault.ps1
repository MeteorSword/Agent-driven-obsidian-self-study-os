# verify-vault.ps1 — Vault 结构自检（只读）
#
# A 必需文件 / B 旧路径残留 / C CourseOS 二进制 / D 模板覆盖 / E 路径变量 / F 断链 / G 索引覆盖面
# 不修改任何文件。退出码：有 ERROR 为 1，否则 0。
#
# 用法：powershell -File scripts/verify-vault.ps1 -VaultRoot "D:\...\MyVault"

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$VaultRoot,
    [string]$RepoIndex = ''
)

$ErrorActionPreference = 'Stop'
$v = (Resolve-Path -LiteralPath $VaultRoot).Path
$repo = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $RepoIndex) { $RepoIndex = Join-Path $repo 'migrations\index-1.0.0.json' }

$err = New-Object System.Collections.ArrayList
$warn = New-Object System.Collections.ArrayList
$ok  = New-Object System.Collections.ArrayList

function Add-E($m) { [void]$err.Add($m) }
function Add-W($m) { [void]$warn.Add($m) }
function Add-O($m) { [void]$ok.Add($m) }

$allMd = @(Get-ChildItem -LiteralPath $v -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -notmatch '\\\.git\\' })
$allFiles = @(Get-ChildItem -LiteralPath $v -Recurse -File -ErrorAction SilentlyContinue |
              Where-Object { $_.FullName -notmatch '\\\.git\\' })

# ---------- A 必需文件 ----------
foreach ($r in @('01_LearningDesk/06_给Agent的启动句.md','70_AgentSystems/SelfStudyOS/System/operating_rules.md',
                 '70_AgentSystems/SelfStudyOS/AGENTS.md','AGENTS.md','05_Templates/learning_close_5lines.md',
                 '99_Meta/SelfStudyOS_Version.md','.selfstudyos/index.json')) {
    if (Test-Path -LiteralPath (Join-Path $v ($r -replace '/','\'))) { Add-O "必需文件存在：$r" } else { Add-E "必需文件缺失：$r" }
}

# ---------- B 旧路径残留 ----------
$legacy = [ordered]@{
    '70_AgentSystems/SelfStudyOS/Raw/courses' = '旧课程资料位置 Raw/courses'
    'CourseOS'                                = 'Vault 根的游离 CourseOS'
    '99_Meta/Templates'                       = '旧模板位置 99_Meta/Templates'
    '70_AgentSystems/SelfStudyOS/Templates'   = '旧模板位置 SelfStudyOS/Templates'
}
foreach ($k in $legacy.Keys) {
    if (Test-Path -LiteralPath (Join-Path $v ($k -replace '/','\'))) { Add-E ("{0} 仍存在" -f $legacy[$k]) } else { Add-O ("{0} 已清理" -f $legacy[$k]) }
}
if (@(Get-ChildItem -LiteralPath $v -Recurse -File -Filter 'START_HERE*' -ErrorAction SilentlyContinue).Count -gt 0) { Add-E 'START_HERE 类文件仍存在' } else { Add-O 'START_HERE 类文件已清理' }
if (@(Get-ChildItem -LiteralPath (Join-Path $v 'prompts') -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^0[1-9]_' }).Count -gt 0) { Add-E 'prompts/ 下仍有旧 prompt' } else { Add-O '旧 prompt 已清理' }
$oldQ = @($allFiles | Where-Object { $_.Name -eq 'material_queue.md' -and $_.FullName -match '\\raw\\' })
if ($oldQ.Count -gt 0) { Add-E ("raw/ 下仍有 material_queue.md {0} 个" -f $oldQ.Count) } else { Add-O 'material_queue.md 位置正确' }

# ---------- C CourseOS 不应有二进制原件 ----------
$courseRoot = Join-Path $v '70_AgentSystems\SelfStudyOS\CourseOS'
if (Test-Path -LiteralPath $courseRoot) {
    $bin = @(Get-ChildItem -LiteralPath $courseRoot -Recurse -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Extension -match '^\.(pdf|ppt|pptx|doc|docx|xls|xlsx|zip|rar|7z|typ|png|jpg|jpeg)$' })
    if ($bin.Count -gt 0) {
        Add-E ("CourseOS 下有 {0} 个非 md 原件（应在 10_Courses/）" -f $bin.Count)
        $bin | Select-Object -First 3 | ForEach-Object { Add-E ("   " + $_.FullName.Substring($v.Length + 1)) }
    } else { Add-O 'CourseOS 下无非 md 原件' }
}

# ---------- D 05_Templates 覆盖率（对照仓库索引）----------
if (Test-Path -LiteralPath $RepoIndex) {
    $ri = Get-Content -LiteralPath $RepoIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    $tplWant = @($ri.files | Where-Object { $_.path -like '05_Templates/*' } | ForEach-Object { $_.path })
    $tplMiss = @($tplWant | Where-Object { -not (Test-Path -LiteralPath (Join-Path $v ($_ -replace '/','\'))) })
    if ($tplMiss.Count -gt 0) { Add-E ("05_Templates 缺 {0} 个模板：{1}" -f $tplMiss.Count, ($tplMiss -join ', ')) }
    else { Add-O ("05_Templates 覆盖完整（{0} 个）" -f $tplWant.Count) }
} else { Add-W "找不到仓库索引，跳过模板覆盖检查：$RepoIndex" }

# ---------- E 路径变量解析 ----------
$rules = Join-Path $v '70_AgentSystems\SelfStudyOS\System\operating_rules.md'
if (Test-Path -LiteralPath $rules) {
    $lines = Get-Content -LiteralPath $rules -Encoding UTF8
    $inT = $false; $checked = 0; $bad = 0
    foreach ($line in $lines) {
        if ($line -match '^##\s*路径变量表') { $inT = $true; continue }
        if ($inT -and $line -match '^##\s+') { break }
        if (-not $inT) { continue }
        if ($line -notmatch '^\|\s*\$\{([A-Z_]+)\}\s*\|\s*(.+?)\s*\|\s*$') { continue }
        $name = $Matches[1]; $raw = $Matches[2]
        if ($raw -match '根路径|平台|不在 vault' -or $raw -match '（可选') { continue }
        $p = ($raw -replace '（.*?）','').Trim()
        if ($p -notmatch '^[0-9A-Za-z_\.]') { continue }
        $pat = $p.Replace('<课程名>','*')
        if ($pat.EndsWith('/')) { $pat += '**' }
        $rx = '^' + ([regex]::Escape($pat).Replace('\*\*','.*').Replace('\*','[^/]*')) + '$'
        $hit = @($allFiles | Where-Object { $_.FullName.Substring($v.Length + 1).Replace('\','/') -match $rx })
        $checked++
        if ($hit.Count -eq 0) { Add-W ("变量解析不到目标：{0} -> {1}" -f $name, $p); $bad++ }
    }
    if ($bad -eq 0) { Add-O ("路径变量全部可解析（{0} 个）" -f $checked) }
} else { Add-E '找不到 operating_rules.md，无法检查路径变量' }

# ---------- F 断链 ----------
$broken = 0
foreach ($md in ($allMd | Where-Object { $_.FullName -notmatch '\\\.selfstudyos\\' -and $_.FullName -notmatch '\\90_Archive\\' })) {
    $txt = [IO.File]::ReadAllText($md.FullName, [Text.Encoding]::UTF8)
    foreach ($m in [regex]::Matches($txt, '\[[^\]]*\]\(([^)#]+)(#[^)]*)?\)')) {
        $tgt = $m.Groups[1].Value.Trim()
        if ($tgt -match '^(https?:|mailto:|[A-Za-z]:)') { continue }
        if ($tgt -match '\.(md|png|jpg|pdf)$') {
            $full = Join-Path $md.DirectoryName ($tgt -replace '/','\')
            if (-not (Test-Path -LiteralPath $full)) {
                $broken++
                if ($broken -le 5) { Add-E ("断链：{0} -> {1}" -f $md.FullName.Substring($v.Length + 1), $tgt) }
            }
        }
    }
}
if ($broken -eq 0) { Add-O '相对链接全部有效' } else { Add-E ("共 {0} 条断链" -f $broken) }

# ---------- G 索引一致性 ----------
$idxPath = Join-Path $v '.selfstudyos\index.json'
if (Test-Path -LiteralPath $idxPath) {
    $idx = Get-Content -LiteralPath $idxPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $missing = 0; $drift = 0
    $registered = @{}
    foreach ($f in $idx.files) {
        $registered[$f.path] = $true
        $p = Join-Path $v ($f.path -replace '/','\')
        if (-not (Test-Path -LiteralPath $p)) { $missing++; continue }
        if ((Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower() -ne $f.sha256) { $drift++ }
    }
    Add-O ("index 版本 {0}，登记 {1} 个文件" -f $idx.version, $idx.files.Count)
    if ($missing -gt 0) { Add-W ("index 登记但缺失 {0} 个" -f $missing) }
    if ($drift -gt 0) { Add-W ("index 登记但内容已变 {0} 个（用户改过）" -f $drift) }
    if ($missing -eq 0 -and $drift -eq 0) { Add-O 'index 与库内容完全一致' }

    $opaque = @($idx.opaque)
    $unreg = 0
    foreach ($md in $allMd) {
        $rel = $md.FullName.Substring($v.Length + 1).Replace('\','/')
        if ($registered.ContainsKey($rel)) { continue }
        $skip = $false
        foreach ($o in $opaque) {
            $op = $o.Replace('<课程名>','*'); if ($op.EndsWith('/')) { $op += '**' }
            $orx = '^' + ([regex]::Escape($op).Replace('\*\*','.*').Replace('\*','[^/]*')) + '$'
            if ($rel -match $orx) { $skip = $true; break }
        }
        if (-not $skip) { $unreg++ }
    }
    if ($unreg -gt 0) { Add-W ("非 opaque 区有 {0} 个 md 未登记进索引" -f $unreg) } else { Add-O '非 opaque 区 md 全部已登记' }
}

# ---------- 输出 ----------
Write-Host ''
Write-Host '=== Vault 结构自检 ===' -ForegroundColor Cyan
Write-Host ("Vault: {0}" -f $v)
Write-Host ''
if ($err.Count)  { Write-Host "ERROR $($err.Count)" -ForegroundColor Red;    $err  | ForEach-Object { Write-Host "  x $_" -ForegroundColor Red } }
if ($warn.Count) { Write-Host "WARN  $($warn.Count)" -ForegroundColor Yellow; $warn | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Yellow } }
if ($ok.Count)   { Write-Host "PASS  $($ok.Count)" -ForegroundColor Green;    $ok   | ForEach-Object { Write-Host "  . $_" -ForegroundColor Green } }
Write-Host ''
if ($err.Count -gt 0) { Write-Host '结论：有 ERROR，未达 v1.0 结构要求。' -ForegroundColor Red; exit 1 }
if ($warn.Count -gt 0) { Write-Host '结论：无 ERROR，有 WARN 待确认。' -ForegroundColor Yellow; exit 0 }
Write-Host '结论：结构干净。' -ForegroundColor Green
exit 0
