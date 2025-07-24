#!/bin/bash

# SmartHomeLite - Create Data Directory Script
# This script creates the data directory for the SmartHomeLite application

echo "=== SmartHomeLite Create Data Directory ==="
echo "This script will create the data directory for SmartHomeLite."
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}

# Create the data directory
echo "Creating data directory at $DATA_DIR..."
mkdir -p "$DATA_DIR"

if [ $? -eq 0 ]; then
    echo "Data directory created successfully."
    
    # Create subdirectories
    mkdir -p "$DATA_DIR/devices"
    mkdir -p "$DATA_DIR/logs"
    mkdir -p "$DATA_DIR/voice"
    
    # Create an empty devices.json file if it doesn't exist
    if [ ! -f "$DATA_DIR/devices/devices.json" ]; then
        echo "Creating empty devices.json file..."
        echo '[]' > "$DATA_DIR/devices/devices.json"
    fi
    
    echo ""
    echo "=== Setup Complete! ==="
    echo "The following directories have been created:"
    echo "  $DATA_DIR"
    echo "  $DATA_DIR/devices"
    echo "  $DATA_DIR/logs"
    echo "  $DATA_DIR/voice"
    echo ""
    echo "An empty devices.json file has been created at:"
    echo "  $DATA_DIR/devices/devices.json"
    exit 0
else
    echo "Failed to create data directory."
    echo "Please check permissions and try again."
    exit 1
fi