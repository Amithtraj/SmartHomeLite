@echo off
REM SmartHomeLite - Reset Application Script for Windows
REM This script resets the application to its initial state

echo === SmartHomeLite Reset Application ===
echo This script will reset the application to its initial state.
echo WARNING: This will delete all your devices and settings!
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)

REM Check if data directory exists
if not exist "%DATA_DIR%" (
    echo Data directory '%DATA_DIR%' does not exist.
    echo Nothing to reset.
    pause
    exit /b 0
)

REM Ask for confirmation
echo Are you ABSOLUTELY SURE you want to reset the application?
echo This will delete all your devices and settings!
set /p CONFIRM=Type 'RESET' (all caps) to confirm: 

if not "%CONFIRM%"=="RESET" (
    echo Reset cancelled.
    pause
    exit /b 0
)

REM Create a backup before resetting
set BACKUP_DIR=.\backups
mkdir "%BACKUP_DIR%" 2>nul

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set DATETIME=%%I
set TIMESTAMP=%DATETIME:~0,8%_%DATETIME:~8,6%
set BACKUP_FILE=%BACKUP_DIR%\pre_reset_%TIMESTAMP%.zip

echo.
echo Creating backup before reset to '%BACKUP_FILE%'...

REM Check if PowerShell is available for better compression
powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    powershell -Command "Compress-Archive -Path '%DATA_DIR%' -DestinationPath '%BACKUP_FILE%' -Force"
    
    if %ERRORLEVEL% NEQ 0 (
        echo Warning: Failed to create backup. Do you want to continue anyway? (y/N):
        set /p CONTINUE=
        if /i not "%CONTINUE%"=="y" (
            echo Reset cancelled.
            pause
            exit /b 0
        )
    ) else (
        echo Backup created successfully.
    )
) else (
    REM Fallback to simple xcopy backup if PowerShell is not available
    set BACKUP_DIR_FULL=%BACKUP_DIR%\pre_reset_%TIMESTAMP%
    mkdir "%BACKUP_DIR_FULL%" 2>nul
    xcopy "%DATA_DIR%" "%BACKUP_DIR_FULL%" /E /I /H /Y >nul
    echo Backup created at: %BACKUP_DIR_FULL%
)

REM Reset the application
echo.
echo Resetting application...

REM Remove the data directory
rmdir /S /Q "%DATA_DIR%"

REM Create a fresh data directory structure
mkdir "%DATA_DIR%\devices" 2>nul
mkdir "%DATA_DIR%\logs" 2>nul
mkdir "%DATA_DIR%\voice" 2>nul

REM Create an empty devices.json file
echo [] > "%DATA_DIR%\devices\devices.json"

REM Reset .env file if it exists
if exist ".env" if exist "example.env" (
    echo Resetting .env file from example.env...
    copy /Y example.env .env >nul
)

echo.
echo === Reset Complete! ===
echo The application has been reset to its initial state.
echo A backup of your previous data was created at: %BACKUP_FILE%
echo You can now start the application with a fresh configuration.

echo Press any key to exit...
pause > nul