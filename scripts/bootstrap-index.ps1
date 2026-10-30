# bootstrap-index.ps1 — 给已迁移但还没有索引的 Vault 建立 .selfstudyos/index.json
#
# 口径与 gen-index.ps1 一致：枚举整个 Vault，跳过 opaque 目录。
# 模板索引只提供归属类别与版本戳；Vault 里多出来的文件按 seeded/default 处理。
#
# 默认 dry-run；加 -Apply 才写 .selfstudyos/index.json（以及缺失的 Version.md）。
#
# 用法：powershell -File scripts/bootstrap-index.ps1 -VaultRoot "D:\...\MyVault" [-Apply]

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$VaultRoot,
    [string]$TemplateIndex = '',
    [string]$TemplateRoot  = '',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$v = (Resolve-Path -LiteralPath $VaultRoot).Path
$repo = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $TemplateIndex) {
    $cands = @(Get-ChildItem (Join-Path $repo "migrations") -Filter "index-*.json" | Sort-Object { [version]($_.BaseName.Replace("index-","")) } -Descending)
    if ($cands.Count -eq 0) { throw "找不到 migrations/index-*.json" }
    $TemplateIndex = $cands[0].FullName
}
if (-not (Test-Path -LiteralPath $TemplateIndex)) { throw "找不到模板索引: $TemplateIndex" }
$tidx = Get-Content -LiteralPath $TemplateIndex -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $TemplateRoot) { $TemplateRoot = Join-Path $repo 'vault-template' }

$tmap = @{}
foreach ($f in $tidx.files) { $tmap[$f.path] = $f }

$opaque = @($tidx.opaque) + @('99_Meta/migration_*.md')

function Test-OpaqueRel([string]$rel) {
    foreach ($o in $opaque) {
        $p = $o.Replace('<课程名>','*'); if ($p.EndsWith('/')) { $p += '**' }
        $rx = '^' + ([regex]::Escape($p).Replace('\*\*','.*').Replace('\*','[^/]*')) + '$'
        if ($rel -match $rx) { return $true }
    }
    return $false
}
function Get-NormSha([string]$full) {
    if ($full -notmatch '\.(md|txt|json|ps1|psm1|yml|yaml)$') { return $null }
    try {
        $t = [IO.File]::ReadAllText($full, [Text.Encoding]::UTF8)
        $t = $t.TrimStart([char]0xFEFF).Replace("`r`n","`n").Replace("`r","`n")
        $norm = (($t.Split("`n") | ForEach-Object { $_.TrimEnd() }) -join "`n")
        $h = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($norm))
        return ([BitConverter]::ToString($h).Replace('-','').ToLower())
    } catch { return $null }
}

$files = New-Object System.Collections.ArrayList
$skipped = 0; $drifted = 0; $extra = 0
foreach ($f in (Get-ChildItem -LiteralPath $v -Recurse -File -Force -ErrorAction SilentlyContinue)) {
    if ($f.FullName -match '\\\.git\\' -or $f.Name -eq 'workspace.json') { continue }
    $rel = $f.FullName.Substring($v.Length + 1).Replace('\','/')
    if (Test-OpaqueRel $rel) { $skipped++; continue }

    $sha = if ($f.Length -eq 0) { 'EMPTY' } else { (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLower() }
    if ($tmap.ContainsKey($rel)) {
        $src = $tmap[$rel]
        $cls = $src.class; $by = $src.definedBy
        $added = $src.addedIn; $last = $src.lastModifiedIn
        if ($sha -ne $src.sha256) { $drifted++ }
    } else {
        $cls = 'seeded'; $by = 'default'; $added = $tidx.version; $last = $tidx.version; $extra++
    }
    [void]$files.Add([ordered]@{
        path           = $rel
        class          = $cls
        definedBy      = $by
        sha256         = $sha
        normSha256     = (Get-NormSha $f.FullName)
        bytes          = $f.Length
        addedIn        = $added
        lastModifiedIn = $last
    })
}

$idx = [ordered]@{
    version       = $tidx.version
    schema        = 1
    generated_at  = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    generator     = 'scripts/bootstrap-index.ps1'
    requiresStep  = $false
    source        = 'bootstrap: 枚举整个 Vault, 模板索引提供归属与版本戳'
    counts        = [ordered]@{
        files         = $files.Count
        owned         = @($files | Where-Object { $_.class -eq 'owned' }).Count
        seeded        = @($files | Where-Object { $_.class -eq 'seeded' }).Count
        opaqueSkipped = $skipped
        drifted       = $drifted
        notInTemplate = $extra
    }
    opaque        = $opaque
    variables     = @($tidx.variables)
    files         = @($files)
}

Write-Host ''
Write-Host '=== bootstrap index ===' -ForegroundColor Cyan
Write-Host ("Vault          : {0}" -f $v)
Write-Host ("版本           : {0}" -f $idx.version)
Write-Host ("登记文件       : {0}（owned {1} / seeded {2}）" -f $files.Count, $idx.counts.owned, $idx.counts.seeded)
Write-Host ("opaque 跳过    : {0}" -f $skipped)
Write-Host ("内容与模板不同 : {0}" -f $drifted)
Write-Host ("模板里没有的   : {0}" -f $extra)

if (-not $Apply) { Write-Host ''; Write-Host '(dry-run, 未写文件。确认后加 -Apply)' -ForegroundColor Yellow; exit 0 }

$sd = Join-Path $v '.selfstudyos'
if (-not (Test-Path -LiteralPath $sd)) { New-Item -ItemType Directory -Path $sd -Force | Out-Null }
[IO.File]::WriteAllText((Join-Path $sd 'index.json'), ($idx | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))

$ver = Join-Path $v '99_Meta\SelfStudyOS_Version.md'
if (-not (Test-Path -LiteralPath $ver)) {
    $src = Join-Path $TemplateRoot '99_Meta\SelfStudyOS_Version.md'
    if (Test-Path -LiteralPath $src) { Copy-Item -LiteralPath $src -Destination $ver -Force; Write-Host '已补 Version.md' -ForegroundColor Green }
}
Write-Host ''
Write-Host ("完成：{0}" -f (Join-Path $sd 'index.json')) -ForegroundColor Green