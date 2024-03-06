<#
.SYNOPSIS
WinPreManage File Recovery Utility

.DESCRIPTION
A PowerShell class designed to facilitate the recovery of deleted files using native Windows capabilities. This class provides methods for attempting to recover files through Windows File Recovery (requires installation) and by accessing Windows Shadow Copies.

.NOTES
Version: 0.1.0
Author: Tristan McGowan (tristan@ipspy.net)
Date: March 5, 2024

.EXAMPLE USAGE:
$recovery = [WinPreManageFileRecovery]::new("C:", "D:\RecoveredFiles")
$recovery.UseWindowsFileRecovery() # This will install Windows File Recovery if not present
$recovery.RecoverFromShadowCopy("\Users\YourUsername\Documents\LostFile.txt")

#>

class WinPreManageFileRecovery {
    [string]$sourcePath
    [string]$destinationPath

    WinPreManageFileRecovery([string]$source, [string]$destination) {
        $this.sourcePath = $source
        $this.destinationPath = $destination
    }

    [void]EnsureWindowsFileRecoveryInstalled() {
        if (!(Get-AppxPackage -Name Microsoft.WindowsFileRecovery)) {
            Write-Host "Windows File Recovery is not installed. Attempting to install via winget..."

            try {
                # Attempt to install Windows File Recovery using winget
                winget install --id=Microsoft.WindowsFileRecovery -e --accept-package-agreements --accept-source-agreements
                Write-Host "Windows File Recovery has been successfully installed."
            } catch {
                Write-Host "Failed to install Windows File Recovery. Please install it manually from the Microsoft Store."
            }
        } else {
            Write-Host "Windows File Recovery is already installed."
        }
    }

    [void]UseWindowsFileRecovery() {
        # Ensure Windows File Recovery is installed
        $this.EnsureWindowsFileRecoveryInstalled()

        # Example usage of Windows File Recovery; adjust parameters as needed
        $winfrCommand = "winfr $this.sourcePath $this.destinationPath /regular /n *.*"
        Invoke-Expression $winfrCommand
        Write-Host "Attempted recovery with Windows File Recovery to $this.destinationPath"
    }

    [void]RecoverFromShadowCopy([string]$fileRelativePath) {
        $shadowCopies = Get-WmiObject -Class Win32_ShadowCopy
        if ($shadowCopies.Count -eq 0) {
            Write-Host "No shadow copies available."
            return
        }

        # Attempt recovery from the first shadow copy for demonstration; adjust logic as needed for your use case
        $shadowCopy = $shadowCopies[0]
        $shadowCopyPath = $shadowCopy.DeviceObject + "\" + $fileRelativePath.TrimStart("\")
        
        $fullDestinationPath = Join-Path -Path $this.destinationPath -ChildPath (Split-Path -Leaf $fileRelativePath)
        
        try {
            Copy-Item -Path $shadowCopyPath -Destination $fullDestinationPath -Force
            Write-Host "Recovered file to $fullDestinationPath from shadow copy."
        } catch {
            Write-Host "Failed to recover file from shadow copy. Error: $_"
        }
    }
}
