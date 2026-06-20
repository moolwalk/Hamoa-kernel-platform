<#
.SYNOPSIS
Compact a WSL VHDX file using Hyper-V optimization.

.DESCRIPTION
This script shuts down WSL, imports the Hyper-V PowerShell module, and runs Optimize-VHD -Mode Full on the specified VHDX file.

.PARAMETER Path
The full path to the WSL VHDX file to compact.

.EXAMPLE
.\shrink-wsl-vhdx.ps1 -Path 'D:\VHDx\Ubuntu-24.04\ext4.vhdx'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = 'D:\VHDx\Ubuntu-24.04\ext4.vhdx'
)

function Assert-CommandAvailable {
    param(
        [string]$Name
    )
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Throw "Required command '$Name' is not available. Install the Hyper-V module and try again."
    }
}

if (-not (Test-Path -Path $Path)) {
    Throw "The VHDX file was not found: $Path"
}

Write-Host "Shutting down WSL..." -ForegroundColor Cyan
wsl --shutdown

Write-Host "Checking Hyper-V module..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
    Throw "The Hyper-V PowerShell module is not installed or available. Install it before running this script."
}

Import-Module Hyper-V -ErrorAction Stop
Assert-CommandAvailable -Name Optimize-VHD

Write-Host "Optimizing VHDX: $Path" -ForegroundColor Cyan
Optimize-VHD -Path $Path -Mode Full

Write-Host "Done. Current file size:" -ForegroundColor Green
Get-Item -Path $Path | Select-Object FullName, Length | Format-List
