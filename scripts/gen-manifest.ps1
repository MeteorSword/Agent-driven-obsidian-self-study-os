# gen-manifest.ps1 — 从路径变量表推导"文件归属清单"(manifest)
#
# 设计原则：**路径只有一个来源**——operating_rules.md 的「路径变量表」。
# 本脚本不自己维护第二份路径清单，只做三件事：
#   1. 解析变量表，按变量名判定归属（owned / seeded / neverTouch / external）
#   2. 把含 <课程名> 的变量展开为通配，扫出模板里实际存在的文件并算 sha256
#   3. 补上"不属于变量表"的框架文件（各级 README、AGENTS.md、.obsidian 配置等）
#
# 只读仓库，只写 -Out 指定的那一个 json。
#
# 用法：powershell -File scripts/gen-manifest.ps1 [-Version 1.0.0] [-Out 路径]

[CmdletBinding()]
param(
    [string]$RepoRoot  = '',
    [string]$VaultDir  = 'vault-template',
    [string]$RulesPath = 'vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md',
    [string]$Version   = '1.0.0',
    [string]$Out       = ''
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$RepoRoot  = (Resolve-Path -LiteralPath $RepoRoot).Path
$vaultPath = Join-Path $RepoRoot $VaultDir
if (-not (Test-Path -LiteralPath $vaultPath)) { throw "找不到模板目录: $vaultPath" }
if (-not $Out) { $Out = Join-Path $RepoRoot "migrations\manifest-$Version.json" }

# ---------- 1. 变量 → 归属类别（只判类别，不写路径）----------
$classOfVariable = @{
    'AGENTS'                = 'owned'
    'OPERATING_RULES'       = 'owned'
    'WEEKLY_REVIEW'         = 'owned'
    'LEARNING_CLOSE_5LINES' = 'owned'
    'DAILY_NOTE_DIR'        = 'neverTouch'
    'YOUR_VAULT_PATH'       = 'external'
    'SKILLS_DIR'            = 'external'
}

# ---------- 2. 不属于变量表的框架文件 ----------
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

$neverTouchGlobs = @(
    '50_LifeOps/Logs/Daily/**',
    '10_Courses/**（ExampleCourse 除外）',
    '80_Attachments/**',
    '90_Archive/**',
    '00_Inbox/**',
    '20_Projects/**',
    '30_Research/**',
    '40_Knowledge/**',
    '70_AgentSystems/SelfStudyOS/CourseOS/*/sessions/**',
    '70_AgentSystems/SelfStudyOS/CourseOS/*/concepts/*.md（concept_index.md 除外）',
    '70_AgentSystems/SelfStudyOS/CourseOS/*/mistakes/*.md（mistake_index.md 除外）',
    '99_Meta/migration_*.md'
)

# ---------- 3. 解析路径变量表 ----------
$rulesFull = Join-Path $RepoRoot $RulesPath
if (-not (Test-Path -LiteralPath $rulesFull)) { throw "找不到规则文件: $rulesFull" }
$lines = Get-Content -LiteralPath $rulesFull -Encoding UTF8
$inTable = $false
$variables = New-Object System.Collections.ArrayList
foreach ($line in $lines) {
    if ($line -match '^##\s*路径变量表') { $inTable = $true; continue }
    if ($inTable -and $line -match '^##\s+') { break }
    if ($inTable -and $line -match '^\|\s*\$\{([A-Z_]+)\}\s*\|\s*(.+?)\s*\|\s*$') {
        $name = $Matches[1]
        $raw  = $Matches[2]
        if ($raw -match '根路径|平台|不在 vault') { continue }
        $path = ($raw -replace '（.*?）','').Trim()
        if ($path -notmatch '^[0-9A-Za-z_\.]' ) { continue }
        $cls = 'seeded'
        if ($classOfVariable.ContainsKey($name)) { $cls = $classOfVariable[$name] }
        [void]$variables.Add([ordered]@{ name = $name; path = $path; class = $cls })
    }
}
if ($variables.Count -eq 0) { throw '路径变量表解析失败：没有读到任何 ${VAR} 行' }

function ConvertTo-Pattern([string]$p) {
    $x = $p.Replace('<课程名>', '*')
    if ($x.EndsWith('/')) { return $x + '**' }
    return $x
}

function Test-Pattern([string]$rel, [string]$pat) {
    $rx = '^' + ([regex]::Escape($pat).Replace('\*\*','.*').Replace('\*','[^/]*')) + '$'
    return ($rel -match $rx)
}

# ---------- 4. 扫描并分类 ----------
function Get-Sha([string]$full) {
    $len = (Get-Item -LiteralPath $full).Length
    if ($len -eq 0) { return 'EMPTY' }
    if ($len -le 2MB) { return (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLower() }
    $fs = [IO.File]::OpenRead($full)
    try {
        $buf = New-Object byte[] (1MB)
        [void]$fs.Read($buf,0,1MB)
        $sha = [Security.Cryptography.SHA256]::Create()
        $h = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        $fs.Seek(-1MB,[IO.SeekOrigin]::End) | Out-Null
        [void]$fs.Read($buf,0,1MB)
        $t = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        return "head:$($h.Substring(0,16))|tail:$($t.Substring(0,16))|len:$len"
    } finally { $fs.Dispose() }
}

$all = Get-ChildItem -LiteralPath $vaultPath -Recurse -File -Force |
       Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -ne 'workspace.json' }

$owned  = New-Object System.Collections.ArrayList
$seeded = New-Object System.Collections.ArrayList
$neverCount = 0

foreach ($f in $all) {
    $rel = $f.FullName.Substring($vaultPath.Length + 1).Replace('\','/')

    $hitVar = $null
    foreach ($v in $variables) {
        if ($v.class -eq 'external') { continue }
        if (Test-Pattern $rel (ConvertTo-Pattern $v.path)) { $hitVar = $v; break }
    }
    if ($hitVar) {
        if ($hitVar.class -eq 'neverTouch') { $neverCount++; continue }
        $item = [ordered]@{
            path      = $rel
            sha256    = (Get-Sha $f.FullName)
            bytes     = $f.Length
            definedBy = ('${' + $hitVar.name + '}')
        }
        if ($hitVar.class -eq 'owned') { [void]$owned.Add($item) } else { [void]$seeded.Add($item) }
        continue
    }

    $isFramework = $false
    foreach ($p in $frameworkOnlyPatterns) { if ($rel -match $p) { $isFramework = $true; break } }
    $item = [ordered]@{
        path      = $rel
        sha256    = (Get-Sha $f.FullName)
        bytes     = $f.Length
        definedBy = $(if ($isFramework) { 'framework' } else { 'default' })
    }
    if ($isFramework) { [void]$owned.Add($item) } else { [void]$seeded.Add($item) }
}

# ---------- 5. 输出 ----------
$manifest = [ordered]@{
    version        = $Version
    generated_at   = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    generator      = 'scripts/gen-manifest.ps1'
    source         = 'vault-template/70_AgentSystems/SelfStudyOS/System/operating_rules.md（路径变量表）'
    scope          = $VaultDir
    note           = '路径来源唯一：operating_rules.md 路径变量表。owned 可更新；seeded 只报差异；neverTouch 不碰。'
    counts         = [ordered]@{ owned = $owned.Count; seeded = $seeded.Count; neverTouchHit = $neverCount; variables = $variables.Count }
    variables      = @($variables)
    frameworkOnly  = $frameworkOnlyPatterns
    owned          = @($owned)
    seeded         = @($seeded)
    seededPatterns = @($variables | Where-Object { $_.class -eq 'seeded' } | ForEach-Object { ConvertTo-Pattern $_.path })
    neverTouch     = $neverTouchGlobs
}

$outDir = Split-Path $Out -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
[IO.File]::WriteAllText($Out, ($manifest | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))

Write-Host ''
Write-Host '=== manifest 生成完成（来源：路径变量表）===' -ForegroundColor Cyan
Write-Host ("解析变量     : {0} 个" -f $variables.Count)
Write-Host ("owned        : {0} 个文件" -f $owned.Count)
Write-Host ("seeded       : {0} 个文件" -f $seeded.Count)
Write-Host ("neverTouch   : {0} 个文件被排除" -f $neverCount)
Write-Host ("输出         : {0}" -f $Out)
Write-Host ''
Write-Host '--- 变量表判定 ---' -ForegroundColor DarkGray
$variables | ForEach-Object { Write-Host ("  {0,-26} {1,-11} {2}" -f ('${' + $_.name + '}'), $_.class, $_.path) -ForegroundColor DarkGray }
