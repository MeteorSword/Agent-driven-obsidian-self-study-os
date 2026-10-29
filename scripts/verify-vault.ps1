# verify-vault.ps1 — 迁移后结构自检（只读）
#
# 检查一个 Vault 是否已经是干净的 v1.0 结构，并报告残留。
# 不修改任何文件。
#
# 用法：powershell -File scripts/verify-vault.ps1 -VaultRoot "D:\...\MyVault"

[CmdletBinding()]
param([Parameter(Mandatory)][string]$VaultRoot)

$ErrorActionPreference = 'Stop'
$v = (Resolve-Path -LiteralPath $VaultRoot).Path
$err = New-Object System.Collections.ArrayList
$warn = New-Object System.Collections.ArrayList
$ok  = New-Object System.Collections.ArrayList

function Add-E($m) { [void]$err.Add($m) }
function Add-W($m) { [void]$warn.Add($m) }
function Add-O($m) { [void]$ok.Add($m) }

# ---------- 1. 必需文件 ----------
$required = @(
    '01_LearningDesk/06_给Agent的启动句.md',
    '70_AgentSystems/SelfStudyOS/System/operating_rules.md',
    '70_AgentSystems/SelfStudyOS/AGENTS.md',
    'AGENTS.md',
    '05_Templates/learning_close_5lines.md',
    '99_Meta/SelfStudyOS_Version.md',
    '.selfstudyos/index.json'
)
foreach ($r in $required) {
    if (Test-Path -LiteralPath (Join-Path $v ($r -replace '/','\'))) { Add-O "必需文件存在：$r" }
    else { Add-E "必需文件缺失：$r" }
}

# ---------- 2. 旧结构残留 ----------
$legacy = @(
    @{ Path='70_AgentSystems/SelfStudyOS/Raw/courses'; Name='旧课程资料位置 Raw/courses' },
    @{ Path='CourseOS';                                Name='Vault 根的游离 CourseOS 目录' },
    @{ Path='99_Meta/Templates';                       Name='旧模板位置 99_Meta/Templates' }
)
foreach ($l in $legacy) {
    $p = Join-Path $v ($l.Path -replace '/','\')
    if (Test-Path -LiteralPath $p) { Add-W ("{0} 仍存在：{1}" -f $l.Name, $l.Path) }
    else { Add-O ("{0} 已清理" -f $l.Name) }
}

$oldStart = Get-ChildItem -LiteralPath $v -Recurse -File -Filter 'START_HERE*' -ErrorAction SilentlyContinue
if ($oldStart) { Add-W ("START_HERE 类文件仍有 {0} 个" -f $oldStart.Count) } else { Add-O 'START_HERE 类文件已清理' }

$oldPrompt = Get-ChildItem -LiteralPath (Join-Path $v 'prompts') -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -match '^0[1-9]_' }
if ($oldPrompt) { Add-W ("prompts/ 下仍有 {0} 个旧 prompt 文件" -f $oldPrompt.Count) } else { Add-O '旧 prompt 已清理' }

$oldQueue = Get-ChildItem -LiteralPath $v -Recurse -File -Filter 'material_queue.md' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '\\raw\\' }
if ($oldQueue) {
    Add-W ("material_queue.md 仍在 raw/ 下 {0} 个（应移到课程根目录）" -f $oldQueue.Count)
    foreach ($q in $oldQueue) { Write-Host ("     - " + $q.FullName.Substring($v.Length + 1)) -ForegroundColor DarkGray }
} else { Add-O 'material_queue.md 位置正确' }

# ---------- 3. index 一致性 ----------
$idxPath = Join-Path $v '.selfstudyos\index.json'
if (Test-Path -LiteralPath $idxPath) {
    $idx = Get-Content -LiteralPath $idxPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Add-O ("index 版本：{0}，登记 {1} 个文件" -f $idx.version, $idx.files.Count)
    $missing = 0; $drift = 0
    foreach ($f in $idx.files) {
        $p = Join-Path $v ($f.path -replace '/','\')
        if (-not (Test-Path -LiteralPath $p)) { $missing++; continue }
        $sha = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()
        if ($sha -ne $f.sha256) { $drift++ }
    }
    if ($missing -gt 0) { Add-W ("index 登记但库中缺失：{0} 个文件（可能是你删掉的）" -f $missing) }
    if ($drift -gt 0) { Add-W ("index 登记但内容已变：{0} 个文件（你自己改过 → 升级时不会覆盖）" -f $drift) }
    if ($missing -eq 0 -and $drift -eq 0) { Add-O 'index 与库内容完全一致' }
}

# ---------- 输出 ----------
Write-Host ''
Write-Host '=== Vault 结构自检 ===' -ForegroundColor Cyan
Write-Host ("Vault: {0}" -f $v)
Write-Host ''
if ($err.Count) { Write-Host "ERROR $($err.Count)" -ForegroundColor Red;  $err  | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red } }
if ($warn.Count) { Write-Host "WARN  $($warn.Count)" -ForegroundColor Yellow; $warn | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Yellow } }
if ($ok.Count)   { Write-Host "PASS  $($ok.Count)" -ForegroundColor Green;  $ok   | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green } }
Write-Host ''
if ($err.Count -gt 0) { Write-Host '结论：结构不完整，先补必需文件。' -ForegroundColor Red; exit 1 }
if ($warn.Count -gt 0) { Write-Host '结论：可用，但有残留项建议清理。' -ForegroundColor Yellow; exit 0 }
Write-Host '结论：结构干净。' -ForegroundColor Green
exit 0
