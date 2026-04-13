# find-edge.ps1 — Locates the Microsoft Edge executable on Windows.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

$candidates = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:LocalAppData\Microsoft\Edge\Application\msedge.exe"
)

$edgePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($edgePath) {
    Write-Output "Edge executable path: $edgePath"
    exit 0
} else {
    Write-Output "Microsoft Edge is not installed. None of the standard locations contain an Edge executable."
    Write-Output "Download Edge at: https://www.microsoft.com/edge"
    exit 1
}
