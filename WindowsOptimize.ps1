<#
.SYNOPSIS
    Optimizes Windows 11 by removing bloatware, disabling telemetry, and improving performance.

.DESCRIPTION
    This script is designed to run after a fresh Windows 11 installation or after 
    major feature updates. It performs several main tasks:
    1. Creates a System Restore point for safety.
    2. Removes provisioned Appx packages (bloatware) for all users.
    3. Modifies the registry to disable Windows telemetry and Wi-Fi Sense.
    4. Disables scheduled tasks that report data back to Microsoft.
    5. Disables non-essential background services.
    6. Disables Game Bar and Game DVR.
    7. Optimizes visual effects for performance.
    8. Sets the High Performance power plan.

.NOTES
    Author: Nair Code Coding Partner & User
    Date: March 2026
    Requirements: Must be run in an Administrator PowerShell console.
    Execution: You may need to bypass the execution policy to run this:
               Set-ExecutionPolicy Bypass -Scope Process -Force

.EXAMPLE
    .\WindowsOptimize.ps1
#>

Write-Host "Starting Windows Optimization..." -ForegroundColor Cyan

# ==========================================
# STEP 1: Create a System Restore Point
# ==========================================
Write-Host "Creating restore point..."
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Pre-Terminal-Debloat" -RestorePointType "MODIFY_SETTINGS"

# ==========================================
# STEP 2: Remove Bloatware (AppxPackages)
# ==========================================
$bloatware = @(
    "*BingNews*",
    "*GetHelp*",
    "*Microsoft3DViewer*",
    "*MicrosoftOfficeHub*",
    "*SolitaireCollection*",
    "*YourPhone*",
    "*ZuneVideo*",
    "*ZuneMusic*"
)

foreach ($app in $bloatware) {
    Write-Host "Attempting to remove $app..."
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# ==========================================
# STEP 3: Disable Telemetry via Registry
# ==========================================
Write-Host "Disabling Telemetry in Registry..."

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
If (!(Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }
Set-ItemProperty -Path $registryPath -Name "AllowTelemetry" -Type DWord -Value 0

$wifiSensePath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $wifiSensePath)) { New-Item -Path $wifiSensePath -Force | Out-Null }
Set-ItemProperty -Path $wifiSensePath -Name "AutoConnectAllowedOEM" -Type DWord -Value 0

# ==========================================
# STEP 4: Disable Telemetry Scheduled Tasks
# ==========================================
Write-Host "Disabling Telemetry Scheduled Tasks..."

$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)

foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskPath (Split-Path $task) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue | Out-Null
}

# ==========================================
# STEP 5: Disable Non-Essential Services
# ==========================================
Write-Host "Disabling non-essential background services..." -ForegroundColor Cyan

$servicesToDisable = @(
    "SysMain",     
    "DiagTrack",   
    "WpcComputerTime" 
)

foreach ($service in $servicesToDisable) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and disabling service: $service"
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    } else {
        Write-Host "Service $service not found, skipping." -ForegroundColor DarkGray
    }
}

# ==========================================
# STEP 6: Disable Game Bar and Game DVR
# ==========================================
Write-Host "Disabling Game Bar and Game DVR..." -ForegroundColor Cyan

$gameConfigStore = "HKCU:\System\GameConfigStore"
If (!(Test-Path $gameConfigStore)) { New-Item -Path $gameConfigStore -Force | Out-Null }
Set-ItemProperty -Path $gameConfigStore -Name "GameDVR_Enabled" -Type DWord -Value 0

$gameDVRPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
If (!(Test-Path $gameDVRPolicy)) { New-Item -Path $gameDVRPolicy -Force | Out-Null }
Set-ItemProperty -Path $gameDVRPolicy -Name "AllowGameDVR" -Type DWord -Value 0

# ==========================================
# STEP 7: Optimize Visual Effects for Performance
# ==========================================
Write-Host "Optimizing Visual Effects..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 2

# ==========================================
# STEP 8: Set High Performance Power Plan
# ==========================================
Write-Host "Setting Power Plan to High Performance..." -ForegroundColor Cyan
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

Write-Host "Optimization Complete! You can close this window." -ForegroundColor Green