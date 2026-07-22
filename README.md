# Windows 11 Optimization Script

This is a PowerShell script designed to debloat Windows 11, disable invasive telemetry, and optimize system performance. You only need to run this once—it makes permanent changes to your system settings. 

## What It Does
1. **Creates a System Restore Point** — Safely backs up your current configuration before making changes.
2. **Removes Bloatware** — Uninstalls pre-packaged junk apps (Solitaire, Zune, Bing News, etc.) for all users.
3. **Disables Telemetry (Registry)** — Stops Windows from sending diagnostic and usage data to Microsoft.
4. **Disables Telemetry (Tasks)** — Turns off hidden scheduled tasks that gather system data.
5. **Disables Non-Essential Services** — Frees up active RAM by stopping background services like SysMain and DiagTrack.
6. **Disables Game Bar & DVR** — Stops Xbox background recording to prevent system-wide micro-stutters.
7. **Optimizes Visual Effects** — Turns off heavy UI animations and window shadows for a snappier experience.
8. **Forces High Performance Power Plan** — Ensures your CPU doesn't downclock aggressively to save power.

## How to Run
You must run this script with Administrator privileges. 

1. Open PowerShell as Administrator.
2. Navigate to the directory where you saved the script.
3. Execute the script by bypassing the default execution policy:
   `Set-ExecutionPolicy Bypass -Scope Process -Force; .\WindowsOptimize.ps1`

## How to Recover
If the script breaks a dependency you have, or if you simply want to undo the changes, you can use the System Restore point it automatically created.

1. Press the Windows key, type **Create a restore point**, and hit **Enter**.
2. Click the **System Restore...** button.
3. Click **Next** and select the restore point named **Pre-Terminal-Debloat**.
4. Click **Next**, then **Finish** to reboot and restore your system to its previous state.


## Desktop shortcut

This repo includes `Windows Optimize.lnk` (Admin PowerShell launcher).

To recreate the shortcut after cloning (points at the script beside it, then copies/links to Desktop):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; .\create-desktop-shortcut.ps1
```
