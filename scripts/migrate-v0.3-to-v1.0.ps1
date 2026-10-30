# migrate-v0.3-to-v1.0.ps1 — 一次性迁移扫描器（v0.3 结构 → v1.0 结构）
#
# 定位：**考古报告生成器**。只读旧 Vault，产出交给另一个 AI / 人执行的清单。
# 它不执行任何迁移动作，也不写旧 Vault。
#
# 产出（全在 -Out 目录）：
#   migration-report.md        摘要 + 结构建议 + 优先处理清单
#   migration-manifest.csv     逐文件清单
#   ai-handoff/README.md       给接手 AI 的硬约束
#   ai-handoff/tasks.json      机械任务（可逐条验证）
#   ai-handoff/tasks.md        同上，人读版
#   ai-handoff/rewrites.md     需要按模板重写的文件（需理解，不可机械执行）
#   ai-handoff/state.json      进度台账（AI 边做边写）
#
# 用法：
#   powershell -File scripts/migrate-v0.3-to-v1.0.ps1 `
#     -VaultRoot "<你的Vault路径>" `
#     -TemplateRoot "<仓库路径>\vault-template" `
#     -ManifestPath "<仓库路径>\migrations\manifest-1.0.0.json" `
#     -Out "<输出目录>"

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$VaultRoot,
    [Parameter(Mandatory)][string]$TemplateRoot,
    [string]$ManifestPath = '',
    [string]$Out = '',
    [string]$OnlyCourse = ''
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'migrate-core.psm1') -Force

$VaultRoot    = (Resolve-Path -LiteralPath $VaultRoot).Path
$TemplateRoot = (Resolve-Path -LiteralPath $TemplateRoot).Path
if (-not $Out) { $Out = Join-Path (Split-Path $VaultRoot -Parent) ('migrate-' + (Get-Date -Format 'yyyyMMdd-HHmm')) }
if (-not (Test-Path -LiteralPath $Out)) { New-Item -ItemType Directory -Path $Out -Force | Out-Null }
$Out = (Resolve-Path -LiteralPath $Out).Path
if (Test-Within $Out $VaultRoot) { throw "输出目录不能放在被扫描的 Vault 内: $Out" }
$handoff = Join-Path $Out 'ai-handoff'
if (-not (Test-Path $handoff)) { New-Item -ItemType Directory -Path $handoff -Force | Out-Null }

if (-not $ManifestPath) {
    $ManifestPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'migrations\manifest-1.0.0.json'
}
$manifest = $null
if (Test-Path -LiteralPath $ManifestPath) {
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
}

Write-Host '--- 扫描前快照（只读证明用）---' -ForegroundColor DarkGray
$snapBefore = New-VaultSnapshot -Root $VaultRoot

# ---------- 步骤 1：枚举旧 Vault ----------
$files = Get-ChildItem -LiteralPath $VaultRoot -Recurse -File -Force |
         Where-Object { $_.FullName -notmatch '\\\.git\\' }
Write-Host ("文件数: {0}" -f $files.Count)

# ---------- 步骤 2：结构迁移规则（v0.3 → v1.0）----------
# 每条规则把旧路径映射到新路径，并生成一个待执行任务
$structRules = @(
    @{ Id='R1'; Rx='^70_AgentSystems/SelfStudyOS/Raw/courses/(?<course>[^/]+)/(?<rest>.+)$';
       Target='10_Courses/<course>/<type>/<file>'; Why='v0.3 把课程资料放在 Raw/courses；v1.0 要求课程实体资料在 10_Courses 下' }
    @{ Id='R2'; Rx='^70_AgentSystems/SelfStudyOS/CourseOS/(?<course>[^/]+)/raw/(?<kind>lectures|slides|quizzes|exams|ppt|papers)/(?<rest>.+)$';
       Target='10_Courses/<course>/<type>/<file>'; Why='课程实体文件不该放在 CourseOS/<课>/raw；那里只存 material_queue 工单' }
    @{ Id='R3'; Rx='^CourseOS/(?<course>[^/]+)/(?<rest>.+)$';
       Target='70_AgentSystems/SelfStudyOS/CourseOS/<course>/<rest>'; Why='Vault 根出现游离 CourseOS 目录，与 SelfStudyOS/CourseOS 重复' }
    @{ Id='R4'; Rx='^70_AgentSystems/AgentMemory/user_profile\.md$';
       Target='（内容先并入 learner_profile.md，再删除）'; Why='画像职能已移到 System/learner_profile.md' }
    @{ Id='R5'; Rx='^70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT\.md$';
       Target='（删除）'; Why='内容已并入 01_LearningDesk/06_给Agent的启动句.md' }
    @{ Id='R6'; Rx='^prompts/0[1-9]_.+\.md$';
       Target='（删除）'; Why='prompt 已被 skill 覆盖，仓库只保留资产索引' }
    @{ Id='R7'; Rx='^99_Meta/Templates/(?<rest>.+)$';
       Target='05_Templates/<rest>'; Why='模板已统一收拢到 05_Templates' }
    @{ Id='R8'; Rx='^70_AgentSystems/SelfStudyOS/CourseOS/(?<course>[^/]+)/raw/material_queue\.md$';
       Target='70_AgentSystems/SelfStudyOS/CourseOS/<course>/material_queue.md'; Why='raw/ 这个名字误导（raw 里不放原始资料），material_queue 提到课程根目录' }
)

