@echo off
REM Dotfiles Setup Script for Windows
REM pwsh (PowerShell 7+) が必要です

where pwsh >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: pwsh ^(PowerShell 7+^) が見つかりません。
    echo 以下のコマンドでインストールしてください:
    echo   winget install --id Microsoft.PowerShell
    pause
    exit /b 1
)

pwsh -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*

if %errorlevel% neq 0 (
    echo.
    echo Setup failed!
    pause
    exit /b 1
)

echo.
echo Setup completed successfully!
pause
