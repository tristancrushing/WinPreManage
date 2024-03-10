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
# $backupPath = "C:\Backup\Browsers\History"
# $browserHistoryBackup = [BrowserHistoryBackup]::new($backupPath)
# $browserHistoryBackup.InvokeUserInteraction

#>
class BrowserHistoryBackup {
    [string]$BackupBasePath
    [string]$HistoryBackupPath

    BrowserHistoryBackup() {
        # Constructor no longer requires initial backup path
    }

    [void]SetupBackupPath([string]$backupBasePath) {
        $this.BackupBasePath = $backupBasePath
        $this.HistoryBackupPath = Join-Path -Path $this.BackupBasePath -ChildPath "History"
        # Ensure backup directory exists
        New-Item -ItemType Directory -Path $this.HistoryBackupPath -Force | Out-Null
    }

    [void]BackupIEAndEdgeLegacyHistory() {
        $ieHistoryPath = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\History"
        # IE and Edge Legacy use similar paths for history; adjust as necessary
        $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "IE_EdgeLegacy_History"
        Copy-Item -Path $ieHistoryPath -Destination $destPath -Recurse -Force
        Write-Host "IE/Edge Legacy history backed up successfully to $destPath."
    }

    [void]BackupEdgeChromiumHistory() {
        $edgeHistoryPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
        if (Test-Path $edgeHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "EdgeChromium_History"
            Copy-Item -Path $edgeHistoryPath -Destination $destPath -Force
            Write-Host "Edge (Chromium) history backed up successfully to $destPath."
        } else {
            Write-Host "Edge (Chromium) history file not found."
        }
    }

    [void]BackupFirefoxHistory() {
        $firefoxProfilePath = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory | Select-Object -First 1
        $firefoxHistoryPath = $firefoxProfilePath.FullName + "\places.sqlite"
        if (Test-Path $firefoxHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Firefox_History"
            Copy-Item -Path $firefoxHistoryPath -Destination $destPath -Force
            Write-Host "Firefox history backed up successfully to $destPath."
        } else {
            Write-Host "Firefox history database not found."
        }
    }

    [void]BackupOperaHistory() {
        $operaHistoryPath = "$env:APPDATA\Opera Software\Opera Stable\History"
        if (Test-Path $operaHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Opera_History"
            Copy-Item -Path $operaHistoryPath -Destination $destPath -Force
            Write-Host "Opera history backed up successfully to $destPath."
        } else {
            Write-Host "Opera history file not found."
        }
    }

    [void]BackupChromeHistory() {
        $chromeHistoryPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
        if (Test-Path $chromeHistoryPath) {
            $destPath = Join-Path -Path $this.HistoryBackupPath -ChildPath "Chrome_History.txt"
            Copy-Item -Path $chromeHistoryPath -Destination $destPath -Force
            Write-Host "Chrome history backed up successfully to $destPath."
        } else {
            Write-Host "Chrome history file not found."
        }
    }

    [void]InvokeUserInteraction() {
        Write-Host "Enter the backup path for browser history:"
        $backupPath = Read-Host
        if (-not [string]::IsNullOrWhiteSpace($backupPath)) {
            $this.SetupBackupPath($backupPath)
            $this.BackupBasePath = $backupPath
            $this.HistoryBackupPath = Join-Path -Path $this.BackupBasePath -ChildPath "History"
            New-Item -ItemType Directory -Path $this.HistoryBackupPath -Force | Out-Null

            Write-Host "Select browsers to backup history from:"
            Write-Host "1. Internet Explorer / Edge Legacy"
            Write-Host "2. Edge (Chromium)"
            Write-Host "3. Firefox"
            Write-Host "4. Opera"
            Write-Host "5. Chrome"
            $browserSelection = Read-Host "Enter the number (Separate multiple choices with commas, e.g., 1,3,5)"
        
            $browserSelection.Split(',') | ForEach-Object {
                switch ($_){
                    "1" { $this.BackupIEAndEdgeLegacyHistory() }
                    "2" { $this.BackupEdgeChromiumHistory() }
                    "3" { $this.BackupFirefoxHistory() }
                    "4" { $this.BackupOperaHistory() }
                    "5" { $this.BackupChromeHistory() }
                    default { Write-Host "Invalid selection." }
                 }
            }
        } else {
            Write-Host "Backup path is required to proceed."
        }
    }

}

# Uncomment the following lines to use the class with user interaction:
$backupUtility = [BrowserHistoryBackup]::new()
$backupUtility.InvokeUserInteraction()
