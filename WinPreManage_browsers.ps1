<#
.SYNOPSIS
WinPreManage Browser Data Backup Utility

.DESCRIPTION
This PowerShell script backs up bookmarks and optionally downloads for selected browsers including IE, Edge, Firefox, Opera, and Chrome. Designed for MSP pre-management phase, ensuring crucial web browser data preservation.

.NOTES
Version: 0.1.0
Author: Tristan McGowan (tristan@ipspy.net)
Date: March 5, 2024
#>

# User selection for browsers to backup
Write-Host "Select browsers to backup data from:"
Write-Host "1. Internet Explorer / Edge Legacy"
Write-Host "2. Microsoft Edge (Chromium)"
Write-Host "3. Firefox"
Write-Host "4. Opera"
Write-Host "5. Google Chrome"
Write-Host "6. (All of the above.)"
Write-Host "Enter numbers separated by commas (e.g., 1,2,5):"
$browsersToBackup = Read-Host 

# Convert selection to array and remove spaces
$browsersToBackupArray = $browsersToBackup -split ',' | ForEach-Object { $_.Trim() }

# User selection for backup type
$backupOption = Read-Host "Do you want to backup (1) Bookmarks only, (2) Both Bookmarks and Downloads? Enter 1 or 2"
if ($backupOption -ne "1" -and $backupOption -ne "2") {
    Write-Host "Invalid selection. Defaulting to Bookmarks only."
    $backupOption = "1"
}

# Define backup paths
$backupBasePath = Read-Host "Enter the letter of the destination drive followed by Backup folder path (e.g., G:\Backup\Browsers\)"
$bookmarksBackupPath = Join-Path -Path $backupBasePath -ChildPath "Bookmarks"
$downloadsBackupPath = Join-Path -Path $backupBasePath -ChildPath "Downloads"

# Ensure backup directories exist
New-Item -ItemType Directory -Path $bookmarksBackupPath -Force | Out-Null
if ($backupOption -eq "2") {
    New-Item -ItemType Directory -Path $downloadsBackupPath -Force | Out-Null
}

# Internet Explorer / Edge (Legacy)
function Backup-IEAndEdgeLegacyData {
    $ieFavoritesPath = "$env:USERPROFILE\Favorites"
    $ieDownloadsPath = "$env:USERPROFILE\Downloads" # IE and Edge legacy use the system Downloads folder

    Copy-Item -Path $ieFavoritesPath\* -Destination $bookmarksBackupPath -Recurse -Force
    Write-Host "IE/Edge Legacy favorites backed up successfully."

    if ($backupOption -eq "2") {
        Copy-Item -Path $ieDownloadsPath\* -Destination $downloadsBackupPath -Recurse -Force
        Write-Host "IE/Edge Legacy downloads backed up successfully."
    }
}

# Microsoft Edge (Chromium-based)
function Backup-EdgeChromiumData {
    $edgeBookmarksPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

    if (Test-Path $edgeBookmarksPath) {
        Copy-Item -Path $edgeBookmarksPath -Destination $bookmarksBackupPath -Force
        Write-Host "Edge (Chromium) bookmarks backed up successfully."
    } else {
        Write-Host "Edge (Chromium) bookmarks file not found."
    }
    # Note: Downloads metadata is not directly backed up as it's part of browser history in Edge (Chromium)
}

# Firefox
function Backup-FirefoxData {
    $firefoxProfilePath = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory | Select-Object -First 1
    $firefoxBookmarksPath = $firefoxProfilePath.FullName + "\places.sqlite"

    if (Test-Path $firefoxBookmarksPath) {
        Copy-Item -Path $firefoxBookmarksPath -Destination $bookmarksBackupPath -Force
        Write-Host "Firefox bookmarks database backed up successfully."
    } else {
        Write-Host "Firefox bookmarks database not found."
    }
    # Note: Downloads are tracked in the same places.sqlite database
}

# Opera
function Backup-OperaData {
    $operaBookmarksPath = "$env:APPDATA\Opera Software\Opera Stable\Bookmarks"

    if (Test-Path $operaBookmarksPath) {
        Copy-Item -Path $operaBookmarksPath -Destination $bookmarksBackupPath -Force
        Write-Host "Opera bookmarks backed up successfully."
    } else {
        Write-Host "Opera bookmarks file not found."
    }
    # Note: Opera uses the system Downloads folder by default
}

# Google Chrome
function Backup-ChromeData {
    $chromeBookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"

    if (Test-Path $chromeBookmarksPath) {
        Copy-Item -Path $chromeBookmarksPath -Destination $bookmarksBackupPath -Force
        Write-Host "Chrome bookmarks backed up successfully."
    } else {
        Write-Host "Chrome bookmarks file not found."
    }
    # Note: Chrome uses the system Downloads folder by default
}

# Main execution function
function Backup-BrowserData {
    Write-Host "Starting browser data backup..."
    
    Backup-IEAndEdgeLegacyData
    Backup-EdgeChromiumData
    Backup-FirefoxData
    Backup-OperaData
    Backup-ChromeData

    Write-Host "Browser data backup completed."
}

# Execute
Backup-BrowserData


# Main execution function
function Backup-BrowserData {
    Write-Host "Starting browser data backup..."
    
    if ($browsersToBackupArray -contains "1") {
        Write-Host "Starting browser data backup for IE browser..."
        
        Backup-IEAndEdgeLegacyData

        Write-Host "Browser data backup for IE completed."
    }
    if ($browsersToBackupArray -contains "2") {
        Write-Host "Starting browser data backup for Edge browser..."
        
        Backup-EdgeChromiumData

        Write-Host "Browser data backup for Edge completed."
    }
    if ($browsersToBackupArray -contains "3") {
        Write-Host "Starting browser data backup for Firefox browser..."
        
        Backup-FirefoxData

        Write-Host "Browser data backup for Firefox completed."
    }
    if ($browsersToBackupArray -contains "4") {
        Write-Host "Starting browser data backup for Opera browser..."
    
        Backup-OperaData

        Write-Host "Browser data backup for Opera completed."
    }
    if ($browsersToBackupArray -contains "5") {
        Write-Host "Starting browser data backup for Chrome browser..."
    
        Backup-ChromeData
        
        Write-Host "Browser data backup for Chrome completed."
    }

    if ($browsersToBackupArray -contains "6") {
        Write-Host "Starting browser data backup for all found browsers..."
    
        Backup-IEAndEdgeLegacyData
        Backup-EdgeChromiumData
        Backup-FirefoxData
        Backup-OperaData
        Backup-ChromeData
    
        Write-Host "Browser data backup for all found browsers completed."
    }

    Write-Host "Browser data backup completed."
}

# Execute
Backup-BrowserData
