@echo off
REM SmartHomeLite - Generate Sample Device Script for Windows
REM This script generates a sample device configuration file

echo === SmartHomeLite Sample Device Generator ===
echo This script will generate a sample device configuration file.
echo.

REM Get the data directory from environment variable or use default
if defined DATA_DIR (
    set DATA_DIR=%DATA_DIR%
) else (
    set DATA_DIR=.\data
)
set DEVICES_DIR=%DATA_DIR%\devices

REM Create the devices directory if it doesn't exist
mkdir "%DEVICES_DIR%" 2>nul

REM Check if devices.json exists
set DEVICES_FILE=%DEVICES_DIR%\devices.json
if not exist "%DEVICES_FILE%" (
    echo Creating empty devices.json file...
    echo [] > "%DEVICES_FILE%"
)

REM Ask for device type
echo Select device type:
echo 1. Light
echo 2. Thermostat
echo 3. Lock
echo 4. Camera
echo 5. Speaker
echo 6. Sensor
set /p DEVICE_TYPE_CHOICE=Enter choice [1-6]: 

REM Set device type based on choice
if "%DEVICE_TYPE_CHOICE%"=="1" (
    set DEVICE_TYPE=light
) else if "%DEVICE_TYPE_CHOICE%"=="2" (
    set DEVICE_TYPE=thermostat
) else if "%DEVICE_TYPE_CHOICE%"=="3" (
    set DEVICE_TYPE=lock
) else if "%DEVICE_TYPE_CHOICE%"=="4" (
    set DEVICE_TYPE=camera
) else if "%DEVICE_TYPE_CHOICE%"=="5" (
    set DEVICE_TYPE=speaker
) else if "%DEVICE_TYPE_CHOICE%"=="6" (
    set DEVICE_TYPE=sensor
) else (
    echo Invalid choice. Using 'light' as default.
    set DEVICE_TYPE=light
)

REM Ask for connection type
echo.
echo Select connection type:
echo 1. Bluetooth
echo 2. MQTT
echo 3. HTTP
set /p CONNECTION_TYPE_CHOICE=Enter choice [1-3]: 

REM Set connection type based on choice
if "%CONNECTION_TYPE_CHOICE%"=="1" (
    set CONNECTION_TYPE=bluetooth
) else if "%CONNECTION_TYPE_CHOICE%"=="2" (
    set CONNECTION_TYPE=mqtt
) else if "%CONNECTION_TYPE_CHOICE%"=="3" (
    set CONNECTION_TYPE=http
) else (
    echo Invalid choice. Using 'mqtt' as default.
    set CONNECTION_TYPE=mqtt
)

REM Generate a unique device ID
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set DATETIME=%%I
set TIMESTAMP=%DATETIME:~0,14%
set DEVICE_ID=sample_%DEVICE_TYPE%_%TIMESTAMP%

REM Ask for device name
echo.
set /p DEVICE_NAME=Enter device name [Sample %DEVICE_TYPE%]: 
if "%DEVICE_NAME%"=="" set DEVICE_NAME=Sample %DEVICE_TYPE%

REM Create device configuration based on type
echo.
echo Generating sample %DEVICE_TYPE% device configuration...

REM Create the device JSON structure
if "%DEVICE_TYPE%"=="light" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"power":"off","brightness":50,"color":"#FFFFFF"},"actions":["turn_on","turn_off","set_brightness","set_color"],"config":{"room":"Living Room"}}
) else if "%DEVICE_TYPE%"=="thermostat" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"power":"off","temperature":21,"target_temperature":22,"mode":"heat"},"actions":["turn_on","turn_off","set_temperature","set_mode"],"config":{"room":"Living Room","modes":["heat","cool","auto","off"]}}
) else if "%DEVICE_TYPE%"=="lock" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"state":"locked","battery":100},"actions":["lock","unlock"],"config":{"room":"Front Door"}}
) else if "%DEVICE_TYPE%"=="camera" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"power":"off","recording":false,"motion_detected":false},"actions":["turn_on","turn_off","start_recording","stop_recording"],"config":{"room":"Front Door","resolution":"1080p","stream_url":"http://localhost:8080/stream"}}
) else if "%DEVICE_TYPE%"=="speaker" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"power":"off","volume":50,"playing":false,"current_track":"None"},"actions":["turn_on","turn_off","set_volume","play","pause","next_track"],"config":{"room":"Living Room"}}
) else if "%DEVICE_TYPE%"=="sensor" (
    set DEVICE_JSON={"id":"%DEVICE_ID%","name":"%DEVICE_NAME%","type":"%DEVICE_TYPE%","connection_type":"%CONNECTION_TYPE%","status":"offline","properties":{"temperature":21,"humidity":45,"battery":100},"actions":[],"config":{"room":"Living Room","update_interval":60}}
)

REM Add connection-specific configuration
if "%CONNECTION_TYPE%"=="bluetooth" (
    set DEVICE_JSON=%DEVICE_JSON:}$=%,"connection_config":{"address":"00:11:22:33:44:55","service_uuid":"0000180a-0000-1000-8000-00805f9b34fb"}}
) else if "%CONNECTION_TYPE%"=="mqtt" (
    set DEVICE_JSON=%DEVICE_JSON:}$=%,"connection_config":{"broker":"localhost","port":1883,"topic":"smarthome/%DEVICE_TYPE%/%DEVICE_ID%"}}
) else if "%CONNECTION_TYPE%"=="http" (
    set DEVICE_JSON=%DEVICE_JSON:}$=%,"connection_config":{"url":"http://localhost:8080/api/devices/%DEVICE_ID%"}}
)

REM Check if PowerShell is available for better JSON handling
powershell -Command "$PSVersionTable.PSVersion" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    REM Use PowerShell to update the devices.json file
    powershell -Command "$devices = Get-Content -Raw -Path '%DEVICES_FILE%' | ConvertFrom-Json; if ($devices -eq $null) { $devices = @() }; $newDevice = ConvertFrom-Json -InputObject '%DEVICE_JSON%'; $devices += $newDevice; ConvertTo-Json -Depth 10 -InputObject $devices | Set-Content -Path '%DEVICES_FILE%'"
) else (
    REM Fallback to simple file manipulation if PowerShell is not available
    REM Read the current devices.json file
    set /p CURRENT_DEVICES=<"%DEVICES_FILE%"
    
    REM Check if the file is empty or not a valid JSON array
    if "%CURRENT_DEVICES%"=="" (
        echo [%DEVICE_JSON%] > "%DEVICES_FILE%"
    ) else if "%CURRENT_DEVICES%"=="[]" (
        echo [%DEVICE_JSON%] > "%DEVICES_FILE%"
    ) else (
        REM If not empty, append this device to the array
        REM Remove the closing bracket, add the new device, and close the array
        set CURRENT_DEVICES=%CURRENT_DEVICES:]=,%
        echo %CURRENT_DEVICES%%DEVICE_JSON%] > "%DEVICES_FILE%"
    )
)

REM Create a standalone file for this device
set SAMPLE_FILE=%DEVICES_DIR%\%DEVICE_ID%.json
echo %DEVICE_JSON% > "%SAMPLE_FILE%"

echo.
echo === Sample Device Created! ===
echo Device ID: %DEVICE_ID%
echo Device Type: %DEVICE_TYPE%
echo Connection Type: %CONNECTION_TYPE%
echo.
echo The device has been added to: %DEVICES_FILE%
echo A standalone device file has been created at: %SAMPLE_FILE%
echo.
echo You can now start the application to see the sample device.

echo Press any key to exit...
pause > nul