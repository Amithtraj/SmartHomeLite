#!/bin/bash

# SmartHomeLite - Termux Setup Script
# This script helps set up the SmartHomeLite application on Termux (Android)

set -e  # Exit on error

echo "=== SmartHomeLite Termux Setup ==="
echo "This script will install the necessary packages and set up SmartHomeLite on your Android device."
echo ""

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "Error: This script must be run in Termux on Android."
    exit 1
fi

echo "=== Installing required packages ==="
pkg update -y
pkg install -y python python-pip git libbluetooth-dev bluez

# Request necessary permissions for Termux
echo "=== Requesting permissions ==="
echo "SmartHomeLite needs additional permissions to access Bluetooth and microphone."
echo "Please grant the requested permissions when prompted."

termux-setup-storage

# Clone the repository if it doesn't exist
if [ ! -d "SmartHomeLite" ]; then
    echo "=== Cloning SmartHomeLite repository ==="
    git clone https://github.com/yourusername/SmartHomeLite.git
    cd SmartHomeLite
else
    echo "=== Updating SmartHomeLite repository ==="
    cd SmartHomeLite
    git pull
fi

# Create virtual environment and install dependencies
echo "=== Setting up Python environment ==="
python -m venv venv
source venv/bin/activate

# Install dependencies
echo "=== Installing Python dependencies ==="
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "=== Creating configuration file ==="
    cp example.env .env
    echo "Created .env file. You may want to edit it with your preferred settings."
fi

# Create data directory
echo "=== Creating data directory ==="
mkdir -p data

# Setup complete
echo ""
echo "=== Setup Complete! ==="
echo "To start SmartHomeLite, run:"
echo "  cd $(pwd)"
echo "  source venv/bin/activate"
echo "  python run.py"
echo ""
echo "You can then access the web interface at:"
echo "  http://localhost:8000"
echo ""
echo "To access from other devices on your network, use your device's IP address instead of localhost."