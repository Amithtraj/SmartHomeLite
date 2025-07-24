@echo off
REM SmartHomeLite - Docker Run Script for Windows
REM This script helps run the SmartHomeLite application using Docker on Windows

echo === SmartHomeLite Docker Run ===
echo This script will start SmartHomeLite using Docker.
echo.

REM Check for Docker installation
docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker is not installed or not in PATH.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check if containers are already running
docker-compose ps | findstr "smarthome-lite" > nul
if %ERRORLEVEL% EQU 0 (
    echo SmartHomeLite is already running.
    echo.
    echo To view logs:
    echo   docker-compose logs -f smarthome-lite
    echo.
    echo To stop the application:
    echo   docker-compose down
    echo.
    echo To restart the application:
    echo   docker-compose restart smarthome-lite
) else (
    echo Starting SmartHomeLite...
    docker-compose up -d
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo SmartHomeLite is now running.
        echo You can access the web interface at:
        echo   http://localhost:8000
        echo.
        echo To view logs:
        echo   docker-compose logs -f smarthome-lite
        echo.
        echo To stop the application:
        echo   docker-compose down
    ) else (
        echo.
        echo Failed to start SmartHomeLite.
        echo Please check the error messages above.
    )
)

echo Press any key to exit...
pause > nul