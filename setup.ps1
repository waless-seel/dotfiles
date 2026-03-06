# Dotfiles Setup Script for Windows (PowerShell)
# This script creates symbolic links for dotfiles configuration

param(
    [switch]$NoAdmin = $false
)

# Colors for output
$ColorGreen = 'Green'
$ColorYellow = 'Yellow'
$ColorRed = 'Red'

# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $NoAdmin) {
        Write-Host "WARNING: This script may require administrator privileges to create symbolic links." -ForegroundColor $ColorYellow
        Write-Host "Please run PowerShell as Administrator or use the -NoAdmin flag to continue without this check." -ForegroundColor $ColorYellow
        Write-Host ""
        $response = Read-Host "Continue without administrator privileges? (y/n)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Setup cancelled." -ForegroundColor $ColorRed
            exit 1
        }
    }
}

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $env:USERPROFILE

Write-Host "Starting dotfiles setup..." -ForegroundColor $ColorYellow

# Function to create symlink
function New-DotfilesLink {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$Name
    )

    # Create destination directory if it doesn't exist
    $DestDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    # Remove existing symlink or file
    if (Test-Path $DestinationPath) {
        Write-Host "Removing existing $Name..." -ForegroundColor $ColorYellow
        Remove-Item -Path $DestinationPath -Force
    }

    # Create symlink
    try {
        New-Item -ItemType SymbolicLink -Path $DestinationPath -Target $SourcePath -Force | Out-Null
        Write-Host "✓ Created symlink for $Name" -ForegroundColor $ColorGreen
    }
    catch {
        Write-Host "✗ Failed to create symlink for $Name" -ForegroundColor $ColorRed
        Write-Host "  Error: $_" -ForegroundColor $ColorRed
        Write-Host "  Try running PowerShell as Administrator" -ForegroundColor $ColorYellow
        exit 1
    }
}

# WezTerm Configuration
Write-Host ""
Write-Host "Setting up WezTerm..." -ForegroundColor $ColorYellow
New-DotfilesLink `
    -SourcePath "$DotfilesDir\WezTerm\.wezterm.lua" `
    -DestinationPath "$HomeDir\.wezterm.lua" `
    -Name "WezTerm configuration"

# PowerShell Configuration
Write-Host ""
Write-Host "Setting up PowerShell..." -ForegroundColor $ColorYellow

# PowerShell profile
New-DotfilesLink `
    -SourcePath "$DotfilesDir\pwsh\Microsoft.PowerShell_profile.ps1" `
    -DestinationPath $Profile `
    -Name "PowerShell profile"

Write-Host ""
Write-Host "✓ Dotfiles setup completed successfully!" -ForegroundColor $ColorGreen
