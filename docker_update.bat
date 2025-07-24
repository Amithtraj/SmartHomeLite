@echo off
REM SmartHomeLite - Docker Update Script for Windows
REM This script helps update the SmartHomeLite application running in Docker

echo === SmartHomeLite Docker Update ===
echo This script will update SmartHomeLite running in Docker.
echo.

REM Check for Docker installation
docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker is not installed or not in PATH.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check for Git installation
git --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Git is not installed or not in PATH.
    echo Please install Git from https://git-scm.com/downloads
    pause
    exit /b 1
)

REM Check if this is a Git repository
if not exist .git (
    echo Error: This does not appear to be a Git repository.
    echo This script is intended to be run from the root of the SmartHomeLite Git repository.
    pause
    exit /b 1
)

REM Pull latest changes from Git
echo Pulling latest changes from Git repository...
git pull

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Failed to pull latest changes from Git repository.
    echo Please resolve any conflicts and try again.
    pause
    exit /b 1
)

REM Check if containers are running
set WAS_RUNNING=false
docker-compose ps | findstr "smarthome-lite" > nul
if %ERRORLEVEL% EQU 0 (
    set WAS_RUNNING=true
    echo Stopping SmartHomeLite...
    docker-compose down
)

REM Rebuild and start the containers
echo Rebuilding SmartHomeLite...
docker-compose build --no-cache smarthome-lite

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Failed to rebuild SmartHomeLite.
    echo Please check the error messages above.
    pause
    exit /b 1
)

REM Start the containers if they were running before
if "%WAS_RUNNING%"=="true" (
    echo Starting SmartHomeLite...
    docker-compose up -d
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo SmartHomeLite has been updated and restarted successfully.
        echo You can access the web interface at:
        echo   http://localhost:8000
    ) else (
        echo.
        echo Failed to start SmartHomeLite after update.
        echo Please check the error messages above.
        pause
        exit /b 1
    )
) else (
    echo.
    echo SmartHomeLite has been updated successfully.
    echo You can start it with docker_run.bat
)

echo Press any key to exit...
pause > nul