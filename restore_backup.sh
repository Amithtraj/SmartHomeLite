#!/bin/bash

# SmartHomeLite - Restore Backup Script
# This script restores a backup of the SmartHomeLite data directory

echo "=== SmartHomeLite Backup Restore ==="
echo "This script will restore your SmartHomeLite data from a backup."
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}

# Check if backup directory exists
BACKUP_DIR="./backups"
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory '$BACKUP_DIR' does not exist."
    echo "No backups found to restore from."
    exit 1
fi

# List available backups
echo "Available backups:"
BACKUP_FILES=($(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
BACKUP_COUNT=${#BACKUP_FILES[@]}

if [ "$BACKUP_COUNT" -eq 0 ]; then
    echo "No backup files found in '$BACKUP_DIR'."
    exit 1
fi

# Display backups with numbers
for i in $(seq 0 $((BACKUP_COUNT-1))); do
    FILE=${BACKUP_FILES[$i]}
    SIZE=$(du -h "$FILE" | cut -f1)
    DATE=$(date -r "$FILE" "+%Y-%m-%d %H:%M:%S")
    echo "[$i] $(basename "$FILE") ($SIZE) - $DATE"
done

# Ask user to select a backup
echo ""
echo "Enter the number of the backup to restore [0-$((BACKUP_COUNT-1))]:"
read -r SELECTION

# Validate selection
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "$BACKUP_COUNT" ]; then
    echo "Invalid selection. Please enter a number between 0 and $((BACKUP_COUNT-1))."
    exit 1
fi

SELECTED_BACKUP=${BACKUP_FILES[$SELECTION]}
echo ""
echo "Selected backup: $(basename "$SELECTED_BACKUP")"

# Confirm before proceeding
echo ""
echo "WARNING: This will replace your current data with the backup."
echo "Any changes made since the backup was created will be lost."
echo ""
echo "Do you want to continue? (y/N):"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Create a backup of current data before restoring
CURRENT_BACKUP="$BACKUP_DIR/pre_restore_$(date +"%Y%m%d_%H%M%S").tar.gz"
if [ -d "$DATA_DIR" ]; then
    echo ""
    echo "Creating backup of current data to '$CURRENT_BACKUP'..."
    tar -czf "$CURRENT_BACKUP" "$DATA_DIR"
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to backup current data. Proceeding with restore anyway."
    else
        echo "Current data backed up successfully."
    fi
fi

# Restore the selected backup
echo ""
echo "Restoring from backup..."

# Remove existing data directory
if [ -d "$DATA_DIR" ]; then
    echo "Removing existing data directory..."
    rm -rf "$DATA_DIR"
fi

# Extract the backup
echo "Extracting backup..."
tar -xzf "$SELECTED_BACKUP"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Restore Complete! ==="
    echo "Your data has been restored from the backup."
    echo "You can now start the application."
    exit 0
else
    echo ""
    echo "Error: Failed to restore from backup."
    echo "If you backed up current data, you can find it at: $CURRENT_BACKUP"
    exit 1
fi