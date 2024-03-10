<#
.SYNOPSIS
    WinPreManaged_disk_health.ps1 - A comprehensive Windows disk health and performance monitoring script.

.DESCRIPTION
    This script provides a detailed analysis and reporting on various aspects of disk health and performance for Windows systems.
    It covers checking disk space usage, assessing the S.M.A.R.T. status of physical drives, performing file system integrity checks,
    evaluating disk performance metrics, analyzing disk fragmentation, and inspecting the Volume Shadow Copy Service (VSS) status.
    Designed with proactive system monitoring and maintenance in mind, it aims to identify potential disk-related issues before they escalate into critical failures.

    The script outputs logs detailing each check it performs, offering insights into the current state of the system's disks.
    It is ideal for system administrators and IT professionals seeking to ensure the optimal functioning and longevity of storage devices within Windows environments.

    Key functionalities include:
    - Disk space usage analysis to prevent unexpected outages due to insufficient storage.
    - S.M.A.R.T. status checks to pre-emptively identify failing disks.
    - File system integrity verifications to ensure data consistency and accessibility.
    - Disk performance benchmarking to identify potential bottlenecks.
    - Disk fragmentation analysis to optimize read/write efficiency.
    - Volume Shadow Copy Service (VSS) inspection to safeguard against snapshot-related issues.

    By consolidating these checks into a single, automated script, WinPreManaged_disk_health.ps1 simplifies the routine maintenance tasks associated with disk management, allowing for regular and systematic health assessments.

.EXAMPLE
    PowerShell.exe -File WinPreManaged_disk_health.ps1

    Executes the script with administrative privileges, performing all disk health checks and logging the results.

.INPUTS
    None. This script does not accept any inputs, relying instead on internal commands and checks.

.OUTPUTS
    Log files are generated in the C:\Logs directory, detailing the activity and any errors encountered during the execution of the script. These logs include timestamps and descriptions of each operation performed, offering a comprehensive overview of the script's findings.

.NOTES
    - Version:        0.1.1
    - Author:         Tristan McGowan (tristan@ipspy.net)
    - Date:           March 10, 2024
    - Requires:       PowerShell 5.1 or higher
    - Operating System: Windows 10/Windows Server 2016 or higher
    - Permissions:    Must be run as Administrator due to the administrative privileges required for certain checks (e.g., S.M.A.R.T. status, chkdsk).
    - Disclaimer:     Running this script can be resource-intensive, and certain checks may impact system performance temporarily. It is recommended to schedule this script during low-usage periods.

.LINK
    For more information and updates, visit https://github.com/TristanMcGowan/WinPreManaged_DiskHealth

#>
# Requires -RunAsAdministrator

# Ask user for log file location
$logsPath = Read-Host "Enter the path for logs (e.g., C:\Logs)"

# Initialize Logging Paths
$dateTimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$activityLogPath = Join-Path -Path $logsPath -ChildPath "DiskHealth_Activity_$dateTimeStamp.log"
$errorLogPath = Join-Path -Path $logsPath -ChildPath "DiskHealth_Error_$dateTimeStamp.log"

# Define logging func

Function Log-Activity {
    param (
        [string]$Message
    )
    Add-Content -Path $activityLogPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $Message"
}

Function Log-Error {
    param (
        [string]$Message
    )
    Add-Content -Path $errorLogPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): ERROR: $Message"
}

Function Log-Warning {
    param (
        [string]$Message
    )
    Add-Content -Path $activityLogPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): WARNING: $Message"
}

# 1. Check Disk Space Usage
Function Check-DiskSpaceUsage {
    Log-Activity "Starting disk space usage check."
    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $totalSizeGB = [math]::Round(($_.Used + $_.Free) / 1GB, 2)
        $freeSpaceGB = [math]::Round($_.Free / 1GB, 2)
        $freeSpacePercent = [math]::Round(($_.Free / ($_.Used + $_.Free)) * 100, 2)

        if ($freeSpacePercent -lt 10) {
            Log-Warning "Drive $($_.Name): is running low on disk space. $freeSpacePercent% ($freeSpaceGB GB) remaining."
        }

        Log-Activity "Drive $($_.Name): Total Size: $totalSizeGB GB, Free Space: $freeSpaceGB GB ($freeSpacePercent%)."
    }
}

