@echo off
REM SmartHomeLite - Docker Logs Script for Windows
REM This script helps view logs of the SmartHomeLite application running in Docker

echo === SmartHomeLite Docker Logs ===
echo This script will show logs of SmartHomeLite running in Docker.
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
    echo Start it first with docker_run.bat
    pause
    exit /b 1
)

REM Show logs
echo Showing SmartHomeLite logs (press Ctrl+C to exit)...
echo.
docker-compose logs -f smarthome-lite