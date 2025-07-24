@echo off
REM SmartHomeLite - Windows Setup Script
REM This script helps set up the SmartHomeLite application on Windows

echo === SmartHomeLite Windows Setup ===
echo This script will set up SmartHomeLite on your Windows system.
echo.

REM Check for Python installation
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Python is not installed or not in PATH.
    echo Please install Python 3.11 or newer from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

REM Check Python version
for /f "tokens=2" %%V in ('python --version 2^>^&1') do set PYTHON_VERSION=%%V
echo Found Python %PYTHON_VERSION%

REM Create virtual environment
echo === Creating virtual environment ===
if not exist venv (
    python -m venv venv
) else (
    echo Virtual environment already exists.
)

REM Activate virtual environment and install dependencies
echo === Installing dependencies ===
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

REM Create .env file if it doesn't exist
if not exist .env (
    echo === Creating configuration file ===
    copy example.env .env
    echo Created .env file. You may want to edit it with your preferred settings.
)

REM Create data directory
echo === Creating data directory ===
if not exist data mkdir data

REM Setup complete
echo.
echo === Setup Complete! ===
echo To start SmartHomeLite, run:
echo   start_app.bat
echo.
echo You can then access the web interface at:
echo   http://localhost:8000
echo.

REM Create start script
echo === Creating start script ===
echo @echo off > start_app.bat
echo call venv\Scripts\activate.bat >> start_app.bat
echo python run.py >> start_app.bat

echo Press any key to exit...
pause > nul