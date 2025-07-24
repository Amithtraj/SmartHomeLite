@echo off
REM SmartHomeLite - Check Requirements Script for Windows
REM This script checks if the system meets the requirements for running SmartHomeLite

echo === SmartHomeLite Requirements Check ===
echo This script will check if your system meets the requirements for running SmartHomeLite.
echo.

REM Function to check if a command is available
setlocal EnableDelayedExpansion

REM Check Python
echo === Python ===
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] Python is not installed.
    set python_ok=false
) else (
    for /f "tokens=2" %%V in ('python --version 2^>^&1') do set python_version=%%V
    for /f "tokens=1,2 delims=." %%a in ("!python_version!") do (
        set python_major=%%a
        set python_minor=%%b
    )
    
    if !python_major! LSS 3 (
        echo [X] Python !python_version! is installed, but version 3.11+ is required.
        set python_ok=false
    ) else if !python_major! EQU 3 if !python_minor! LSS 11 (
        echo [X] Python !python_version! is installed, but version 3.11+ is required.
        set python_ok=false
    ) else (
        echo [√] Python !python_version! is installed (required: 3.11+).
        set python_ok=true
    )
)
echo.

REM Check Git
echo === Git ===
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] Git is not installed.
    echo     Download from: https://git-scm.com/download/win
    set git_ok=false
) else (
    for /f "tokens=3" %%V in ('git --version') do set git_version=%%V
    echo [√] Git !git_version! is installed.
    set git_ok=true
)
echo.

REM Check pip
echo === Pip (Python Package Manager) ===
python -m pip --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] Pip is not installed or not working properly.
    set pip_ok=false
) else (
    for /f "tokens=2" %%V in ('python -m pip --version') do set pip_version=%%V
    echo [√] Pip !pip_version! is installed.
    set pip_ok=true
)
echo.

REM Check Docker (optional)
echo === Docker (Optional) ===
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Docker is not installed (optional for containerized deployment).
    echo     Download from: https://www.docker.com/products/docker-desktop
    set docker_ok=false
) else (
    for /f "tokens=3" %%V in ('docker --version') do set docker_version=%%V
    echo [√] Docker !docker_version! is installed.
    set docker_ok=true
)
echo.

REM Check Bluetooth support
echo === Bluetooth Support ===
powershell -Command "Get-PnpDevice -Class Bluetooth" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Unable to check Bluetooth devices.
    set bluetooth_ok=unknown
) else (
    powershell -Command "$bt = Get-PnpDevice -Class Bluetooth; if ($bt) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [!] No Bluetooth adapters found.
        set bluetooth_ok=false
    ) else (
        echo [√] Bluetooth adapter is available.
        set bluetooth_ok=true
    )
)
echo.

REM Summary
echo === Summary ===
set all_ok=true

if "%python_ok%"=="false" (
    echo [X] Python requirements not met.
    set all_ok=false
) else (
    echo [√] Python requirements met.
)

if "%git_ok%"=="false" (
    echo [X] Git is not installed.
    set all_ok=false
) else (
    echo [√] Git is installed.
)

if "%pip_ok%"=="false" (
    echo [X] Pip is not working properly.
    set all_ok=false
) else (
    echo [√] Pip is working properly.
)

if "%bluetooth_ok%"=="false" (
    echo [!] Bluetooth support may be limited.
    REM Don't fail for Bluetooth as it's technically optional
) else if "%bluetooth_ok%"=="true" (
    echo [√] Bluetooth support is available.
) else (
    echo [!] Bluetooth status unknown.
)

echo.
if "%all_ok%"=="true" (
    echo [√] Your system meets the basic requirements for running SmartHomeLite.
    echo     You can proceed with the installation.
    exit /b 0
) else (
    echo [X] Your system does not meet all requirements for running SmartHomeLite.
    echo     Please install the missing components before proceeding.
    pause
    exit /b 1
)