@echo off
REM SmartHomeLite - Create Data Directory Script for Windows
REM This script creates the data directory for the SmartHomeLite application

echo === SmartHomeLite Create Data Directory ===
echo This script will create the data directory for SmartHomeLite.
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)

REM Create the data directory
echo Creating data directory at %DATA_DIR%...
mkdir "%DATA_DIR%" 2>nul

REM Create subdirectories
mkdir "%DATA_DIR%\devices" 2>nul
mkdir "%DATA_DIR%\logs" 2>nul
mkdir "%DATA_DIR%\voice" 2>nul

REM Create an empty devices.json file if it doesn't exist
if not exist "%DATA_DIR%\devices\devices.json" (
    echo Creating empty devices.json file...
    echo [] > "%DATA_DIR%\devices\devices.json"
)

echo.
echo === Setup Complete! ===
echo The following directories have been created:
echo   %DATA_DIR%
echo   %DATA_DIR%\devices
echo   %DATA_DIR%\logs
echo   %DATA_DIR%\voice
echo.
echo An empty devices.json file has been created at:
echo   %DATA_DIR%\devices\devices.json

echo Press any key to exit...
pause > nul