# install-python.ps1 — Downloads and silently installs Python on Windows.
# Usage: .\install-python.ps1 [-PythonVersion <version>]
# Falls back to DEFAULT_PYTHON_VERSION env var, then to '3.14.4'.

param(
    [Parameter(Mandatory = $false)]
    [string]$PythonVersion = ""
)

if (-not $PythonVersion) {
    $PythonVersion = if ($env:DEFAULT_PYTHON_VERSION) { $env:DEFAULT_PYTHON_VERSION } else { "3.14.4" }
}

$installerName = "python-$PythonVersion-amd64.exe"
$installerUrl  = "https://www.python.org/ftp/python/$PythonVersion/$installerName"
$installerPath = Join-Path $env:TEMP $installerName

Write-Host "Downloading Python $PythonVersion from $installerUrl..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

Write-Host "Installing Python $PythonVersion silently..."
$process = Start-Process -FilePath $installerPath `
    -ArgumentList "/quiet PrependPath=1 InstallPip=1" `
    -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Python $PythonVersion installation complete."
} else {
    Write-Error "Python $PythonVersion installation failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}
