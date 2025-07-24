@echo off
REM SmartHomeLite - Backup Data Script for Windows
REM This script creates a backup of the SmartHomeLite data directory

echo === SmartHomeLite Data Backup ===
echo This script will create a backup of your SmartHomeLite data.
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)

REM Check if data directory exists
if not exist "%DATA_DIR%" (
    echo Error: Data directory '%DATA_DIR%' does not exist.
    echo Please run the application at least once to create the data directory.
    pause
    exit /b 1
)

REM Create backup directory if it doesn't exist
set BACKUP_DIR=.\backups
mkdir "%BACKUP_DIR%" 2>nul

REM Create a timestamp for the backup file
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set DATETIME=%%I
set TIMESTAMP=%DATETIME:~0,8%_%DATETIME:~8,6%
set BACKUP_FILE=%BACKUP_DIR%\smarthome_data_%TIMESTAMP%.zip

REM Create the backup
echo Creating backup of '%DATA_DIR%' to '%BACKUP_FILE%'...

REM Check if PowerShell is available for better compression
powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    powershell -Command "Compress-Archive -Path '%DATA_DIR%' -DestinationPath '%BACKUP_FILE%' -Force"
) else (
    REM Fallback to simple xcopy backup if PowerShell is not available
    set BACKUP_DIR_FULL=%BACKUP_DIR%\smarthome_data_%TIMESTAMP%
    mkdir "%BACKUP_DIR_FULL%" 2>nul
    xcopy "%DATA_DIR%" "%BACKUP_DIR_FULL%" /E /I /H /Y
    echo Backup created at: %BACKUP_DIR_FULL%
    goto backup_done
)

if %ERRORLEVEL% EQU 0 (
    echo Backup created successfully!
    echo Backup file: %BACKUP_FILE%
    
    REM List existing backups
    echo.
    echo Existing backups:
    dir /B /O-D "%BACKUP_DIR%\*.zip" 2>nul
    
    REM Cleanup old backups (keep last 5)
    setlocal EnableDelayedExpansion
    set count=0
    for /f "tokens=*" %%F in ('dir /B /O-D "%BACKUP_DIR%\*.zip" 2^>nul') do (
        set /a count+=1
        if !count! GTR 5 (
            echo Removing old backup: %%F
            del "%BACKUP_DIR%\%%F"
        )
    )
    endlocal
) else (
    echo Failed to create backup.
    echo Please check permissions and disk space.
    pause
    exit /b 1
)

:backup_done
echo.
echo Backup process completed.
echo Press any key to exit...
pause > nul