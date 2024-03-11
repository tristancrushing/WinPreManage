<#
.SYNOPSIS
Prepares a USB stick for WinPreManage deployment by setting up required directories and copying WinPreManage files.

.DESCRIPTION
This script creates a structured environment on a USB stick for WinPreManage deployment. It checks for the presence of required WinPreManage files in the script's current directory and copies them to the USB stick. If any files are missing, the user is prompted to download the repository again.

.NOTES
Version: 0.1.1
Author: Tristan McGowan (trsitan@ipspy.net)
Date: March 10, 2024

#>

# Get the script's current directory
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# List of required WinPreManage files
$requiredFiles = @(
    "WinPreManage.ps1",
    "WinPreManage_FileRecovery.ps1",
    "WinPreManage_browsers.ps1",
    "WinPreManage_browsers_history.ps1",
    "WinPreManaged_DiskHealth_Functions.ps1"
)

# Check for the presence of required files
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path -Path (Join-Path -Path $scriptDir -ChildPath $_)) }

if ($missingFiles) {
    Write-Host "The following required files are missing:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    Write-Host "Please download the complete repository from https://github.com/tristancrushing/WinPreManage" -ForegroundColor Green
    exit
}

# Function to get removable drives (omitted for brevity, include your existing implementation)
# Function Get-RemovableDrives goes here

# Function to confirm drive selection (omitted for brevity, include your existing implementation)
# Function Confirm-DriveSelection goes here

# Display all removable drives
$drives = Get-RemovableDrives
Write-Host "Available USB Drives:"
$drives | ForEach-Object { Write-Host $_.DeviceID }

# Ask the user to select a drive
$selectedDrive = Read-Host "Please enter the drive letter of the USB stick you want to use (e.g., E:\)"

# Confirm drive selection
Confirm-DriveSelection -driveLetter $selectedDrive

# Create necessary directories on the selected drive
$dirsToCreate = @("WinPreManage", "Backup", "Logs")
foreach ($dir in $dirsToCreate) {
    $path = Join-Path -Path $selectedDrive -ChildPath $dir
    New-Item -Path $path -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $path"
}

# Copy WinPreManage files to the USB stick
$winPreManageDir = Join-Path -Path $selectedDrive -ChildPath "WinPreManage"
foreach ($file in $requiredFiles) {
    $sourceFilePath = Join-Path -Path $scriptDir -ChildPath $file
    $destinationFilePath = Join-Path -Path $winPreManageDir -ChildPath $file
    Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Force
    Write-Host "Copied $file to $winPreManageDir."
}

Write-Host "WinPreManage has been successfully prepared on $selectedDrive. Backup and Logs directories are also set up."
