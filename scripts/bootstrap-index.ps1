# bootstrap-index.ps1 — 给"已迁移但还没有 index"的 Vault 建立 .selfstudyos/index.json
#
# 场景：用 migrate-v0.3-to-v1.0.ps1 迁完之后，库是 v1.0 结构但没有指纹表，
#       导致 upgrade.ps1 会认为它是 pre-1.0 而拒绝运行。
#
# 做法：以仓库的 index-<版本>.json 为模板，只保留"该 Vault 真实存在"的文件，
#       重新计算 sha256 / normSha256，并保持归属类别与版本戳；
#       示例课（ExampleCourse）若不存在则不写入；另补上该 Vault 各门课自己的文件。
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
if (-not $TemplateIndex) { $TemplateIndex = Join-Path $repo 'migrations\index-1.0.0.json' }
if (-not (Test-Path -LiteralPath $TemplateIndex)) { throw "找不到模板 index: $TemplateIndex" }
$tidx = Get-Content -LiteralPath $TemplateIndex -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $TemplateRoot) { $TemplateRoot = Join-Path $repo 'vault-template' }

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

$hasExample = Test-Path -LiteralPath (Join-Path $v '70_AgentSystems\SelfStudyOS\CourseOS\ExampleCourse')
$files = New-Object System.Collections.ArrayList
$skipped = 0; $drifted = 0

foreach ($f in $tidx.files) {
    if ($f.path -like '*CourseOS/ExampleCourse/*' -and -not $hasExample) { $skipped++; continue }
    $p = Join-Path $v ($f.path -replace '/','\')
    if (-not (Test-Path -LiteralPath $p)) { $skipped++; continue }
    $sha = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()
    if ($sha -ne $f.sha256) { $drifted++ }
    [void]$files.Add([ordered]@{
        path           = $f.path
        class          = $f.class
        definedBy      = $f.definedBy
        sha256         = $sha
        normSha256     = (Get-NormSha $p)
        bytes          = (Get-Item -LiteralPath $p).Length
        addedIn        = $f.addedIn
        lastModifiedIn = $f.lastModifiedIn
    })
}

# 补：该 Vault 各门课自己的 seeded 文件（不在模板 index 里）
$courseRoot = Join-Path $v '70_AgentSystems\SelfStudyOS\CourseOS'
$added = 0
if (Test-Path -LiteralPath $courseRoot) {
    Get-ChildItem -LiteralPath $courseRoot -Directory | ForEach-Object {
        $c = $_.Name
        if ($c -eq 'ExampleCourse') { return }
        $cands = @("$c/$(($c))-MOC.md","$c/progress.md","$c/material_queue.md","$c/course_profile.md",
                   "$c/concepts/concept_index.md","$c/mistakes/mistake_index.md",
                   "$c/problems/problem_index.md","$c/problems/exam_topic_index.md")
        foreach ($rel in $cands) {
            $full = Join-Path $v ("70_AgentSystems\SelfStudyOS\CourseOS\" + ($rel -replace '/','\'))
            if (Test-Path -LiteralPath $full) {
                $rp = "70_AgentSystems/SelfStudyOS/CourseOS/$rel"
                if ($files | Where-Object { $_.path -eq $rp }) { continue }
                [void]$files.Add([ordered]@{
                    path = $rp; class = 'seeded'; definedBy = 'default'
                    sha256 = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLower()
                    normSha256 = (Get-NormSha $full); bytes = (Get-Item -LiteralPath $full).Length
                    addedIn = '1.0.0'; lastModifiedIn = '1.0.0'
                })
                $added++
            }
        }
    }
}

$idx = [ordered]@{
    version      = $tidx.version
    schema       = 1
    generated_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    generator    = 'scripts/bootstrap-index.ps1'
    requiresStep = $false
    source       = 'bootstrap：以仓库 index 为模板，按本 Vault 实际文件重建'
    counts       = [ordered]@{ files = $files.Count; owned = @($files | Where-Object { $_.class -eq 'owned' }).Count; seeded = @($files | Where-Object { $_.class -eq 'seeded' }).Count; skipped = $skipped; drifted = $drifted; courseFilesAdded = $added }
    opaque       = $tidx.opaque
    files        = @($files)
}

Write-Host ''
Write-Host '=== bootstrap index（干跑）===' -ForegroundColor Cyan
Write-Host ("Vault          : {0}" -f $v)
Write-Host ("版本           : {0}" -f $idx.version)
Write-Host ("登记文件       : {0}（owned {1} / seeded {2}）" -f $files.Count, $idx.counts.owned, $idx.counts.seeded)
Write-Host ("跳过（库中无） : {0}" -f $skipped)
Write-Host ("内容与模板不同 : {0}（你自己改过，正常）" -f $drifted)
Write-Host ("补入课程文件   : {0}" -f $added)

if (-not $Apply) { Write-Host ''; Write-Host '（dry-run，未写文件。确认后加 -Apply）' -ForegroundColor Yellow; exit 0 }

$sd = Join-Path $v '.selfstudyos'
if (-not (Test-Path -LiteralPath $sd)) { New-Item -ItemType Directory -Path $sd -Force | Out-Null }
[IO.File]::WriteAllText((Join-Path $sd 'index.json'), ($idx | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))

$ver = Join-Path $v '99_Meta\SelfStudyOS_Version.md'
if (-not (Test-Path -LiteralPath $ver)) {
    $src = Join-Path $TemplateRoot '99_Meta\SelfStudyOS_Version.md'
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination $ver -Force
        Write-Host ("已补 Version.md：{0}" -f $ver) -ForegroundColor Green
    }
}
Write-Host ''
Write-Host ("完成：{0}" -f (Join-Path $sd 'index.json')) -ForegroundColor Green
Write-Host '下一步：powershell -File scripts/verify-vault.ps1 -VaultRoot <该Vault>' -ForegroundColor DarkGray
