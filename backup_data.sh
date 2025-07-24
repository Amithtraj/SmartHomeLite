#!/bin/bash

# SmartHomeLite - Backup Data Script
# This script creates a backup of the SmartHomeLite data directory

echo "=== SmartHomeLite Data Backup ==="
echo "This script will create a backup of your SmartHomeLite data."
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}

# Check if data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Data directory '$DATA_DIR' does not exist."
    echo "Please run the application at least once to create the data directory."
    exit 1
fi

# Create backup directory if it doesn't exist
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

# Create a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/smarthome_data_$TIMESTAMP.tar.gz"

# Create the backup
echo "Creating backup of '$DATA_DIR' to '$BACKUP_FILE'..."
tar -czf "$BACKUP_FILE" "$DATA_DIR"

if [ $? -eq 0 ]; then
    echo "Backup created successfully!"
    echo "Backup file: $BACKUP_FILE"
    
    # List existing backups
    echo ""
    echo "Existing backups:"
    ls -lh "$BACKUP_DIR" | grep -v "^total" | awk '{print $9, "(" $5 ")"}'    
    
    # Check disk space
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    echo ""
    echo "Total backup size: $BACKUP_SIZE"
    
    # Cleanup old backups (keep last 5)
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" | wc -l)
    if [ "$BACKUP_COUNT" -gt 5 ]; then
        echo ""
        echo "Cleaning up old backups (keeping the 5 most recent)..."
        ls -t "$BACKUP_DIR" | tail -n +6 | xargs -I {} rm "$BACKUP_DIR/{}"
        echo "Cleanup complete."
    fi
    
    exit 0
else
    echo "Failed to create backup."
    echo "Please check permissions and disk space."
    exit 1
fi