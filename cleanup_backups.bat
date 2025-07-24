@echo off
REM SmartHomeLite - Cleanup Backups Script for Windows
REM This script helps clean up old backup files to save disk space

echo === SmartHomeLite Backup Cleanup ===
echo This script will help you clean up old backup files to save disk space.
echo.

REM Check if backup directory exists
set BACKUP_DIR=.\backups
if not exist "%BACKUP_DIR%" (
    echo Error: Backup directory '%BACKUP_DIR%' does not exist.
    echo No backups found to clean up.
    pause
    exit /b 1
)

REM Check if PowerShell is available for better file handling
powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: This script requires PowerShell to run.
    echo Please install PowerShell or use the manual cleanup method.
    pause
    exit /b 1
)

REM Count backup files
for /f %%A in ('powershell -Command "(Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Measure-Object).Count"') do set BACKUP_COUNT=%%A

if %BACKUP_COUNT% EQU 0 (
    echo No backup files found in '%BACKUP_DIR%'.
    pause
    exit /b 1
)

REM Display backup information
echo Found %BACKUP_COUNT% backup files in '%BACKUP_DIR%'.

REM Calculate total size
for /f %%A in ('powershell -Command "[math]::Round((Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Measure-Object -Property Length -Sum).Sum / 1MB, 2)"') do set TOTAL_SIZE=%%A
echo Total size of all backups: %TOTAL_SIZE% MB
echo.

REM List backups with details
echo Backup files (sorted by date, newest first):
echo ------------------------------------------
powershell -Command "Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Sort-Object LastWriteTime -Descending | Format-Table Name, @{Name='Size (MB)';Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime -AutoSize"
echo.

REM Ask how many backups to keep
echo How many recent backups would you like to keep?
echo (Recommended: 3-5 backups, enter 0 to cancel)
set /p KEEP_COUNT=Enter number: 

REM Validate input
if "%KEEP_COUNT%"=="" goto invalid_input
for /f "delims=0123456789" %%i in ("%KEEP_COUNT%") do goto invalid_input

if %KEEP_COUNT% EQU 0 (
    echo Operation cancelled. No backups were deleted.
    pause
    exit /b 0
)

if %KEEP_COUNT% GEQ %BACKUP_COUNT% (
    echo You chose to keep %KEEP_COUNT% backups, but there are only %BACKUP_COUNT% backups.
    echo No backups will be deleted.
    pause
    exit /b 0
)

REM Calculate how many backups to delete
set /a DELETE_COUNT=%BACKUP_COUNT% - %KEEP_COUNT%

REM Show which backups will be deleted
echo The following %DELETE_COUNT% backup(s) will be deleted:
powershell -Command "Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -Skip %KEEP_COUNT% | Format-Table Name, @{Name='Size (MB)';Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime -AutoSize"

REM Confirm deletion
echo.
set /p CONFIRM=Are you sure you want to delete these backups? (y/N): 

if /i not "%CONFIRM%"=="y" (
    echo Operation cancelled. No backups were deleted.
    pause
    exit /b 0
)

REM Delete the backups
echo.
echo Deleting old backups...
powershell -Command "Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -Skip %KEEP_COUNT% | ForEach-Object { Write-Host ('Deleting: ' + $_.Name); Remove-Item -Path $_.FullName -Force }"

REM Show results
for /f %%A in ('powershell -Command "[math]::Round((Get-ChildItem -Path '%BACKUP_DIR%\*.zip' | Measure-Object -Property Length -Sum).Sum / 1MB, 2)"') do set NEW_SIZE=%%A

echo.
echo Cleanup complete!
echo Kept the %KEEP_COUNT% most recent backup(s).
echo Deleted %DELETE_COUNT% old backup(s).
echo New total backup size: %NEW_SIZE% MB (was %TOTAL_SIZE% MB)

echo.
echo Press any key to exit...
pause > nul
exit /b 0

:invalid_input
echo Invalid input. Please enter a number.
pause
exit /b 1