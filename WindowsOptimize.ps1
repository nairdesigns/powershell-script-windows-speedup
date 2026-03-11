<#
.SYNOPSIS
    Optimizes Windows 11 by removing bloatware and disabling telemetry.

.DESCRIPTION
    This script is designed to run after a fresh Windows 11 installation or after 
    major feature updates. It performs four main tasks:
    1. Creates a System Restore point for safety.
    2. Removes provisioned Appx packages (bloatware) for all users.
    3. Modifies the registry to disable Windows telemetry and Wi-Fi Sense.
    4. Disables scheduled tasks that report data back to Microsoft.

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
# Rationale: Always create a backup before modifying registry or system packages.
# This allows us to easily revert if an update breaks dependencies.
Write-Host "Creating restore point..."
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Pre-Terminal-Debloat" -RestorePointType "MODIFY_SETTINGS"

# ==========================================
# STEP 2: Remove Bloatware (AppxPackages)
# ==========================================
# The $bloatware array holds wildcard strings matching the names of apps we don't want.
# You can safely add or remove names from this list as your needs change.
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

# Loop through each item in the array to remove it.
foreach ($app in $bloatware) {
    Write-Host "Attempting to remove $app..."
    
    # Remove from current users. 
    # -ErrorAction SilentlyContinue hides red errors if the app is already uninstalled.
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    
    # Remove from the Windows image so it doesn't reinstall for new users.
    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# ==========================================
# STEP 3: Disable Telemetry via Registry
# ==========================================
# Rationale: Windows Settings UI hides the master switch for telemetry.
# We must edit the registry to force data collection to 0 (Off).
Write-Host "Disabling Telemetry in Registry..."

# Target path for main Windows Data Collection
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
If (!(Test-Path $registryPath)) { New-Item -Path $registryPath -Force | Out-Null }
Set-ItemProperty -Path $registryPath -Name "AllowTelemetry" -Type DWord -Value 0

# Target path for Wi-Fi Sense (Stops auto-sharing network credentials)
$wifiSensePath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $wifiSensePath)) { New-Item -Path $wifiSensePath -Force | Out-Null }
Set-ItemProperty -Path $wifiSensePath -Name "AutoConnectAllowedOEM" -Type DWord -Value 0

# ==========================================
# STEP 4: Disable Telemetry Scheduled Tasks
# ==========================================
# Rationale: Microsoft runs hidden tasks in Task Scheduler to gather system data.
Write-Host "Disabling Telemetry Scheduled Tasks..."

# Array containing the exact folder paths and names of the telemetry tasks.
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)

# Loop through and disable each task.
foreach ($task in $tasks) {
    # Split-Path extracts just the folder path, and -Leaf extracts just the task name.
    Disable-ScheduledTask -TaskPath (Split-Path $task) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "Optimization Complete! You can close this window." -ForegroundColor Green	

# ==========================================
# STEP 5: Disable Non-Essential Services
# ==========================================
# Rationale: Windows runs many background services by default. 
# Disabling these safely frees up active RAM usage.

Write-Host "Disabling non-essential background services..." -ForegroundColor Cyan

# Array of services that are generally safe to disable to save RAM.
$servicesToDisable = @(
    "SysMain",     # Pre-loads apps into RAM. Safe to disable on SSDs.
    "DiagTrack",   # Connected User Experiences and Telemetry.
    "WpcComputerTime" # Family Safety monitoring.
)

foreach ($service in $servicesToDisable) {
    # Check if the service exists on the system first
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and disabling service: $service"
        
        # Stop the service immediately so it clears out of RAM
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        
        # Set the startup type to Disabled so it doesn't boot up next restart
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    } else {
        Write-Host "Service $service not found, skipping." -ForegroundColor DarkGray
    }
}