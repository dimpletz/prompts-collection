# find-brave.ps1 — Locates the Brave browser executable on Windows.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

$candidates = @(
    "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe",
    "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe",
    "$env:LocalAppData\BraveSoftware\Brave-Browser\Application\brave.exe"
)

$bravePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($bravePath) {
    Write-Output "Brave executable path: $bravePath"
    exit 0
} else {
    Write-Output "Brave is not installed. None of the standard locations contain a Brave executable."
    Write-Output "Download Brave at: https://brave.com/download"
    exit 1
}
