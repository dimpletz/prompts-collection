# find-firefox.ps1 — Locates the Mozilla Firefox executable on Windows.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

$candidates = @(
    "$env:ProgramFiles\Mozilla Firefox\firefox.exe",
    "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe",
    "$env:LocalAppData\Mozilla Firefox\firefox.exe"
)

$firefoxPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($firefoxPath) {
    Write-Output "Firefox executable path: $firefoxPath"
    exit 0
} else {
    Write-Output "Mozilla Firefox is not installed. None of the standard locations contain a Firefox executable."
    Write-Output "Download Firefox at: https://www.mozilla.org/firefox"
    exit 1
}
