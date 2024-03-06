# WinPreManage Suite

## Overview
The WinPreManage suite is a comprehensive collection of PowerShell scripts developed to assist Managed Service Providers (MSPs) and IT professionals in preparing Windows systems for MSP management. This suite encompasses utilities for data backup, file recovery, browser data management, and disk health assessment. It is uniquely designed to be run from a 32GB or larger USB 2.0 or 3.0 flash drive, which doubles as the backup media. This approach not only facilitates the backup process but also serves as a leave-behind for clients, ensuring they possess a backup of literally everything they need.

### Features
- **Data Backup**: Securely backs up documents, images, videos, and other critical user data to the USB drive.
- **File Recovery**: Offers tools for recovering deleted files using native Windows capabilities, including support for Windows File Recovery and Shadow Copies.
- **Browser Data Management**: Provides functionality to backup and manage web browser data, including bookmarks and history from popular browsers such as Internet Explorer, Edge, Firefox, Opera, and Chrome.
- **Disk Health Monitoring**: Performs comprehensive checks on disk health and performance, including S.M.A.R.T. status assessments, disk space usage, file system integrity checks, and more.

## Installation
1. Ensure PowerShell 5.1 or later is installed on the Windows system.
2. Download the WinPreManage suite and copy it to a 32GB or larger USB flash drive.
3. Extract the suite directly onto the USB drive.

## Usage
Execute the scripts directly from the USB drive in an elevated PowerShell prompt. Each utility is designed for easy use with clear instructions:

### Data Backup
```powershell
.\WinPreManage.ps1
```
- Follow the interactive prompts to select source and destination paths for the backup, directly utilizing the USB drive as the destination.

### File Recovery
```powershell
$recovery = [WinPreManageFileRecovery]::new("SourcePath", "DestinationPath")
$recovery.UseWindowsFileRecovery()
$recovery.RecoverFromShadowCopy("FilePath")
```

### Browser Data Management
```powershell
.\WinPreManage_browsers.ps1
```
- Choose the browsers and data types to backup when prompted.

### Disk Health Monitoring
```powershell
.\WinPreManaged_DiskHealth_Functions.ps1
```
- Check the generated logs for detailed information on disk health.

## Pre-testing Phase Note
This suite is currently in a pre-testing phase. As such, features and functionalities are subject to change. We welcome feedback and contributions to improve the utilities.

## License
The project is licensed under [LICENSE DETAILS]. Please see the LICENSE file for more details.

## Acknowledgements
Special thanks to Tristan McGowan for the development and contributions to the WinPreManage suite.

## Contact
For further information, suggestions, or contributions, please contact (tristan@ipspy.net).
