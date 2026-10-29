# preflight.ps1 — 发布前只读检查
#
# 用途：在把仓库公开（或推送）之前，确认没有隐私泄漏、大文件、断链。
# 特征：只读。不修改任何文件，不执行 git 写操作。
#
# 用法：
#   pwsh -File scripts/preflight.ps1                 # 检查当前树
#   pwsh -File scripts/preflight.ps1 -History        # 额外扫描 git 历史
#   pwsh -File scripts/preflight.ps1 -Json out.json  # 同时输出 JSON 报告
#
# 退出码：0 = 通过（可能有 WARN）；1 = 有 BLOCK 项

[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [switch]$History,
    [string]$Json
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\','/')
$script:block = New-Object System.Collections.ArrayList
$script:warn  = New-Object System.Collections.ArrayList
$script:info  = New-Object System.Collections.ArrayList

function Get-Rel([string]$full) {
    if ($full.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($Root.Length).TrimStart('\','/')
    }
    return $full
}

function Test-SafePath([string]$p) {
    # 路径可能越出盘符根（相对链接穿越），Test-Path 会抛异常，这里吞掉
    try { return (Test-Path -LiteralPath $p) } catch { return $false }
}

function Add-Block([string]$code, [string]$where, [string]$detail) {
    [void]$script:block.Add([pscustomobject]@{ Level='BLOCK'; Code=$code; Where=$where; Detail=$detail })
}
function Add-Warn([string]$code, [string]$where, [string]$detail) {
    [void]$script:warn.Add([pscustomobject]@{ Level='WARN'; Code=$code; Where=$where; Detail=$detail })
}

Push-Location $Root
try {
    # ---------- 0. 采集文件清单（只取被 git 跟踪的文件；无 git 时退化为磁盘遍历） ----------
    $isGit = Test-Path (Join-Path $Root '.git')
    if ($isGit) {
        $tracked = & git -c core.quotepath=false ls-files
        $files = $tracked | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path -LiteralPath $_ }
        [void]$script:info.Add("文件来源：git tracked（$($files.Count) 个）")
    } else {
        $files = Get-ChildItem -Recurse -File -Force |
            Where-Object { $_.FullName -notmatch '\\\.git\\' } |
            Select-Object -ExpandProperty FullName
        [void]$script:info.Add("文件来源：磁盘遍历（$($files.Count) 个）")
    }

    $textExt = @('.md','.txt','.json','.ps1','.yml','.yaml','.gitignore','.gitattributes','.typ')
    $textFiles = $files | Where-Object { $textExt -contains [IO.Path]::GetExtension($_).ToLower() -or (Split-Path $_ -Leaf) -in '.gitignore','.gitattributes' }

    # 示例路径白名单：这些文件里的绝对路径是给人看的示例，不是真实泄漏
    $pathAllow = @('windows-setup.md','privacy-and-safety.md','publish-checklist.md','CONTRIBUTING.md','selfstudyos-course-workflow','selfstudyos-workflow')

    # ---------- 1. 敏感串（BLOCK） ----------
    $secretRules = @(
        @{ Code='SECRET-SK';     Pattern='\bsk-[A-Za-z0-9_\-]{16,}' },
        @{ Code='SECRET-GHP';    Pattern='\bghp_[A-Za-z0-9]{20,}' },
        @{ Code='SECRET-AWS';    Pattern='\bAKIA[0-9A-Z]{16}\b' },
        @{ Code='SECRET-PRIVKEY';Pattern='-----BEGIN [A-Z ]*PRIVATE KEY-----' },
        @{ Code='SECRET-ASSIGN'; Pattern='(?i)(api[_-]?key|secret|password|passwd|token)\s*[:=]\s*["'']?[A-Za-z0-9_\-]{12,}' }
    )
    foreach ($f in $textFiles) {
        $lines = Get-Content -LiteralPath $f -Encoding UTF8 -ErrorAction SilentlyContinue
        $n = 0
        foreach ($line in $lines) {
            $n++
            foreach ($r in $secretRules) {
                if ($line -match $r.Pattern) {
                    Add-Block $r.Code "$((Get-Rel $f)):$n" '疑似密钥/凭据'
                }
            }
        }
    }

    # ---------- 2. 邮箱 / 手机号 / 学号（BLOCK，示例值除外） ----------
    $emailPattern = '[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}'
    $emailAllow  = 'noreply@|example\.com|example\.org|users\.noreply\.github\.com|git@github\.com|@localhost|<[^>]*>'
    $phonePattern = '(?<!\d)1[3-9]\d{9}(?!\d)'
    $sidPattern   = '学号[:：]?\s*[A-Za-z]?\d{6,}'
    foreach ($f in $textFiles) {
        $rel = (Get-Rel $f)
        $lines = Get-Content -LiteralPath $f -Encoding UTF8 -ErrorAction SilentlyContinue
        $n = 0
        foreach ($line in $lines) {
            $n++
            foreach ($m in [regex]::Matches($line, $emailPattern)) {
                if ($m.Value -notmatch $emailAllow) { Add-Block 'PII-EMAIL' "${rel}:$n" $m.Value }
            }
            if ($line -match $phonePattern) { Add-Block 'PII-PHONE' "${rel}:$n" '疑似手机号' }
            if ($line -match $sidPattern)   { Add-Block 'PII-SID'   "${rel}:$n" '疑似学号' }
        }
    }

    # ---------- 3. 本机绝对路径（WARN；白名单文件跳过） ----------
    $absPattern = '[A-Za-z]:\\[^\s`"''\]]{3,}'
    foreach ($f in $textFiles) {
        $rel = (Get-Rel $f)
        $leaf = Split-Path $f -Leaf
        $allowed = $false
        foreach ($a in $pathAllow) { if ($rel -like "*$a*") { $allowed = $true } }
        $lines = Get-Content -LiteralPath $f -Encoding UTF8 -ErrorAction SilentlyContinue
        $n = 0
        foreach ($line in $lines) {
            $n++
            foreach ($m in [regex]::Matches($line, $absPattern)) {
                if ($m.Value -notmatch '<|\$|Users\\<') {
                    if ($allowed) { Add-Warn 'PATH-EXAMPLE' "${rel}:$n" $m.Value }
                    else          { Add-Block 'PATH-ABS'     "${rel}:$n" $m.Value }
                }
            }
        }
    }

    # ---------- 4. 大文件（BLOCK） ----------
    foreach ($f in $files) {
        $len = (Get-Item -LiteralPath $f).Length
        if ($len -gt 5MB) { Add-Block 'FILE-BIG' ((Get-Rel $f)) ('{0:N1} MB' -f ($len/1MB)) }
    }

    # ---------- 5. 断链（WARN） ----------
    $vaultRoot = Join-Path $Root 'vault-template'
    if (Test-Path $vaultRoot) {
        # 文件名索引，近似 Obsidian 的最短路径解析
        $index = @{}
        Get-ChildItem $vaultRoot -Recurse -File -Filter '*.md' | ForEach-Object {
            $k = $_.BaseName
            if (-not $index.ContainsKey($k)) { $index[$k] = @() }
            $index[$k] += $_.FullName
        }
        Get-ChildItem $vaultRoot -Recurse -File -Filter '*.md' | ForEach-Object {
            $rel = (Get-Rel $_.FullName)
            $lines = Get-Content -LiteralPath $_.FullName -Encoding UTF8
            $n = 0
            foreach ($line in $lines) {
                $n++
                foreach ($m in [regex]::Matches($line, '\[\[([^\]\|#]+)')) {
                    $target = $m.Groups[1].Value.Trim()
                    $name = Split-Path $target -Leaf
                    if (-not $index.ContainsKey($name)) { Add-Warn 'LINK-WIKI' "${rel}:$n" "[[$target]] 目标不存在" }
                }
                foreach ($m in [regex]::Matches($line, '\]\(([^)]+\.md)(?:#[^)]*)?\)')) {
                    $t = $m.Groups[1].Value
                    if ($t -match '^https?:') { continue }
                    $resolved = Join-Path (Split-Path $_.FullName -Parent) $t
                    $ok = Test-SafePath $resolved
                    if (-not $ok) { $ok = Test-SafePath (Join-Path $Root $t) }
                    if (-not $ok) { Add-Warn 'LINK-MD' "${rel}:$n" "$t 目标不存在" }
                }
            }
        }
    }

    # ---------- 6. 编码（WARN） ----------
    foreach ($f in $textFiles) {
        $bytes = [IO.File]::ReadAllBytes($f)
        if ($bytes.Length -eq 0) { continue }
        try { [void](New-Object System.Text.UTF8Encoding($false,$true)).GetString($bytes) }
        catch { Add-Warn 'ENCODING' ((Get-Rel $f)) '不是合法 UTF-8' }
    }

    # ---------- 7. 历史扫描（可选，只读） ----------
    if ($History -and $isGit) {
        $revs = & git rev-list --all
        $histPatterns = @{
            'HIST-SCHOOL' = '中国科学技术大学|中科大|USTC'
            'HIST-PATH'   = 'D:\\SelfStudy'
            'HIST-QQ'     = '[0-9]{6,12}@qq\.com'
            'HIST-COURSE' = '数学分析B2|分析化学|化学原理|电磁学|电路基本理论'
        }
        foreach ($k in $histPatterns.Keys) {
            $out = & git grep -I -l -E $histPatterns[$k] $revs -- 2>$null
            $cnt = ($out | Measure-Object).Count
            if ($cnt -gt 0) { Add-Block $k "history" "$cnt 个历史文件命中" }
            else            { [void]$script:info.Add("$k : 0") }
        }
    }

    # ---------- 输出 ----------
    Write-Host ''
    Write-Host "=== SelfStudyOS preflight === root: $Root" -ForegroundColor Cyan
    Write-Host "BLOCK: $($script:block.Count)   WARN: $($script:warn.Count)"
    if ($script:block.Count -gt 0) {
        Write-Host ''
        Write-Host '--- BLOCK（必须修复才能发布）---' -ForegroundColor Red
        $script:block | Format-Table -AutoSize Level,Code,Where,Detail | Out-String -Width 200 | Write-Host
    }
    if ($script:warn.Count -gt 0) {
        Write-Host '--- WARN（人工确认即可）---' -ForegroundColor Yellow
        $script:warn | Group-Object Code | ForEach-Object {
            Write-Host ("  [{0}] {1} 处" -f $_.Name, $_.Count)
            $_.Group | Select-Object -First 8 | ForEach-Object { Write-Host ("      {0}  {1}" -f $_.Where, $_.Detail) }
        }
    }
    if ($script:info.Count -gt 0) {
        Write-Host ''
        Write-Host '--- INFO ---' -ForegroundColor DarkGray
        $script:info | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    }

    if ($Json) {
        $report = [pscustomobject]@{
            root  = $Root
            block = $script:block
            warn  = $script:warn
            info  = $script:info
        }
        $report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Json -Encoding UTF8
        Write-Host ''
        Write-Host "JSON 报告：$Json" -ForegroundColor DarkGray
    }

    if ($script:block.Count -gt 0) { exit 1 } else { exit 0 }
}
finally {
    Pop-Location
}
