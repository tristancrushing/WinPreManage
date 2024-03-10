<#
.SYNOPSIS
WinPreManage Browser History Backup Utility

.DESCRIPTION
This PowerShell class is an extension of the WinPreManage suite, specifically designed for backing up browser history from major web browsers including Internet Explorer, Microsoft Edge (both Legacy and Chromium-based), Firefox, Opera, and Google Chrome. Its primary objective is to ensure the comprehensive preservation of browser history during the transition to MSP management, thereby minimizing the risk of data loss.

The class provides a methodical approach to back up browser history data, supporting flexible backup operations tailored to each browser's specific history storage mechanism. It facilitates real-time progress feedback and employs error handling to ensure the backup process is robust and reliable.

.FEATURES
- Supports major browsers: IE, Edge (Legacy and Chromium), Firefox, Opera, and Chrome.
- User-defined backup path for storing browser history backups.
- Comprehensive backup of browser history data, focusing on user privacy and data integrity.
- Real-time feedback during the backup process for user awareness and monitoring.
- Customizable backup operations to cater to specific browser versions or user preferences.

.USAGE
Ideal for IT professionals, MSPs, and users needing to preserve browser history data before device or browser management transitions. This utility allows for a proactive approach to data protection, ensuring critical browsing information is securely backed up.

.REQUIREMENTS
- PowerShell Execution Policy must be set to RemoteSigned or less restrictive to run this script.
- Adequate permissions to access browser history data locations on the host system.
- Sufficient storage space on the destination drive or directory for the browser history backups.

.NOTES
Version: 0.1.1
Author: Tristan McGowan (tristan@ipspy.net)
Date: March 10, 2024

.EXAMPLE
$backupPath = "C:\Backup\Browsers\History"
$logsPath = "C:\Logs"
$browserHistoryBackup = [BrowserHistoryBackup]::new($backupPath, $logsPath)
$browserHistoryBackup.BackupIEAndEdgeLegacyHistory()
$browserHistoryBackup.BackupEdgeChromiumHistory()
$browserHistoryBackup.BackupFirefoxHistory()
$browserHistoryBackup.BackupOperaHistory()
$browserHistoryBackup.BackupChromeHistory()

This example demonstrates creating a new instance of the BrowserHistoryBackup class and invoking methods to back up browser history for supported browsers to a specified path.

#>
class BrowserHistoryBackup {
    [string]$BackupBasePath
    [string]$HistoryBackupPath

    BrowserHistoryBackup([string]$backupBasePath, [string]$logsPath) {
        Initialize-Logging -logsPath $logsPath

        $this.BackupBasePath = $backupBasePath
        $this.HistoryBackupPath = Join-Path -Path $this.BackupBasePath -ChildPath "History"
        # Ensure backup directory exists
        New-Item -ItemType Directory -Path $this.HistoryBackupPath -Force | Out-Null

        Log-Activity "Initialized BrowserHistoryBackup with backup path: $this.HistoryBackupPath"
    }

    [void]BackupIEAndEdgeLegacyHistory() {
        $ieHistoryPath = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\History"
        # IE and Edge Legacy use similar paths for history; adjust as necessary
        $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "IE_EdgeLegacy_History"
        Copy-Item -Path $ieHistoryPath -Destination $destPath -Recurse -Force
        Log-Activity "IE/Edge Legacy history backed up successfully to $destPath"
    }

    [void]BackupEdgeChromiumHistory() {
        $edgeHistoryPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
        if (Test-Path $edgeHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "EdgeChromium_History"
            Copy-Item -Path $edgeHistoryPath -Destination $destPath -Force
            Log-Activity "Edge (Chromium) history backed up successfully to $destPath"
        } else {
            Log-Error "Edge (Chromium) history file not found."
        }
    }

    [void]BackupFirefoxHistory() {
        $firefoxProfilePath = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory | Select-Object -First 1
        $firefoxHistoryPath = $firefoxProfilePath.FullName + "\places.sqlite"
        if (Test-Path $firefoxHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Firefox_History"
            Copy-Item -Path $firefoxHistoryPath -Destination $destPath -Force
            Log-Activity "Firefox history backed up successfully to $destPath"
        } else {
            Log-Error "Firefox history database not found."
        }
    }

    [void]BackupOperaHistory() {
        $operaHistoryPath = "$env:APPDATA\Opera Software\Opera Stable\History"
        if (Test-Path $operaHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Opera_History"
            Copy-Item -Path $operaHistoryPath -Destination $destPath -Force
            Log-Activity "Opera history backed up successfully to $destPath"
        } else {
            Log-Error "Opera history file not found."
        }
    }

    [void]BackupChromeHistory() {
        $chromeHistoryPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
        if (Test-Path $chromeHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Chrome_History"
            Copy-Item -Path $chromeHistoryPath -Destination $destPath -Force
            Log-Activity "Chrome history backed up successfully to $destPath"
        } else {
            Log-Error "Chrome history file not found."
        }
    }

    # Define global variables for log paths, initialized later
    $global:activityLogPath = $null
    $global:errorLogPath = $null

    Function Initialize-Logging {
        param (
            [string]$logsPath
        )
        $dateTimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $global:activityLogPath = Join-Path -Path $logsPath -ChildPath "BrowserHistoryBackup_Activity_$dateTimeStamp.log"
        $global:errorLogPath = Join-Path -Path $logsPath -ChildPath "BrowserHistoryBackup_Error_$dateTimeStamp.log"

        # Create log files
        New-Item -Path $global:activityLogPath -ItemType File -Force | Out-Null
        New-Item -Path $global:errorLogPath -ItemType File -Force | Out-Null
    }

    Function Log-Activity {
        param ([string]$Message)
        Add-Content -Path $global:activityLogPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $Message"
        Write-Host $Message
    }

    Function Log-Error {
        param ([string]$Message)
        Add-Content -Path $global:errorLogPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): ERROR: $Message"
        Write-Host $Message -ForegroundColor Red
    }
}
