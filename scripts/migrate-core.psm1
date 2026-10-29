# migrate-core.psm1 — 迁移工具共享内核
#
# 提供：哈希、只读快照（用于证明"我没写你的库"）、路径判断、UTF-8 写入、通配匹配。
# 被 migrate-v0.3-to-v1.0.ps1 与 upgrade.ps1 共用。
#
# 约束：本模块**不包含任何写用户 Vault 的函数**。

Set-StrictMode -Version 2.0

function Get-FileSha256 {
    param([Parameter(Mandatory)][string]$Path)
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -eq 0) { return 'EMPTY' }
    if ($item.Length -le 2MB) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLower()
    }
    # 大文件：首尾各 1MB，够检测变化且快
    $fs = [IO.File]::OpenRead($Path)
    try {
        $buf = New-Object byte[] (1MB)
        [void]$fs.Read($buf, 0, 1MB)
        $sha = [Security.Cryptography.SHA256]::Create()
        $head = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        $fs.Seek(-1MB, [IO.SeekOrigin]::End) | Out-Null
        [void]$fs.Read($buf, 0, 1MB)
        $tail = [BitConverter]::ToString($sha.ComputeHash($buf)).Replace('-','').ToLower()
        return "head:$($head.Substring(0,16))|tail:$($tail.Substring(0,16))|len:$($item.Length)"
    } finally { $fs.Dispose() }
}

function New-VaultSnapshot {
    <#
      只读快照：路径 → "长度|修改时间|哈希"。用于在扫描前后各算一次，证明未改动目标。
    #>
    param(
        [Parameter(Mandatory)][string]$Root,
        [string[]]$ExcludeDirs = @('.git')
    )
    $rootFull = (Resolve-Path -LiteralPath $Root).Path
    $snap = @{}
    Get-ChildItem -LiteralPath $rootFull -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $rel = $_.FullName.Substring($rootFull.Length + 1)
            $skip = $false
            foreach ($d in $ExcludeDirs) { if ($rel -like "$d\*" -or $rel -like "$d/*") { $skip = $true } }
            -not $skip
        } |
        ForEach-Object {
            $rel = $_.FullName.Substring($rootFull.Length + 1).Replace('\','/')
            $snap[$rel] = ('{0}|{1}|{2}' -f $_.Length, $_.LastWriteTimeUtc.Ticks, (Get-FileSha256 $_.FullName))
        }
    return $snap
}

function Compare-VaultSnapshot {
    <#
      比较两次快照，返回差异列表（Added / Removed / Changed）。空数组 = 完全没变。
    #>
    param(
        [Parameter(Mandatory)][hashtable]$Before,
        [Parameter(Mandatory)][hashtable]$After
    )
    $diff = New-Object System.Collections.ArrayList
    foreach ($k in $After.Keys) {
        if (-not $Before.ContainsKey($k)) { [void]$diff.Add([pscustomobject]@{ Kind='Added'; Path=$k; Detail='' }) }
        elseif ($Before[$k] -ne $After[$k]) { [void]$diff.Add([pscustomobject]@{ Kind='Changed'; Path=$k; Detail="$($Before[$k]) -> $($After[$k])" }) }
    }
    foreach ($k in $Before.Keys) {
        if (-not $After.ContainsKey($k)) { [void]$diff.Add([pscustomobject]@{ Kind='Removed'; Path=$k; Detail='' }) }
    }
    return $diff
}

function Test-Within {
    <# 判断 Child 是否位于 Parent 之内（用于拒绝把输出目录放进被扫描的 Vault） #>
    param([string]$Child, [string]$Parent)
    $c = (Resolve-Path -LiteralPath $Child -ErrorAction SilentlyContinue)
    if (-not $c) { $c = $Child }
    else { $c = $c.Path }
    $p = (Resolve-Path -LiteralPath $Parent).Path
    return $c.StartsWith($p, [StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-GlobRegex {
    <# 把 glob（* / **）转成正则。* 不跨目录，** 跨目录。 #>
    param([Parameter(Mandatory)][string]$Pattern)
    $rx = [regex]::Escape($Pattern.Replace('\','/'))
    $rx = $rx.Replace('\*\*','§DOUBLE§').Replace('\*','[^/]*').Replace('§DOUBLE§','.*')
    return '^' + $rx + '$'
}

function Test-Glob {
    param([string]$Path, [string]$Pattern)
    return ($Path.Replace('\','/') -match (ConvertTo-GlobRegex $Pattern))
}

function Write-Utf8File {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Content)
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [IO.File]::WriteAllText($Path, $Content, (New-Object Text.UTF8Encoding($false)))
}

Export-ModuleMember -Function Get-FileSha256, New-VaultSnapshot, Compare-VaultSnapshot, Test-Within, ConvertTo-GlobRegex, Test-Glob, Write-Utf8File
