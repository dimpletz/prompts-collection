# find-chrome.ps1 — Locates the Google Chrome executable on Windows.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

$candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)

$chromePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($chromePath) {
    Write-Output "Chrome executable path: $chromePath"
    exit 0
} else {
    Write-Output "Google Chrome is not installed. None of the standard locations contain a Chrome executable."
    Write-Output "Download Chrome at: https://www.google.com/chrome/"
    exit 1
}
