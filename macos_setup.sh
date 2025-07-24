#!/bin/bash

# SmartHomeLite - macOS Setup Script
# This script helps set up the SmartHomeLite application on macOS

set -e  # Exit on error

echo "=== SmartHomeLite macOS Setup ==="
echo "This script will install the necessary packages and set up SmartHomeLite on your Mac."
echo ""

# Check for Homebrew installation
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ $(uname -m) == "arm64" ]]; then
        # For Apple Silicon Macs
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # For Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "=== Installing system dependencies ==="
brew update
brew install python@3.11 git bluetooth-connector

# Check for Python installation
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed or not in PATH."
    exit 1
fi

# Create virtual environment
echo "=== Creating virtual environment ==="
python3 -m venv venv
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

# Create start script
echo "=== Creating start script ==="
cat > start_app.sh << EOF
#!/bin/bash
source "$(pwd)/venv/bin/activate"
python "$(pwd)/run.py"
EOF

chmod +x start_app.sh

# Setup complete
echo ""
echo "=== Setup Complete! ==="
echo "To start SmartHomeLite, run:"
echo "  ./start_app.sh"
echo ""
echo "You can then access the web interface at:"
echo "  http://localhost:8000"
echo ""
echo "Note: You may need to grant Bluetooth permissions to Terminal in System Preferences > Security & Privacy > Privacy > Bluetooth."