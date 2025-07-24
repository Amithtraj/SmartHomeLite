@echo off
REM SmartHomeLite - Check Status Script for Windows
REM This script checks the status of the SmartHomeLite application

echo === SmartHomeLite Status Check ===
echo This script will check the status of your SmartHomeLite application.
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)

REM Check if data directory exists
if not exist "%DATA_DIR%" (
    echo [X] Data directory '%DATA_DIR%' does not exist.
    echo     The application may not be properly set up.
    echo     Run create_data_dir.bat to create the data directory.
) else (
    echo [√] Data directory exists: %DATA_DIR%
    
    REM Check devices directory
    if exist "%DATA_DIR%\devices" (
        echo [√] Devices directory exists: %DATA_DIR%\devices
        
        REM Check devices.json file
        if exist "%DATA_DIR%\devices\devices.json" (
            echo [√] Devices configuration file exists: %DATA_DIR%\devices\devices.json
            
            REM Count devices (requires PowerShell)
            powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
            if %ERRORLEVEL% EQU 0 (
                for /f %%A in ('powershell -Command "(Get-Content '%DATA_DIR%\devices\devices.json' | Select-String -Pattern '\"id\":' -AllMatches).Matches.Count"') do set DEVICE_COUNT=%%A
                echo     Found %DEVICE_COUNT% device(s) in configuration.
            )
        ) else (
            echo [X] Devices configuration file does not exist: %DATA_DIR%\devices\devices.json
            echo     Run generate_sample_device.bat to create a sample device.
        )
    ) else (
        echo [X] Devices directory does not exist: %DATA_DIR%\devices
    )
    
    REM Check logs directory
    if exist "%DATA_DIR%\logs" (
        echo [√] Logs directory exists: %DATA_DIR%\logs
        
        REM Count log files
        set LOG_COUNT=0
        for /f %%A in ('dir /b /a-d "%DATA_DIR%\logs" 2^>nul ^| find /c /v ""') do set LOG_COUNT=%%A
        echo     Found %LOG_COUNT% log file(s).
    ) else (
        echo [X] Logs directory does not exist: %DATA_DIR%\logs
    )
    
    REM Check voice directory
    if exist "%DATA_DIR%\voice" (
        echo [√] Voice directory exists: %DATA_DIR%\voice
    ) else (
        echo [X] Voice directory does not exist: %DATA_DIR%\voice
    )
)

REM Check .env file
if exist ".env" (
    echo [√] Environment file exists: .env
    
    REM Check if .env file has required variables
    findstr /C:"HOST" .env >nul
    set HOST_EXISTS=%ERRORLEVEL%
    findstr /C:"PORT" .env >nul
    set PORT_EXISTS=%ERRORLEVEL%
    
    if %HOST_EXISTS% EQU 0 if %PORT_EXISTS% EQU 0 (
        echo [√] Environment file contains basic configuration.
    ) else (
        echo [!] Environment file may be missing some configuration.
        echo     Check example.env for required variables.
    )
) else (
    echo [X] Environment file does not exist: .env
    echo     Copy example.env to .env to set up the environment.
)

REM Check if application is running
echo.
echo Checking if application is running...

REM Check for Python process running run.py
set APP_RUNNING=0
for /f "tokens=1" %%i in ('tasklist /fi "imagename eq python.exe" /fo csv /nh') do (
    tasklist /fi "imagename eq python.exe" /v /fo csv | findstr /i "run.py" >nul
    if %ERRORLEVEL% EQU 0 set APP_RUNNING=1
)

if %APP_RUNNING% EQU 1 (
    echo [√] Application is running.
    
    REM Try to determine the port (requires PowerShell)
    powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        for /f %%A in ('powershell -Command "Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' -and ($_.LocalPort -eq 8000 -or $_.LocalPort -eq 5000) } | Select-Object -First 1 -ExpandProperty LocalPort"') do set PORT=%%A
        
        if defined PORT (
            echo [√] Application is likely listening on port: %PORT%
            echo     You can access the web interface at: http://localhost:%PORT%
        ) else (
            echo [!] Could not determine the port the application is listening on.
        )
    )
) else (
    echo [X] Application is not running.
    echo     Start the application with: python run.py
)

REM Check for Docker
where docker >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Checking Docker status...
    
    REM Check if Docker container is running
    docker ps | findstr "smarthome-lite" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [√] Docker container is running.
        
        REM Get the port mapping (requires PowerShell)
        powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            for /f %%A in ('powershell -Command "(docker ps | Select-String -Pattern 'smarthome-lite.*0.0.0.0:(\\d+)->8000/tcp' | ForEach-Object { $_.Matches.Groups[1].Value }) -replace '\r\n'"') do set DOCKER_PORT=%%A
            
            if defined DOCKER_PORT (
                echo [√] Docker container is exposing port: %DOCKER_PORT%
                echo     You can access the web interface at: http://localhost:%DOCKER_PORT%
            ) else (
                echo [!] Could not determine the port mapping for the Docker container.
            )
        )
    ) else (
        echo [X] Docker container is not running.
        echo     Start the Docker container with: docker-compose up -d
    )
)

REM Check for MQTT broker
where mosquitto >nul 2>&1 || where mosquitto_sub >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Checking MQTT broker status...
    
    REM Try to connect to MQTT broker
    mosquitto_sub -t "test" -C 1 -W 2 >nul 2>&1
    
    if %ERRORLEVEL% EQU 0 (
        echo [√] MQTT broker is running and accessible.
    ) else (
        echo [X] MQTT broker is not running or not accessible.
        echo     Start the MQTT broker if you want to use MQTT devices.
    )
)

echo.
echo === Status Check Complete! ===

echo Press any key to exit...
pause > nul