<#
.SYNOPSIS
WinPreManage Backup Utility

.DESCRIPTION
This PowerShell script is part of the WinPreManage suite, designed to facilitate the backup of selected types of documents, images, and videos from a Windows device before management by a Managed Service Provider (MSP). Its primary goal is to ensure the preservation of critical user data during the transition to MSP management, minimizing the risk of data loss.

The utility prompts the user for input to define source and destination drives, along with a path for logging activities and errors. It employs a methodical approach to back up files by specified types, providing real-time feedback, progress updates, and comprehensive logging. Unique log files for activities and errors are generated for each backup session, aiding in troubleshooting and record-keeping.

.FEATURES
- User-defined source and destination paths for flexible backup operations.
- Support for multiple file types, focusing on documents, images, and videos.
- Progress feedback directly in the console for real-time monitoring.
- Comprehensive logging of all backup activities and encountered errors.
- Error handling to ensure the backup process continues even when individual files fail to copy.
- Customizable for incremental backups, compression, and other enhancements.

.USAGE
Suitable for IT professionals, MSPs, and technically inclined users looking to secure data before device management transitions. It offers a proactive approach to data protection, ensuring valuable information is safely backed up.

.REQUIREMENTS
- PowerShell Execution Policy must be set to RemoteSigned or less restrictive to run this script.
- Adequate permissions to access and write to the source and destination drives.
- Sufficient storage space on the destination drive for the backup data.

.NOTES
Version: 0.1.1
Author: Tristan McGowan (tristan@ipspy.net)
Date: March 5, 2024

#>
# PowerShell script to backup selected types of documents, images, and videos on a GNS pre-managed computer,
# with progress feedback and logging, including a separate error log.
Set-ExecutionPolicy RemoteSigned # Important Must Be Set

# Prompt for source, destination, and logs path
$sourceDrive = Read-Host "Enter the letter of the source drive (e.g., C:\)"
$destDrive = Read-Host "Enter the letter of the destination drive followed by Backup folder path (e.g., G:\Backup\)"
$logsPath = Read-Host "Enter the path for logs (e.g., G:\Logs\)"

# Generate log file names
$randomHash = Get-Random -Minimum 100000 -Maximum 999999
$dateTimeUTC = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
$activityLogFileName = "$randomHash" + "_" + $dateTimeUTC + "-WPMng-BKUP-Activity.txt"
$errorLogFileName = "$randomHash" + "_" + $dateTimeUTC + "-WPMng-BKUP-Error.txt"
$activityLogFilePath = Join-Path -Path $logsPath -ChildPath $activityLogFileName
$errorLogFilePath = Join-Path -Path $logsPath -ChildPath $errorLogFileName

# Function to backup files by type and log the activity
function Backup-FilesByType {
    param (
        [string]$sourceDrive,
        [string]$destDrive,
        [string[]]$fileTypes,
        [string]$activityLogFilePath,
        [string]$errorLogFilePath
    )

    foreach ($type in $fileTypes) {
        $files = Get-ChildItem -Path $sourceDrive -Recurse -Filter *.$type -ErrorAction SilentlyContinue
        $totalFiles = $files.Count
        $currentFileNumber = 0
        foreach ($file in $files) {
            $currentFileNumber++
            # Calculate relative path and destination path
            $relativePath = $file.FullName.Substring($sourceDrive.Length)
            $destPath = Join-Path -Path $destDrive -ChildPath $relativePath

            # Ensure the destination directory exists
            $destDir = [System.IO.Path]::GetDirectoryName($destPath)
            if (-not (Test-Path -Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }

            Write-Host "Processing ($currentFileNumber of $totalFiles): $($file.FullName) to $destPath"
            try {
                Copy-Item -Path $file.FullName -Destination $destPath -Force

                # Log the file copy action to the activity log and terminal
                $timestampUTC = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
                $timestampLocal = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                $logMessage = "[$timestampUTC UTC] / [$timestampLocal LOCAL] - Copied: $($file.FullName) to $destPath"
                Add-Content -Path $activityLogFilePath -Value $logMessage
                Write-Host $logMessage
            } catch {
                $errorMessage = "Error copying $($file.FullName) to ${destPath}: $($_.Exception.Message)"
                Add-Content -Path $errorLogFilePath -Value $errorMessage
                Write-Host $errorMessage
            }
        }
    }
}


# Map document types
$oldOfficeDocs = @("doc", "xls", "ppt")
$newOfficeDocs = @("docx", "xlsx", "pptx")
$pdfDocs = @("pdf")
$imageFiles = @("jpg", "jpeg", "png", "webp", "bmp")
$videoFiles = @("mp4", "avi", "mov", "wmv", "flv", "mkv", "webm", "mpeg")
$soundFiles = @("mp3", "wav", "ogg", "flac", "aac", "m4a", "wma")

# Prompt for types of documents to backup
Write-Host "Select the types of documents to backup:"
Write-Host "1 - Old Microsoft Office Documents (.doc, .xls, .ppt)"
Write-Host "2 - New Microsoft Office Documents (.docx, .xlsx, .pptx)"
Write-Host "3 - PDF Documents (.pdf)"
Write-Host "4 - Image Files (.jpg, .jpeg, .png, .webp, .bmp)"
Write-Host "5 - Video Files (.mp4, .avi, .mov, .wmv, .flv, .mkv, .webm, .mpeg)"
Write-Host "6 - Video Files (.mp3, .wav, .ogg, .flac, .aac, .m4a, .wma)"
Write-Host "7 - Everything (All the above)"
$selections = Read-Host "Enter the numbers corresponding to your choices, separated by commas (e.g., 1,2,4), or select 5 for everything"

# Parse selections
$selectedTypes = @()
if ($selections -match "1") { $selectedTypes += $oldOfficeDocs }
if ($selections -match "2") { $selectedTypes += $newOfficeDocs }
if ($selections -match "3") { $selectedTypes += $pdfDocs }
if ($selections -match "4") { $selectedTypes += $imageFiles }
if ($selections -match "5") { $selectedTypes += $videoFiles }
if ($selections -match "6") { $selectedTypes += $soundFiles }
if ($selections -match "7") { $selectedTypes += $oldOfficeDocs + $newOfficeDocs + $pdfDocs + $imageFiles + $videoFiles + $soundFiles }

# Execute backup based on selections
Backup-FilesByType -sourceDrive $sourceDrive -destDrive $destDrive -fileTypes $selectedTypes -activityLogFilePath $activityLogFilePath -errorLogFilePath $errorLogFilePath

# Include child powershell libs.
# Source the browser backup script
. ".\WinPreManage_browsers.ps1"

# Backup Browser Bookmarks and Downloads?
# Backup-BrowserData

# Write Exit & Script Execution feedback to terminal
Write-Host "Backup completed successfully. Activity log created at $activityLogFilePath"
Write-Host "Check $errorLogFilePath for any errors during the backup process."