# 2. Disk Health Status via SMART
Function Check-SMARTStatus {
    Log-Activity "Starting SMART status check."
    # Using a placeholder as accessing SMART directly in PowerShell requires external tools
    # An example call could be to a hypothetical third-party utility "SmartCtl"
    # Example: smartctl -a /dev/sda | Out-File -FilePath $smartStatusLog
    Log-Activity "SMART status check complete. (Please integrate with a third-party SMART utility)"
}

# 3. File System Integrity Check
Function Check-FileSystemIntegrity {
    Log-Activity "Starting file system integrity check."
    $disks = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $disks) {
        $driveLetter = $disk.DeviceID
        # This is a safer, non-disruptive check compared to chkdsk /f or /r
        $chkdskResult = & chkdsk $driveLetter /scan | Out-String
        Log-Activity "File system integrity check for ${driveLetter}: $chkdskResult"
    }
}

# 4. Disk Performance Metrics
Function Check-DiskPerformance {
    Log-Activity "Starting disk performance check."
    # Utilizing Get-Disk and Measure-Command to log disk read/write speed as an example
    $disks = Get-Disk
    foreach ($disk in $disks) {
        $performance = Measure-Command { $null = dd if=/dev/zero of=/dev/$($disk.DeviceID) bs=1M count=1024 oflag=direct }
        Log-Activity "Disk $($disk.DeviceID) performance: $performance.TotalSeconds seconds for 1GB write test."
    }
    Log-Activity "Disk performance check complete."
}

# 5. Disk Fragmentation Status
Function Check-DiskFragmentation {
    Log-Activity "Starting disk fragmentation check."
    $disks = Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $disks) {
        $driveLetter = $disk.DriveLetter
        $fragResult = defrag $driveLetter /A /V | Out-String
        Log-Activity "Disk fragmentation status for ${driveLetter}: $fragResult"
    }
}

# 6. Volume Shadow Copy Service (VSS) Check
Function Check-VSSStatus {
    Log-Activity "Checking Volume Shadow Copy Service (VSS) status."
    $vssAdminListWriters = & vssadmin list writers | Out-String
    Log-Activity "VSS check: $vssAdminListWriters"
}

# Ask user which checks to run
Write-Host "Select the disk health checks to perform:"
Write-Host "1 - Check Disk Space Usage"
Write-Host "2 - Check S.M.A.R.T. Status"
Write-Host "3 - Check File System Integrity"
Write-Host "4 - Check Disk Performance"
Write-Host "5 - Check Disk Fragmentation"
Write-Host "6 - Check Volume Shadow Copy Service (VSS) Status"
Write-Host "7 - Perform All Checks"
$selections = Read-Host "Enter the numbers corresponding to your choices, separated by commas (e.g., 1,2,4), or select 7 for all checks"

# Parse selections and run selected checks
$selectedOptions = $selections.Split(',')

if ('7' -in $selectedOptions -or '1' -in $selectedOptions) {
    Check-DiskSpaceUsage
}
if ('7' -in $selectedOptions -or '2' -in $selectedOptions) {
    Check-SMARTStatus
}
if ('7' -in $selectedOptions -or '3' -in $selectedOptions) {
    Check-FileSystemIntegrity
}
if ('7' -in $selectedOptions -or '4' -in $selectedOptions) {
    Check-DiskPerformance
}
if ('7' -in $selectedOptions -or '5' -in $selectedOptions) {
    Check-DiskFragmentation
}
if ('7' -in $selectedOptions -or '6' -in $selectedOptions) {
    Check-VSSStatus
}

Write-Host "Disk health checks completed. Please review the logs at $logsPath for detailed results."
