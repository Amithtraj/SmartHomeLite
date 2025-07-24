@echo off
REM SmartHomeLite - Restore Backup Script for Windows
REM This script restores a backup of the SmartHomeLite data directory

echo === SmartHomeLite Backup Restore ===
echo This script will restore your SmartHomeLite data from a backup.
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)

REM Check if backup directory exists
set BACKUP_DIR=.\backups
if not exist "%BACKUP_DIR%" (
    echo Error: Backup directory '%BACKUP_DIR%' does not exist.
    echo No backups found to restore from.
    pause
    exit /b 1
)

REM List available backups
echo Available backups:
setlocal EnableDelayedExpansion
set count=0

REM Check if PowerShell is available for better file handling
powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    REM Use PowerShell to list backups with details
    echo.
    powershell -Command "Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Sort-Object LastWriteTime -Descending | ForEach-Object { $i = 0 } { Write-Host ('[' + $i + '] ' + $_.Name + ' (' + [math]::Round($_.Length / 1MB, 2) + ' MB) - ' + $_.LastWriteTime); $i++ }"
    
    REM Count the number of backups
    for /f %%A in ('powershell -Command "(Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Measure-Object).Count"') do set backup_count=%%A
    
    if !backup_count! EQU 0 (
        echo No backup files found in '%BACKUP_DIR%'.
        pause
        exit /b 1
    )
    
    REM Ask user to select a backup
    echo.
    set /p SELECTION=Enter the number of the backup to restore [0-!backup_count!]: 
    
    REM Validate selection
    if "!SELECTION!"=="" goto invalid_selection
    for /f "delims=0123456789" %%i in ("!SELECTION!") do goto invalid_selection
    if !SELECTION! LSS 0 goto invalid_selection
    if !SELECTION! GEQ !backup_count! goto invalid_selection
    
    REM Get the selected backup file
    for /f "tokens=*" %%A in ('powershell -Command "(Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Sort-Object LastWriteTime -Descending)[%SELECTION%].FullName"') do set SELECTED_BACKUP=%%A
) else (
    REM Fallback to simple dir listing if PowerShell is not available
    for /f "tokens=*" %%F in ('dir /B /O-D "%BACKUP_DIR%\*.zip" 2^>nul') do (
        echo [!count!] %%F
        set "backup_!count!=%%F"
        set /a count+=1
    )
    
    if !count! EQU 0 (
        echo No backup files found in '%BACKUP_DIR%'.
        pause
        exit /b 1
    )
    
    REM Ask user to select a backup
    echo.
    set /p SELECTION=Enter the number of the backup to restore [0-!count!]: 
    
    REM Validate selection
    if "!SELECTION!"=="" goto invalid_selection
    for /f "delims=0123456789" %%i in ("!SELECTION!") do goto invalid_selection
    if !SELECTION! LSS 0 goto invalid_selection
    if !SELECTION! GEQ !count! goto invalid_selection
    
    REM Get the selected backup file
    set SELECTED_BACKUP=%BACKUP_DIR%\!backup_%SELECTION%!
)

echo.
echo Selected backup: !SELECTED_BACKUP!

REM Confirm before proceeding
echo.
echo WARNING: This will replace your current data with the backup.
echo Any changes made since the backup was created will be lost.
echo.
set /p CONFIRM=Do you want to continue? (y/N): 

if /i not "%CONFIRM%"=="y" (
    echo Restore cancelled.
    pause
    exit /b 0
)

REM Create a backup of current data before restoring
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set DATETIME=%%I
set TIMESTAMP=%DATETIME:~0,8%_%DATETIME:~8,6%
set CURRENT_BACKUP=%BACKUP_DIR%\pre_restore_%TIMESTAMP%.zip

if exist "%DATA_DIR%" (
    echo.
    echo Creating backup of current data to '%CURRENT_BACKUP%'...
    
    if %ERRORLEVEL% EQU 0 (
        powershell -Command "Compress-Archive -Path '%DATA_DIR%' -DestinationPath '%CURRENT_BACKUP%' -Force"
        if !ERRORLEVEL! NEQ 0 (
            echo Warning: Failed to backup current data. Proceeding with restore anyway.
        ) else (
            echo Current data backed up successfully.
        )
    ) else (
        echo Warning: PowerShell not available for backup. Proceeding with restore anyway.
    )
)

REM Restore the selected backup
echo.
echo Restoring from backup...

REM Remove existing data directory
if exist "%DATA_DIR%" (
    echo Removing existing data directory...
    rmdir /S /Q "%DATA_DIR%"
)

REM Extract the backup
echo Extracting backup...

if %ERRORLEVEL% EQU 0 (
    powershell -Command "Expand-Archive -Path '%SELECTED_BACKUP%' -DestinationPath '.' -Force"
    
    if !ERRORLEVEL! EQU 0 (
        echo.
        echo === Restore Complete! ===
        echo Your data has been restored from the backup.
        echo You can now start the application.
    ) else (
        echo.
        echo Error: Failed to restore from backup.
        echo If you backed up current data, you can find it at: %CURRENT_BACKUP%
        pause
        exit /b 1
    )
) else (
    echo Error: PowerShell is required for extracting ZIP archives.
    echo Please install PowerShell or extract the backup manually.
    pause
    exit /b 1
)

echo.
echo Press any key to exit...
pause > nul
exit /b 0

:invalid_selection
echo Invalid selection. Please enter a valid number.
pause
exit /b 1