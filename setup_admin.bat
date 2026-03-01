@echo off
REM Dotfiles Setup Script for Windows (Batch - Admin)
REM This script runs setup with administrator privileges

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "SETUP_PS1=%SCRIPT_DIR%setup.ps1"

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    echo.

    REM Create a temporary batch file that will be run with admin privileges
    set "TEMP_BAT=%temp%\setup_temp.bat"

    (
        echo @echo off
        echo cd /d "%SCRIPT_DIR%"
        echo powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%SETUP_PS1%"
        echo pause
    ) > "!TEMP_BAT!"

    REM Use PowerShell to elevate the temporary batch
    powershell -NoProfile -Command "Start-Process -FilePath '!TEMP_BAT!' -Verb runas -Wait"

    REM Clean up
    timeout /t 1 /nobreak >nul 2>&1
    del /q "!TEMP_BAT!" 2>nul
    exit /b 0
)

echo Running dotfiles setup with administrator privileges...
echo.

REM Get the directory where this script is located
set "DOTFILES_DIR=%~dp0"

REM Run PowerShell script
powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%DOTFILES_DIR%setup.ps1"

if %errorlevel% neq 0 (
    echo.
    echo Setup failed!
    pause
    exit /b 1
)

echo.
echo Setup completed successfully!
pause
