# gen-index.ps1 — 生成版本索引（index-<版本>.json + index-<版本>.md）
#
# 一份数据，两种呈现：
#   index-<v>.json  给 upgrade.ps1 用：逐文件 路径/归属/sha256/起始版本/上次修改版本
#   index-<v>.md    给人看：树形，未变目录整枝折叠
#
# 路径来源唯一：operating_rules.md 的「路径变量表」+ 少量框架文件规则。
# opaque 目录（整块归用户）不列文件、不比较、不触碰，index 因此保持很小。
#
# 用法：
#   powershell -File scripts/gen-index.ps1 -Version 1.0.0 [-Previous 旧index.json]

[CmdletBinding()]
param(
    [string]$RepoRoot  = '',
    [string]$VaultDir  = 'vault-template',
    [string]$RulesPath = 'vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md',
    [string]$Version   = '1.0.0',
    [string]$Previous  = '',
    [string]$OutDir    = ''
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$RepoRoot  = (Resolve-Path -LiteralPath $RepoRoot).Path
$vaultPath = Join-Path $RepoRoot $VaultDir
if (-not (Test-Path -LiteralPath $vaultPath)) { throw "找不到模板目录: $vaultPath" }
if (-not $OutDir) { $OutDir = Join-Path $RepoRoot 'migrations' }
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

# ---------- 归属类别（按变量名判定）----------
$classOfVariable = @{
    'AGENTS'                = 'owned'
    'OPERATING_RULES'       = 'owned'
    'WEEKLY_REVIEW'         = 'owned'
    'LEARNING_CLOSE_5LINES' = 'owned'
    'DAILY_NOTE_DIR'        = 'neverTouch'
    'YOUR_VAULT_PATH'       = 'external'
    'SKILLS_DIR'            = 'external'
}

# ---------- 不属于变量表的框架文件 ----------
$frameworkOnlyPatterns = @(
    '(^|/)README\.md$',
    '^AGENTS\.md$',
    '^CLAUDE\.md$',
    '^05_Templates/',
    '^10_Courses/ExampleCourse/',
    '^70_AgentSystems/SelfStudyOS/CourseOS/ExampleCourse/',
    '^70_AgentSystems/AgentBootstrap/',
    '^70_AgentSystems/SelfStudyOS/System/(daily_start|wiki_maintenance_rules|raw_data_pipeline)\.md$',
    '^99_Meta/SelfStudyOS_Version\.md$',
    '^\.obsidian/(app|appearance|core-plugins|templates|daily-notes)\.json$'
)

# ---------- opaque：整块归用户，不进 index ----------
$opaque = @(
    '10_Courses/',
    '70_AgentSystems/SelfStudyOS/CourseOS/*/raw/',
    '70_AgentSystems/SelfStudyOS/CourseOS/*/sessions/',
    '50_LifeOps/',
    '.selfstudyos/'
)

function Test-Opaque([string]$rel) {
    foreach ($o in $opaque) {
        $p = $o.Replace('<课程名>','*')
        if ($p.EndsWith('/')) { $p = $p + '**' }
        $rx = [regex]::Escape($p).Replace('\*\*','.*').Replace('\*','[^/]*')
        if ($rel -match ('^' + $rx + '$')) { return $true }
    }
    return $false
}

# ---------- 解析路径变量表 ----------
$rulesFull = Join-Path $RepoRoot $RulesPath
$lines = Get-Content -LiteralPath $rulesFull -Encoding UTF8
$inTable = $false
$variables = New-Object System.Collections.ArrayList
foreach ($line in $lines) {
    if ($line -match '^##\s*路径变量表') { $inTable = $true; continue }
    if ($inTable -and $line -match '^##\s+') { break }
    if ($inTable -and $line -match '^\|\s*\$\{([A-Z_]+)\}\s*\|\s*(.+?)\s*\|\s*$') {
        $name = $Matches[1]; $raw = $Matches[2]
        if ($raw -match '根路径|平台|不在 vault') { continue }
        $path = ($raw -replace '（.*?）','').Trim()
        if ($path -notmatch '^[0-9A-Za-z_\.]') { continue }
        $cls = 'seeded'
        if ($classOfVariable.ContainsKey($name)) { $cls = $classOfVariable[$name] }
        [void]$variables.Add([ordered]@{ name = $name; path = $path; class = $cls })
    }
}
if ($variables.Count -eq 0) { throw '路径变量表解析失败' }

function ConvertTo-Pattern([string]$p) {
    $x = $p.Replace('<课程名>', '*')
    if ($x.EndsWith('/')) { return $x + '**' }
    return $x
}
function Test-Pattern([string]$rel, [string]$pat) {
    $rx = '^' + ([regex]::Escape($pat).Replace('\*\*','.*').Replace('\*','[^/]*')) + '$'
    return ($rel -match $rx)
}
function Get-Sha([string]$full) {
    $item = Get-Item -LiteralPath $full
    if ($item.Length -eq 0) { return 'EMPTY' }
    if ($item.Length -le 2MB) { return (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLower() }
    $fs = [IO.File]::OpenRead($full)
    try {
        $buf = New-Object byte[] (1MB)
        [void]$fs.Read($buf,0,1MB)
        $sha = [Security.Cryptography.SHA256]::Create()
        $h = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        $fs.Seek(-1MB,[IO.SeekOrigin]::End) | Out-Null
        [void]$fs.Read($buf,0,1MB)
        $t = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        return "head:$($h.Substring(0,16))|tail:$($t.Substring(0,16))|len:$($item.Length)"
    } finally { $fs.Dispose() }
}

# ---------- 上一版索引（用于继承版本戳）----------
$prevMap = @{}
if ($Previous -and (Test-Path -LiteralPath $Previous)) {
    $pj = Get-Content -LiteralPath $Previous -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($f in $pj.files) { $prevMap[$f.path] = $f }
}

# ---------- 扫描 ----------
$all = Get-ChildItem -LiteralPath $vaultPath -Recurse -File -Force |
       Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -ne 'workspace.json' }

$files = New-Object System.Collections.ArrayList
$opaqueSkipped = 0
foreach ($f in $all) {
    $rel = $f.FullName.Substring($vaultPath.Length + 1).Replace('\','/')
    if (Test-Opaque $rel) { $opaqueSkipped++; continue }

    $cls = $null; $definedBy = $null
    foreach ($v in $variables) {
        if ($v.class -eq 'external') { continue }
        if (Test-Pattern $rel (ConvertTo-Pattern $v.path)) { $cls = $v.class; $definedBy = ('${' + $v.name + '}'); break }
    }
    if (-not $cls) {
        $isFw = $false
        foreach ($p in $frameworkOnlyPatterns) { if ($rel -match $p) { $isFw = $true; break } }
        $cls = if ($isFw) { 'owned' } else { 'seeded' }
        $definedBy = if ($isFw) { 'framework' } else { 'default' }
    }
    if ($cls -eq 'neverTouch') { $opaqueSkipped++; continue }

    $sha = Get-Sha $f.FullName
    $addedIn = $Version; $lastMod = $Version
    if ($prevMap.ContainsKey($rel)) {
        $p = $prevMap[$rel]
        $addedIn = $p.addedIn
        if ($p.sha256 -eq $sha) { $lastMod = $p.lastModifiedIn } else { $lastMod = $Version }
    }
    [void]$files.Add([ordered]@{
        path           = $rel
        class          = $cls
        definedBy      = $definedBy
        sha256         = $sha
        bytes          = $f.Length
        addedIn        = $addedIn
        lastModifiedIn = $lastMod
    })
}

# 旧版有、新版没有的文件 → 记下（供升级时提示"是否删除"，不自动删）
$removed = @()
if ($prevMap.Count -gt 0) {
    $nowPaths = @{}
    foreach ($f in $files) { $nowPaths[$f.path] = $true }
    $removed = @($prevMap.Keys | Where-Object { -not $nowPaths.ContainsKey($_) })
}

# ---------- 输出 JSON ----------
$json = [ordered]@{
    version      = $Version
    schema       = 1
    generated_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    generator    = 'scripts/gen-index.ps1'
    requiresStep = $false
    source       = 'operating_rules.md 路径变量表 + 框架文件规则'
    counts       = [ordered]@{ files = $files.Count; owned = @($files | Where-Object { $_.class -eq 'owned' }).Count; seeded = @($files | Where-Object { $_.class -eq 'seeded' }).Count; opaqueSkipped = $opaqueSkipped }
    opaque       = $opaque
    variables    = @($variables)
    files        = @($files)
    removedIn    = $removed
}
$jsonPath = Join-Path $OutDir "index-$Version.json"
[IO.File]::WriteAllText($jsonPath, ($json | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))

# ---------- 输出 Markdown（树形；有上一版索引时才折叠未变目录）----------
# 第一版是"完整清单"，不折叠；后续版本才折叠，让读者只看变化。
$foldUnchanged = ($prevMap.Count -gt 0)
$byDir = @{}
foreach ($f in $files) {
    $dir = ''; $name = $f.path
    if ($f.path.Contains('/')) { $dir = $f.path.Substring(0, $f.path.LastIndexOf('/')); $name = Split-Path $f.path -Leaf }
    if (-not $byDir.ContainsKey($dir)) { $byDir[$dir] = New-Object System.Collections.ArrayList }
    [void]$byDir[$dir].Add([pscustomobject]@{ name = $name; entry = $f })
}

# 补齐"只含子目录、自己没有直接文件"的中间目录（否则树会缺层）
$allAncestors = New-Object System.Collections.Generic.HashSet[string]
foreach ($f in $files) {
    $parts = $f.path.Split('/')
    for ($i = 1; $i -lt $parts.Count; $i++) {
        $null = $allAncestors.Add(($parts[0..($i-1)] -join '/'))
    }
}
foreach ($d in $allAncestors) {
    if (-not $byDir.ContainsKey($d)) { $byDir[$d] = New-Object System.Collections.ArrayList }
}

function Get-DirStamp([string]$dir) {
    # 该目录（含子目录）下所有文件是否同一个 lastModifiedIn
    $stamps = @()
    foreach ($k in $byDir.Keys) {
        if ($k -eq $dir -or $k.StartsWith($dir + '/')) {
            foreach ($it in $byDir[$k]) { $stamps += $it.entry.lastModifiedIn }
        }
    }
    if ($stamps.Count -eq 0) { return $null }
    $u = @($stamps | Select-Object -Unique)
    if ($u.Count -eq 1) { return [string]$u[0] }
    return $null
}

function Format-Stamp($entry) {
    if ($entry.lastModifiedIn -ne $entry.addedIn) { return ('→' + $entry.lastModifiedIn) }
    return ('@' + $entry.lastModifiedIn)
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# index v$Version")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('标记：`@版本` = 自该版本起未改动；`→版本` = 该版本改过。整块未变的目录折叠为一行。')
[void]$sb.AppendLine('')
[void]$sb.AppendLine(('文件 {0} 个（owned {1} / seeded {2}）；不透明目录已跳过 {3} 个文件。' -f $files.Count, $json.counts.owned, $json.counts.seeded, $opaqueSkipped))
[void]$sb.AppendLine('')

function Render-Node([string]$dir, [int]$depth) {
    $indent = '  ' * $depth
    if ($dir -ne '') {
        $stamp = Get-DirStamp $dir
        if ($foldUnchanged -and $stamp) {
            [void]$sb.AppendLine(('{0}{1}/    @{2}' -f $indent, (Split-Path $dir -Leaf), $stamp))
            return
        }
        [void]$sb.AppendLine(('{0}{1}/' -f $indent, (Split-Path $dir -Leaf)))
    }
    if ($byDir.ContainsKey($dir)) {
        foreach ($it in ($byDir[$dir] | Sort-Object name)) {
            [void]$sb.AppendLine(('{0}  {1}    {2}' -f $indent, $it.name, (Format-Stamp $it.entry)))
        }
    }
    $children = @()
    foreach ($k in $byDir.Keys) {
        if ($k -eq $dir) { continue }
        if ($dir -eq '') {
            if ($k -notmatch '/') { $children += $k }
        } elseif ($k.StartsWith($dir + '/')) {
            if (($k.Substring($dir.Length + 1)) -notmatch '/') { $children += $k }
        }
    }
    foreach ($c in ($children | Sort-Object)) { Render-Node $c ($depth + 1) }
}

Render-Node '' 0

[void]$sb.AppendLine('')
[void]$sb.AppendLine('## 不透明目录（整块归用户，不列文件、不比较、不触碰）')
[void]$sb.AppendLine('')
foreach ($o in $opaque) { [void]$sb.AppendLine(('  {0}' -f $o)) }

$mdPath = Join-Path $OutDir "index-$Version.md"
[IO.File]::WriteAllText($mdPath, $sb.ToString(), (New-Object Text.UTF8Encoding($false)))

Write-Host ''
Write-Host '=== index 生成完成 ===' -ForegroundColor Cyan
Write-Host ("版本      : {0}" -f $Version)
Write-Host ("文件      : {0}（owned {1} / seeded {2}）" -f $files.Count, $json.counts.owned, $json.counts.seeded)
Write-Host ("不透明跳过: {0} 个文件" -f $opaqueSkipped)
Write-Host ("输出      : {0}" -f $jsonPath)
Write-Host ("            {0}" -f $mdPath)
