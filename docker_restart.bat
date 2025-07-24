@echo off
REM SmartHomeLite - Docker Restart Script for Windows
REM This script helps restart the SmartHomeLite application running in Docker

echo === SmartHomeLite Docker Restart ===
echo This script will restart SmartHomeLite running in Docker.
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
    echo Starting it instead...
    docker-compose up -d
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo SmartHomeLite has been started successfully.
        echo You can access the web interface at:
        echo   http://localhost:8000
    ) else (
        echo.
        echo Failed to start SmartHomeLite.
        echo Please check the error messages above.
    )
    
    pause
    exit /b
)

REM Restart the container
echo Restarting SmartHomeLite...
docker-compose restart smarthome-lite

REM Check if restart was successful
if %ERRORLEVEL% EQU 0 (
    echo.
    echo SmartHomeLite has been restarted successfully.
    echo You can access the web interface at:
    echo   http://localhost:8000
) else (
    echo.
    echo Failed to restart SmartHomeLite.
    echo Please check the error messages above.
)

echo Press any key to exit...
pause > nul