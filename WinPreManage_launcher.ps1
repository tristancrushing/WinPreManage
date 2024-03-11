<#
.SYNOPSIS
Launcher for the WinPreManage Suite

.DESCRIPTION
This script serves as a launcher for the WinPreManage suite. It configures the required execution policy for the session and provides options to run various components of the WinPreManage suite.

.NOTES
Version: 0.1.1
Author: Tristan McGowan (tristan@ipspy.net)
Date: March 10, 2024

#>

# Function to display menu and handle user input
function Show-Menu {
    param (
        [string]$path
    )

    Write-Host "WinPreManage Launcher" -ForegroundColor Cyan
    Write-Host "---------------------"
    Write-Host "1: Prepare USB with WinPreManage"
    Write-Host "2: WinPreManage Main Script"
    Write-Host "3: WinPreManage File Recovery"
    Write-Host "4: WinPreManage Browser Backup"
    Write-Host "5: WinPreManage Browser History Backup"
    Write-Host "6: WinPreManage Disk Health Functions"
    Write-Host "Q: Quit"
    $input = Read-Host "Please select an option"

    switch ($input) {
        '1' { 
            Set-ExecutionPolicy Unrestricted -Scope Process -Force
            & "$path\WinPreManage_prep_usb.ps1"
        }
        '2' {
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            & "$path\WinPreManage.ps1" 
        }
        '3' { 
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            & "$path\WinPreManage_FileRecovery.ps1" 
        }
        '4' { 
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            & "$path\WinPreManage_browsers.ps1" 
        }
        '5' { 
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            & "$path\WinPreManage_browsers_history.ps1" 
        }
        '6' { 
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            & "$path\WinPreManaged_DiskHealth_Functions.ps1" 
        }
        'Q' { Write-Host "Exiting WinPreManage Launcher"; return }
        default { Write-Host "Invalid selection, please try again." -ForegroundColor Red }
    }
}

# Determine path of WinPreManage files
$winPreManagePath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Call the menu function
Show-Menu -path $winPreManagePath