function Convert-KindToType([string]$kind) {
    switch ($kind.ToLower()) {
        'lectures' { return 'PPT' }
        'slides'   { return 'PPT' }
        'ppt'      { return 'PPT' }
        'quizzes'  { return '测验' }
        'exams'    { return '真题' }
        'papers'   { return '真题' }
        default    { return '待定' }
    }
}

# ---------- 步骤 3：逐文件分类 ----------
$mediaExt = @('.pdf','.ppt','.pptx','.doc','.docx','.xls','.xlsx','.zip','.rar','.7z')
$rows = New-Object System.Collections.ArrayList
$structHits = @{}

foreach ($f in $files) {
    $rel = $f.FullName.Substring($VaultRoot.Length + 1).Replace('\','/')
    if ($OnlyCourse -and ($rel -notlike "*$OnlyCourse*")) { continue }

    $ext = $f.Extension.ToLower()
    $class = 'unknown'
    $note  = ''
    $structId = $null

    foreach ($r in $structRules) {
        $m = [regex]::Match($rel, $r.Rx)
        if ($m.Success) { $structId = $r.Id; break }
    }

    $tplRel = Join-Path $TemplateRoot ($rel -replace '/','\')
    if ($structId) {
        $class = "structural-$structId"
        $note = ($structRules | Where-Object { $_.Id -eq $structId } | ForEach-Object { $_.Why })
        if (-not $structHits.ContainsKey($structId)) { $structHits[$structId] = New-Object System.Collections.ArrayList }
        [void]$structHits[$structId].Add($rel)
    }
    elseif ($mediaExt -contains $ext) {
        $class = 'private-material'; $note = '课程资料/版权文件'
    }
    elseif (Test-Path -LiteralPath $tplRel) {
        $h1 = Get-FileSha256 $f.FullName
        $h2 = Get-FileSha256 $tplRel
        if ($h1 -eq $h2) { $class = 'framework-same'; $note = '与模板一致' }
        else { $class = 'framework-modified'; $note = '同名但内容不同（你改过，或它是旧版）' }
    }
    elseif ($rel -like '00_DataBackup/*') { $class = 'backup'; $note = '旧备份目录（历史镜像），迁移时不动' }
    elseif ($rel -like '50_LifeOps/Logs/Daily/*') { $class = 'user-data'; $note = '每日收口记录' }
    elseif ($rel -like '70_AgentSystems/SelfStudyOS/CourseOS/*') { $class = 'user-data'; $note = '课程学习产物' }
    elseif ($rel -like '70_AgentSystems/AgentMemory/*') { $class = 'user-data'; $note = '记忆' }

    [void]$rows.Add([pscustomobject]@{
        path    = $rel
        class   = $class
        bytes   = $f.Length
        sha256  = (Get-FileSha256 $f.FullName)
        note    = $note
        struct  = $structId
    })
}

# ---------- 步骤 4：重复内容（只报有意义的：单文件 >10KB，且按占用空间排序）----------
$dups = $rows | Where-Object { $_.sha256 -ne 'EMPTY' -and $_.bytes -gt 10240 -and $_.class -ne 'backup' } |
        Group-Object sha256 | Where-Object { $_.Count -gt 1 } |
        Sort-Object { (($_.Group | Measure-Object bytes -Sum).Sum) } -Descending

# ---------- 步骤 5：生成 ai-handoff/tasks.json ----------
$tasks = New-Object System.Collections.ArrayList
$n = 0
foreach ($r in $structRules) {
    if (-not $structHits.ContainsKey($r.Id)) { continue }
    $hitFiles = $structHits[$r.Id]
    $actions = New-Object System.Collections.ArrayList
    if ($r.Id -in 'R1','R2') {
        # 按 课程 × 资料类型 拆成多个任务，避免一个任务塞几十个动作
        $byTarget = @{}
        foreach ($rel in $hitFiles) {
            $m = [regex]::Match($rel, $r.Rx)
            $course = $m.Groups['course'].Value
            $rest   = $m.Groups['rest'].Value
            $seg    = ''
            if ($rest -match '/') { $seg = ($rest -split '/')[0] }
            $leaf = Split-Path $rel -Leaf
            $type = '待定'
            if ($seg -match '^(PPT|slides|课件|讲义)$') { $type = 'PPT' }
            elseif ($seg -match '^(真题|试卷|试题|exams|quizzes)$') { $type = '真题' }
            elseif ($seg -match '^(教材|课本)$') { $type = '教材' }
            elseif ($seg -match '^(作业)$') { $type = '作业' }
            elseif ($leaf -match '试卷|试题|真题|期末|期中|模拟|exam|quiz') { $type = '真题' }
            elseif ($leaf -match 'PPT|课件|讲义|slide|lecture') { $type = 'PPT' }
            elseif ($leaf -match '教材|课本') { $type = '教材' }
            elseif ($leaf -match '作业|HW|homework') { $type = '作业' }
            $key = "$course|$type"
            if (-not $byTarget.ContainsKey($key)) { $byTarget[$key] = New-Object System.Collections.ArrayList }
            [void]$byTarget[$key].Add($rel)
        }
        foreach ($k in ($byTarget.Keys | Sort-Object)) {
            $parts = $k.Split('|'); $course = $parts[0]; $type = $parts[1]
            $n++
            $acts = New-Object System.Collections.ArrayList
            [void]$acts.Add([ordered]@{ op='mkdir'; path="10_Courses/$course/$type" })
            foreach ($rel in $byTarget[$k]) {
                [void]$acts.Add([ordered]@{ op='copy'; from=$rel; to="10_Courses/$course/$type/$(Split-Path $rel -Leaf)"; verify='sha256' })
            }
            [void]$tasks.Add([ordered]@{
                id            = ('T-{0:D3}' -f $n)
                rule          = 'R1+R2'
                risk          = 'low'
                title         = "课程资料归位：$course / $type（$($byTarget[$k].Count) 个文件）"
                why           = 'v0.3 把课程实体资料放在 Raw/courses 与 CourseOS/<课>/raw；v1.0 统一到 10_Courses/<课程>/<类型>/'
                target        = "10_Courses/$course/$type/"
                preconditions = @(
                    '目标目录下若已存在同名文件，停止并报告，不要覆盖',
                    '每个 copy 动作完成后立即校验 sha256 与源一致'
                )
                actions       = @($acts)
                verify        = '目标文件数与源一致，且 sha256 全部匹配'
                onFailure     = 'stop-and-report'
                rollback      = '删除本次新建的目录与文件（源文件保留不动）'
            })
        }
        continue
    }
    if ($r.Id -eq 'R7') {
        foreach ($rel in $hitFiles) {
            $m = [regex]::Match($rel, $r.Rx)
            [void]$actions.Add([ordered]@{ op='copy'; from=$rel; to="05_Templates/$($m.Groups['rest'].Value)"; verify='sha256' })
        }
    } else {
        [void]$actions.Add([ordered]@{ op='manual'; reason='此规则需要人工判断内容归属，见 rewrites.md' })
    }

    $riskLevel = 'high'
    if ($r.Id -in 'R1','R2','R3','R7') { $riskLevel = 'low' }
    $n++
    $taskId = ('T-{0:D3}' -f $n)

    [void]$tasks.Add([ordered]@{
        id            = $taskId
        rule          = $r.Id
        risk          = $riskLevel
        title         = "结构迁移 $($r.Id)：$($hitFiles.Count) 个文件"
        why           = $r.Why
        target        = $r.Target
        preconditions = @(
            '目标路径下若已存在同名文件，停止并报告，不要覆盖',
            '每个 copy 动作完成后立即校验 sha256 与源一致'
        )
        actions       = @($actions)
        verify        = '目标文件数与源一致，且 sha256 全部匹配'
        onFailure     = 'stop-and-report'
        rollback      = '删除本次新建的目录与文件（源文件保留不动）'
    })
}

$state = [ordered]@{ started_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'); vault = $VaultRoot; tasks = @{} }
foreach ($t in $tasks) { $state.tasks[$t.id] = 'pending' }

Write-Utf8File -Path (Join-Path $handoff 'tasks.json') -Content ($tasks | ConvertTo-Json -Depth 8)
Write-Utf8File -Path (Join-Path $handoff 'state.json') -Content ($state | ConvertTo-Json -Depth 5)

# ---------- 步骤 6：ai-handoff/README.md ----------
$readme = @'
# 给接手 AI 的约束

你正在执行一次 **v0.3 → v1.0 的结构迁移**。请严格遵守下面六条。

## 硬约束

1. **只允许修改 `tasks.json` 里 `actions` 明确列出的路径。** 除此之外，旧 Vault 里的任何文件都视为只读。
2. **执行前逐条验证 `preconditions`。** 任何一条不成立 -> 停止，把该任务写入 `state.json` 标记为 `blocked`，并报告原因。
3. **一律 copy，不要 move。** 在全部任务验收通过之前，旧位置的文件不得删除。
4. **每完成一个 action，立刻更新 `state.json`**（id / 状态 / 时间 / 实际路径 / 校验结果）。
5. **遇到 `"op": "manual"` 的任务，不要自行决定**，停下来问用户。
6. **不确定时停止**，不要"猜一个合理做法"。

## 顺序

1. 先读 `tasks.json` 全部任务，确认你理解了每一项。
2. 按 id 升序执行。
3. 全部完成后，读 `rewrites.md`，按里面的要求做"按模板重写"——这一步需要理解内容，不能机械复制。
4. 最后把结果汇总给用户。

## 不要做的事

- 不要删除任何文件（除非用户明确批准 `manual` 任务里的删除）。
- 不要修改 `50_LifeOps/Logs/Daily/` 下的日记。
- 不要动 `10_Courses/` 下已有文件的内容。
'@
Write-Utf8File -Path (Join-Path $handoff 'README.md') -Content $readme

# ---------- 步骤 7：tasks.md（人读版）----------
$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine('# 机械任务清单（人读版）'); [void]$md.AppendLine('')
foreach ($t in $tasks) {
    [void]$md.AppendLine("## $($t.id) · $($t.title)")
    [void]$md.AppendLine("")
    [void]$md.AppendLine("- 规则：$($t.rule)　风险：$($t.risk)")
    [void]$md.AppendLine("- 为什么：$($t.why)")
    [void]$md.AppendLine("- 目标：$($t.target)")
    [void]$md.AppendLine("- 动作数：$($t.actions.Count)")
    [void]$md.AppendLine("")
}
Write-Utf8File -Path (Join-Path $handoff 'tasks.md') -Content $md.ToString()

# ---------- 步骤 8：rewrites.md ----------
$mods = $rows | Where-Object { $_.class -eq 'framework-modified' }
$rw = New-Object System.Text.StringBuilder
[void]$rw.AppendLine('# 需要按模板重写的文件'); [void]$rw.AppendLine('')
[void]$rw.AppendLine('这些文件在旧库里存在、且与当前模板内容不同。**不要机械覆盖**——你需要在保留用户原有内容的前提下，按新模板的结构补齐。'); [void]$rw.AppendLine('')
$i = 0
foreach ($m in $mods) {
    $i++
    $rwHead = ('## R-{0:D2}  {1}' -f $i, $m.path)
    [void]$rw.AppendLine($rwHead)
    [void]$rw.AppendLine('')
    [void]$rw.AppendLine("- 对应模板：$($m.path)（在模板仓库中同名）")
    [void]$rw.AppendLine("- 状态：旧库版本与模板不同")
    [void]$rw.AppendLine('- 要求：先读模板确认新结构，再读旧库版本确认用户内容，然后合并；**用户独有的段落必须保留**')
    [void]$rw.AppendLine('- 完成后自检：旧库版本里原有的自定义内容仍在，且新模板要求的章节/字段都已出现')
    [void]$rw.AppendLine('')
}
if ($mods.Count -eq 0) { [void]$rw.AppendLine('（无）') }
Write-Utf8File -Path (Join-Path $handoff 'rewrites.md') -Content $rw.ToString()

# ---------- 步骤 9：report + csv ----------
$byClass = $rows | Group-Object class | Sort-Object Count -Descending
$rep = New-Object System.Text.StringBuilder
[void]$rep.AppendLine('# 迁移扫描报告'); [void]$rep.AppendLine('')
[void]$rep.AppendLine("- 旧 Vault：$VaultRoot")
[void]$rep.AppendLine("- 新模板：$TemplateRoot")
[void]$rep.AppendLine("- 扫描时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm')")
[void]$rep.AppendLine("- 文件总数：$($rows.Count)")
[void]$rep.AppendLine('')
[void]$rep.AppendLine('## 分类统计'); [void]$rep.AppendLine('')
[void]$rep.AppendLine('| 类别 | 文件数 |'); [void]$rep.AppendLine('|---|---:|')
foreach ($g in $byClass) { [void]$rep.AppendLine("| $($g.Name) | $($g.Count) |") }
[void]$rep.AppendLine('')
[void]$rep.AppendLine('## 结构迁移建议'); [void]$rep.AppendLine('')
[void]$rep.AppendLine('| 规则 | 命中文件 | 说明 |'); [void]$rep.AppendLine('|---|---:|---|')
foreach ($r in $structRules) {
    $cnt = if ($structHits.ContainsKey($r.Id)) { $structHits[$r.Id].Count } else { 0 }
    [void]$rep.AppendLine("| $($r.Id) | $cnt | $($r.Why) |")
}
[void]$rep.AppendLine('')
[void]$rep.AppendLine('## 重复内容'); [void]$rep.AppendLine('')
if ($dups.Count -eq 0) { [void]$rep.AppendLine('（无）') }
else {
    [void]$rep.AppendLine('| 组 | 文件数 | 大小 | 示例路径 |'); [void]$rep.AppendLine('|---|---:|---:|---|')
    $j = 0
    foreach ($d in ($dups | Select-Object -First 15)) {
        $j++
        $dupMb = (($d.Group | Measure-Object bytes -Sum).Sum / 1MB)
        $dupLine = ('| D-{0:D2} | {1} | {2:N1} MB | {3} |' -f $j, $d.Count, $dupMb, $d.Group[0].path)
        [void]$rep.AppendLine($dupLine)
    }
    if ($dups.Count -gt 15) {
        [void]$rep.AppendLine('')
        [void]$rep.AppendLine(('（仅显示占用空间最大的 15 组，共 {0} 组；完整清单见 migration-manifest.csv 的 sha256 列）' -f $dups.Count))
    }
}
[void]$rep.AppendLine('')
[void]$rep.AppendLine('## 下一步'); [void]$rep.AppendLine('')
[void]$rep.AppendLine('1. 把 `ai-handoff/` 整个目录交给执行迁移的 AI。')
[void]$rep.AppendLine('2. 它按 `tasks.json` 逐条执行、按 `rewrites.md` 做内容合并。')
[void]$rep.AppendLine('3. 全部完成后，再回来做验收（对比本报告与迁移后结构）。')
Write-Utf8File -Path (Join-Path $Out 'migration-report.md') -Content $rep.ToString()

$csv = $rows | Select-Object path,class,bytes,sha256,note | ConvertTo-Csv -NoTypeInformation
Write-Utf8File -Path (Join-Path $Out 'migration-manifest.csv') -Content ($csv -join "`r`n")

# ---------- 步骤 10：只读证明 ----------
Write-Host '--- 扫描后快照（只读证明用）---' -ForegroundColor DarkGray
$snapAfter = New-VaultSnapshot -Root $VaultRoot
$diff = Compare-VaultSnapshot -Before $snapBefore -After $snapAfter

Write-Host ''
Write-Host '=== 扫描完成 ===' -ForegroundColor Cyan
Write-Host ("文件         : {0}" -f $rows.Count)
Write-Host ("结构任务     : {0}" -f $tasks.Count)
Write-Host ("待重写       : {0}" -f $mods.Count)
Write-Host ("重复组       : {0}" -f $dups.Count)
Write-Host ("输出目录     : {0}" -f $Out)
if ($diff.Count -gt 0) {
    Write-Host ('!!! 只读校验失败：扫描期间有 {0} 个文件变化' -f $diff.Count) -ForegroundColor Red
    $diff | Select-Object -First 10 | ForEach-Object { Write-Host ("  {0} {1}" -f $_.Kind, $_.Path) }
    exit 2
} else {
    Write-Host '只读校验     : 通过（扫描前后 Vault 零变化）' -ForegroundColor Green
}
