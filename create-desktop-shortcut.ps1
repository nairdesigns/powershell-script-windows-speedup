<#
.SYNOPSIS
  Creates a Desktop shortcut that runs WindowsOptimize.ps1 as Administrator.
#>
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $scriptDir 'WindowsOptimize.ps1'
if (-not (Test-Path $script)) {
  throw "WindowsOptimize.ps1 not found next to this script: $script"
}

$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop 'Windows Optimize.lnk'

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($lnkPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$Shortcut.WorkingDirectory = $scriptDir
$Shortcut.WindowStyle = 1
$Shortcut.Description = 'Run WindowsOptimize.ps1'
$Shortcut.IconLocation = 'powershell.exe,0'
$Shortcut.Save()

# Run as administrator
$bytes = [System.IO.File]::ReadAllBytes($lnkPath)
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($lnkPath, $bytes)

Write-Host "Created: $lnkPath" -ForegroundColor Green
