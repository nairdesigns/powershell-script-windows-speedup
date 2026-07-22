<#
.SYNOPSIS
  Creates a Desktop shortcut for the one-time WindowsOptimize.ps1 debloat script.
#>
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $scriptDir 'WindowsOptimize.ps1'
if (-not (Test-Path $script)) {
  throw "WindowsOptimize.ps1 not found next to this script: $script"
}

$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop 'Windows Debloat (One-time).lnk'

# Remove old name if present
$old = Join-Path $desktop 'Windows Optimize.lnk'
if (Test-Path $old) { Remove-Item $old -Force }

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($lnkPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$Shortcut.WorkingDirectory = $scriptDir
$Shortcut.WindowStyle = 1
$Shortcut.Description = 'One-time Windows 11 debloat and optimize (not a background service)'
$Shortcut.IconLocation = 'powershell.exe,0'
$Shortcut.Save()

$bytes = [System.IO.File]::ReadAllBytes($lnkPath)
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($lnkPath, $bytes)

Write-Host "Created: $lnkPath" -ForegroundColor Green
Write-Host "Note: this is a one-shot script, not a background watcher." -ForegroundColor Yellow
