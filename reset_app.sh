#!/bin/bash

# SmartHomeLite - Reset Application Script
# This script resets the application to its initial state

echo "=== SmartHomeLite Reset Application ==="
echo "This script will reset the application to its initial state."
echo "WARNING: This will delete all your devices and settings!"
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}

# Check if data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "Data directory '$DATA_DIR' does not exist."
    echo "Nothing to reset."
    exit 0
fi

# Ask for confirmation
echo "Are you ABSOLUTELY SURE you want to reset the application?"
echo "This will delete all your devices and settings!"
echo "Type 'RESET' (all caps) to confirm:"
read -r CONFIRM

if [ "$CONFIRM" != "RESET" ]; then
    echo "Reset cancelled."
    exit 0
fi

# Create a backup before resetting
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/pre_reset_$TIMESTAMP.tar.gz"

echo ""
echo "Creating backup before reset to '$BACKUP_FILE'..."
tar -czf "$BACKUP_FILE" "$DATA_DIR"

if [ $? -ne 0 ]; then
    echo "Warning: Failed to create backup. Do you want to continue anyway? (y/N):"
    read -r CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "Reset cancelled."
        exit 0
    fi
else
    echo "Backup created successfully."
fi

# Reset the application
echo ""
echo "Resetting application..."

# Remove the data directory
rm -rf "$DATA_DIR"

# Create a fresh data directory structure
mkdir -p "$DATA_DIR/devices"
mkdir -p "$DATA_DIR/logs"
mkdir -p "$DATA_DIR/voice"

# Create an empty devices.json file
echo '[]' > "$DATA_DIR/devices/devices.json"

# Reset .env file if it exists
if [ -f ".env" ] && [ -f "example.env" ]; then
    echo "Resetting .env file from example.env..."
    cp example.env .env
fi

echo ""
echo "=== Reset Complete! ==="
echo "The application has been reset to its initial state."
echo "A backup of your previous data was created at: $BACKUP_FILE"
echo "You can now start the application with a fresh configuration."