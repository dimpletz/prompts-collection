# split-diff.ps1 — Splits a large diff file into chunk files and oversized section files.
# Usage: split-diff.ps1 <diff-file> [<max-lines>] [<ignore-file>]
# Output (stdout):
#   WITHIN_LIMIT:<path>  — file is within the line limit; no output files created
#   CHUNK:<path>         — a chunk file was created
#   OVERSIZED:<path>     — a section exceeded the limit and was saved as a standalone file
#   IGNORED:<path>       — a section was excluded because its file path matched the ignore file

param(
    [Parameter(Mandatory = $true,  Position = 0)] [string] $DiffFile,
    [Parameter(Mandatory = $false, Position = 1)] [int]    $MaxLines = 500,
    [Parameter(Mandatory = $false, Position = 2)] [string] $IgnoreFile = ""
)

# ---------------------------------------------------------------------------
# Gitignore-style pattern matching helpers
# ---------------------------------------------------------------------------

function Test-GitignorePattern {
    param([string]$FilePath, [string]$Pattern)
    $fp  = $FilePath -replace '\\', '/'
    $pat = $Pattern.Trim()

    # Directory pattern (ends with /)
    if ($pat.EndsWith('/')) {
        $dir = $pat.TrimEnd('/')
        if ($fp -like "$dir/*" -or $fp -like "*/$dir/*") { return $true }
        return $false
    }

    # Rooted pattern (contains / somewhere other than start)
    if ($pat.Contains('/')) {
        $stripped = $pat.TrimStart('./').TrimStart('/')
        if ($fp -like $stripped -or $fp -like "$stripped/*") { return $true }
        return $false
    }

    # Unrooted pattern — match filename or any path component
    $fileName = [System.IO.Path]::GetFileName($fp)
    if ($fileName -like $pat) { return $true }
    foreach ($component in ($fp -split '/')) {
        if ($component -like $pat) { return $true }
    }
    return $false
}

function Test-ShouldIgnore {
    param([string]$FilePath, [string]$IgnoreFilePath)
    if ([string]::IsNullOrEmpty($IgnoreFilePath) -or -not (Test-Path -LiteralPath $IgnoreFilePath)) {
        return $false
    }
    foreach ($line in (Get-Content -LiteralPath $IgnoreFilePath)) {
        $pattern = $line.Trim()
        if ([string]::IsNullOrEmpty($pattern) -or $pattern.StartsWith('#')) { continue }
        if (Test-GitignorePattern -FilePath $FilePath -Pattern $pattern) { return $true }
    }
    return $false
}

# If no ignore file was specified, fall back to the sibling config/.ignore
if ([string]::IsNullOrEmpty($IgnoreFile)) {
    $defaultIgnore = Join-Path $PSScriptRoot "..\config\.ignore"
    if (Test-Path -LiteralPath $defaultIgnore) {
        $IgnoreFile = $defaultIgnore
    }
}

if (-not (Test-Path -LiteralPath $DiffFile)) {
    Write-Error "Error: file not found: $DiffFile"
    exit 1
}

$lines = Get-Content -LiteralPath $DiffFile
if ($null -eq $lines) { $lines = @() }
$totalLines = $lines.Count

if ($totalLines -le $MaxLines) {
    Write-Output "WITHIN_LIMIT:$DiffFile"
    exit 0
}

$dir      = Split-Path -Parent $DiffFile
$basename = Split-Path -Leaf $DiffFile
$base     = [System.IO.Path]::GetFileNameWithoutExtension($basename)

function Sanitize-Name([string]$s) {
    $s = $s -replace '[/.\\ ]', '-'
    $s = $s -replace '[^a-zA-Z0-9-]', ''
    $s = $s -replace '-{2,}', '-'
    return $s.Trim('-')
}

# Find section start indices (0-based) and file paths
$sectionStarts = [System.Collections.Generic.List[int]]::new()
$sectionPaths  = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^diff --git a/') {
        $sectionStarts.Add($i)
        if ($lines[$i] -match '^diff --git a/(.*) b/') {
            $sectionPaths.Add($Matches[1])
        } else {
            $sectionPaths.Add("unknown-section-$i")
        }
    }
}

if ($sectionStarts.Count -eq 0) {
    Write-Output "WITHIN_LIMIT:$DiffFile"
    exit 0
}

# Index of last preamble line (-1 means no preamble)
$preambleEnd = $sectionStarts[0] - 1

# Classify sections: ignored, oversized (> MaxLines), or eligible for chunking
$eligibleStarts = [System.Collections.Generic.List[int]]::new()
$eligibleEnds   = [System.Collections.Generic.List[int]]::new()

for ($s = 0; $s -lt $sectionStarts.Count; $s++) {
    $secStart = $sectionStarts[$s]
    $secEnd   = if ($s + 1 -lt $sectionStarts.Count) { $sectionStarts[$s + 1] - 1 } else { $totalLines - 1 }
    $secLines = $secEnd - $secStart + 1

    if (Test-ShouldIgnore -FilePath $sectionPaths[$s] -IgnoreFilePath $IgnoreFile) {
        Write-Output "IGNORED:$($sectionPaths[$s])"
        continue
    }

    if ($secLines -gt $MaxLines) {
        $sanitized = Sanitize-Name $sectionPaths[$s]
        $outFile   = Join-Path $dir "${base}-${MaxLines}-${sanitized}.diff"
        $content   = [System.Collections.Generic.List[string]]::new()
        if ($preambleEnd -ge 0) { $content.AddRange([string[]]@($lines[0..$preambleEnd])) }
        $content.AddRange([string[]]@($lines[$secStart..$secEnd]))
        [System.IO.File]::WriteAllLines($outFile, $content)
        Write-Output "OVERSIZED:$outFile"
    } else {
        $eligibleStarts.Add($secStart)
        $eligibleEnds.Add($secEnd)
    }
}

# Greedily pack eligible sections into chunks
$chunkNum     = 1
$chunkLines   = 0
$chunkContent = [System.Collections.Generic.List[string]]::new()

for ($e = 0; $e -lt $eligibleStarts.Count; $e++) {
    $secStart = $eligibleStarts[$e]
    $secEnd   = $eligibleEnds[$e]
    $secLines = $secEnd - $secStart + 1

    if ($chunkLines -gt 0 -and ($chunkLines + $secLines) -gt $MaxLines) {
        $outFile = Join-Path $dir "${base}-${MaxLines}-chunk-${chunkNum}.diff"
        $content = [System.Collections.Generic.List[string]]::new()
        if ($preambleEnd -ge 0) { $content.AddRange([string[]]@($lines[0..$preambleEnd])) }
        $content.AddRange($chunkContent)
        [System.IO.File]::WriteAllLines($outFile, $content)
        Write-Output "CHUNK:$outFile"
        $chunkNum++
        $chunkContent = [System.Collections.Generic.List[string]]::new()
        $chunkLines   = 0
    }

    $chunkContent.AddRange([string[]]@($lines[$secStart..$secEnd]))
    $chunkLines += $secLines
}

if ($chunkLines -gt 0) {
    $outFile = Join-Path $dir "${base}-${MaxLines}-chunk-${chunkNum}.diff"
    $content = [System.Collections.Generic.List[string]]::new()
    if ($preambleEnd -ge 0) { $content.AddRange([string[]]@($lines[0..$preambleEnd])) }
    $content.AddRange($chunkContent)
    [System.IO.File]::WriteAllLines($outFile, $content)
    Write-Output "CHUNK:$outFile"
}
