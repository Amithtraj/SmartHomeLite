#!/bin/bash

# SmartHomeLite - Check Requirements Script
# This script checks if the system meets the requirements for running SmartHomeLite

echo "=== SmartHomeLite Requirements Check ==="
echo "This script will check if your system meets the requirements for running SmartHomeLite."
echo ""

# Function to check if a command is available
check_command() {
    if command -v "$1" &> /dev/null; then
        echo "✅ $2 is installed."
        return 0
    else
        echo "❌ $2 is not installed."
        return 1
    fi
}

# Function to check Python version
check_python_version() {
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version 2>&1 | awk '{print $2}')
        python_major=$(echo "$python_version" | cut -d. -f1)
        python_minor=$(echo "$python_version" | cut -d. -f2)
        
        if [ "$python_major" -ge 3 ] && [ "$python_minor" -ge 11 ]; then
            echo "✅ Python $python_version is installed (required: 3.11+)."
            return 0
        else
            echo "❌ Python $python_version is installed, but version 3.11+ is required."
            return 1
        fi
    else
        echo "❌ Python 3 is not installed."
        return 1
    fi
}

# Function to check if a Python package is installed
check_python_package() {
    if python3 -c "import $1" &> /dev/null; then
        echo "✅ Python package '$1' is installed."
        return 0
    else
        echo "❌ Python package '$1' is not installed."
        return 1
    fi
}

# Check operating system
echo "=== Operating System ==="
os_name=$(uname -s)
case "$os_name" in
    Linux*)
        echo "✅ Operating System: Linux"
        ;;
    Darwin*)
        echo "✅ Operating System: macOS"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo "✅ Operating System: Windows (Cygwin/MinGW/MSYS)"
        ;;
    *)
        echo "⚠️ Operating System: $os_name (not officially supported)"
        ;;
esac
echo ""

# Check required commands
echo "=== Required Commands ==="
required_commands_ok=true

check_command python3 "Python 3" || required_commands_ok=false
check_command pip3 "Pip (Python package manager)" || required_commands_ok=false
check_command git "Git" || required_commands_ok=false

echo ""

# Check Python version
echo "=== Python Version ==="
python_version_ok=true
check_python_version || python_version_ok=false
echo ""

# Check Bluetooth
echo "=== Bluetooth Support ==="
bluetooth_ok=true

if [ "$os_name" = "Linux" ]; then
    if check_command bluetoothctl "Bluetooth control utility"; then
        # Check if Bluetooth adapter is available
        if bluetoothctl list | grep -q "Controller"; then
            echo "✅ Bluetooth adapter is available."
        else
            echo "❌ No Bluetooth adapter found."
            bluetooth_ok=false
        fi
    else
        bluetooth_ok=false
    fi
    
    # Check for libbluetooth-dev
    if [ -f "/usr/include/bluetooth/bluetooth.h" ]; then
        echo "✅ Bluetooth development libraries are installed."
    else
        echo "❌ Bluetooth development libraries are not installed."
        echo "   Install with: sudo apt-get install libbluetooth-dev (Debian/Ubuntu)"
        echo "   or: sudo dnf install bluez-libs-devel (Fedora/RHEL)"
        bluetooth_ok=false
    fi
elif [ "$os_name" = "Darwin" ]; then
    # macOS has built-in Bluetooth support
    echo "✅ macOS has built-in Bluetooth support."
else
    echo "⚠️ Bluetooth support check not implemented for this OS."
    echo "   You may need to install Bluetooth drivers or libraries."
    bluetooth_ok=false
fi
echo ""

# Check optional components
echo "=== Optional Components ==="

# Check MQTT broker
if check_command mosquitto "Mosquitto MQTT broker"; then
    echo "✅ MQTT broker is available for local messaging."
else
    echo "⚠️ MQTT broker is not installed (optional for MQTT device support)."
    echo "   Install with: sudo apt-get install mosquitto (Debian/Ubuntu)"
    echo "   or: brew install mosquitto (macOS with Homebrew)"
fi

# Check for voice recognition dependencies
echo ""
echo "Voice Recognition Dependencies:"
if check_command arecord "Audio recording utility" || [ "$os_name" = "Darwin" ]; then
    echo "✅ Audio recording is available."
else
    echo "⚠️ Audio recording utility not found (required for voice control)."
    echo "   Install with: sudo apt-get install alsa-utils (Debian/Ubuntu)"
fi

# Summary
echo ""
echo "=== Summary ==="
all_ok=true

if [ "$required_commands_ok" = true ]; then
    echo "✅ All required commands are available."
else
    echo "❌ Some required commands are missing."
    all_ok=false
fi

if [ "$python_version_ok" = true ]; then
    echo "✅ Python version is sufficient."
else
    echo "❌ Python version is insufficient."
    all_ok=false
fi

if [ "$bluetooth_ok" = true ]; then
    echo "✅ Bluetooth support is available."
else
    echo "⚠️ Bluetooth support may be limited or unavailable."
    # Don't fail for Bluetooth, as it's technically optional
fi

echo ""
if [ "$all_ok" = true ]; then
    echo "✅ Your system meets the basic requirements for running SmartHomeLite."
    echo "   You can proceed with the installation."
    exit 0
else
    echo "❌ Your system does not meet all requirements for running SmartHomeLite."
    echo "   Please install the missing components before proceeding."
    exit 1
fi