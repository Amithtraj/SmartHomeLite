@echo off
REM SmartHomeLite - Docker Setup Script for Windows
REM This script helps set up the SmartHomeLite application using Docker on Windows

echo === SmartHomeLite Docker Setup ===
echo This script will set up SmartHomeLite using Docker.
echo.

REM Check for Docker installation
docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker is not installed or not in PATH.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check for Docker Compose installation
docker-compose --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker Compose is not installed or not in PATH.
    echo Docker Compose should be included with Docker Desktop.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo === Creating configuration file ===
    copy example.env .env
    echo Created .env file. You may want to edit it with your preferred settings.
)

REM Create data directory
echo === Creating data directory ===
if not exist data mkdir data

REM Create MQTT directories
echo === Setting up MQTT ===
if not exist mqtt\config mkdir mqtt\config
if not exist mqtt\data mkdir mqtt\data
if not exist mqtt\log mkdir mqtt\log

REM Copy MQTT config if it doesn't exist
if not exist mqtt\config\mosquitto.conf (
    copy mqtt\config\mosquitto.conf.example mqtt\config\mosquitto.conf 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo Creating default MQTT configuration...
        (
            echo # Mosquitto MQTT Broker Configuration
            echo.
            echo # Basic configuration
            echo persistence true
            echo persistence_location /mosquitto/data/
            echo log_dest file /mosquitto/log/mosquitto.log
            echo log_type all
            echo.
            echo # Allow anonymous connections (for development)
            echo allow_anonymous true
            echo.
            echo # Uncomment and modify for authentication
            echo # password_file /mosquitto/config/passwd
            echo.
            echo # Listeners
            echo listener 1883
            echo protocol mqtt
            echo.
            echo listener 9001
            echo protocol websockets
        ) > mqtt\config\mosquitto.conf
    )
    echo Created default mosquitto.conf file.
)

REM Build and start the containers
echo === Building and starting containers ===
docker-compose build
docker-compose up -d

REM Setup complete
echo.
echo === Setup Complete! ===
echo SmartHomeLite is now running in Docker.
echo You can access the web interface at:
echo   http://localhost:8000
echo.
echo To view logs:
echo   docker-compose logs -f smarthome-lite
echo.
echo To stop the application:
echo   docker-compose down
echo.
echo Note: For Bluetooth functionality, the container needs access to the host's Bluetooth hardware.
echo This may require additional configuration depending on your system.

echo Press any key to exit...
pause > nul