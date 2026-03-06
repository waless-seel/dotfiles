@echo off
REM Dotfiles Setup Script for Windows

set "DOTFILES_DIR=%~dp0"

echo Running dotfiles setup...
echo.

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
