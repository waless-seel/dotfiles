# Dotfiles Setup Script for Windows (PowerShell)
# This script creates symbolic links for dotfiles configuration
# 要件: pwsh (PowerShell 7+)

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

# mise のインストール (winget)
Write-Host ""
Write-Host "Checking mise..." -ForegroundColor $ColorYellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: winget が見つかりません。Microsoft Store から 'App Installer' をインストールしてください。" -ForegroundColor $ColorRed
    exit 1
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "✓ mise はインストール済みです" -ForegroundColor $ColorGreen
} else {
    Write-Host "mise をインストールしています..." -ForegroundColor $ColorYellow
    winget install --id jdx.mise --silent --accept-source-agreements --accept-package-agreements
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = $machinePath + ';' + $userPath
    Write-Host "✓ mise をインストールしました" -ForegroundColor $ColorGreen
}

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

$ProfileDir = Split-Path -Parent $Profile
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

$ProfileLine = ". `"$DotfilesDir\pwsh\Microsoft.PowerShell_profile.ps1`""
if (-not (Test-Path $Profile)) {
    New-Item -ItemType File -Path $Profile -Force | Out-Null
}

$ProfileContent = Get-Content $Profile -ErrorAction SilentlyContinue
if ($ProfileContent -notcontains $ProfileLine) {
    Add-Content -Path $Profile -Value $ProfileLine
    Write-Host "✓ PowerShell profile に dotfiles の読み込みを追加しました" -ForegroundColor $ColorGreen
} else {
    Write-Host "✓ PowerShell profile は設定済みです" -ForegroundColor $ColorGreen
}

# mise グローバル config
Write-Host ""
Write-Host "Setting up mise..." -ForegroundColor $ColorYellow
New-DotfilesLink `
    -SourcePath "$DotfilesDir\mise.toml" `
    -DestinationPath "$env:APPDATA\mise\config.toml" `
    -Name "mise global config"

# ツールを一括インストール
Write-Host ""
Write-Host "Running mise install..." -ForegroundColor $ColorYellow
mise trust "$DotfilesDir\mise.toml"
mise install
Write-Host "✓ mise install 完了" -ForegroundColor $ColorGreen

Write-Host ""
Write-Host "✓ Dotfiles setup completed successfully!" -ForegroundColor $ColorGreen
