@echo off
REM SmartHomeLite - Docker Stop Script for Windows
REM This script helps stop the SmartHomeLite application running in Docker

echo === SmartHomeLite Docker Stop ===
echo This script will stop SmartHomeLite running in Docker.
echo.

REM Check for Docker installation
docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker is not installed or not in PATH.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check if containers are running
docker-compose ps | findstr "smarthome-lite" > nul
if %ERRORLEVEL% NEQ 0 (
    echo SmartHomeLite is not currently running.
    pause
    exit /b 0
)

REM Stop the containers
echo Stopping SmartHomeLite...
docker-compose down

REM Check if shutdown was successful
if %ERRORLEVEL% EQU 0 (
    echo.
    echo SmartHomeLite has been stopped successfully.
) else (
    echo.
    echo Failed to stop SmartHomeLite.
    echo Please check the error messages above.
)

echo Press any key to exit...
pause > nul