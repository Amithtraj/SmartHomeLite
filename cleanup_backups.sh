#!/bin/bash

# SmartHomeLite - Cleanup Backups Script
# This script helps clean up old backup files to save disk space

echo "=== SmartHomeLite Backup Cleanup ==="
echo "This script will help you clean up old backup files to save disk space."
echo ""

# Check if backup directory exists
BACKUP_DIR="./backups"
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory '$BACKUP_DIR' does not exist."
    echo "No backups found to clean up."
    exit 1
fi

# List available backups
BACKUP_FILES=($(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
BACKUP_COUNT=${#BACKUP_FILES[@]}

if [ "$BACKUP_COUNT" -eq 0 ]; then
    echo "No backup files found in '$BACKUP_DIR'."
    exit 1
fi

# Display backup information
echo "Found $BACKUP_COUNT backup files in '$BACKUP_DIR'."
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "Total size of all backups: $TOTAL_SIZE"
echo ""

# List backups with details
echo "Backup files (sorted by date, newest first):"
echo "------------------------------------------"
ls -lt "$BACKUP_DIR"/*.tar.gz | awk '{print $6, $7, $8, $9, "(" $5 ")"}'
echo ""

# Ask how many backups to keep
echo "How many recent backups would you like to keep?"
echo "(Recommended: 3-5 backups, enter 0 to cancel)"
read -r KEEP_COUNT

# Validate input
if ! [[ "$KEEP_COUNT" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a number."
    exit 1
fi

if [ "$KEEP_COUNT" -eq 0 ]; then
    echo "Operation cancelled. No backups were deleted."
    exit 0
fi

if [ "$KEEP_COUNT" -ge "$BACKUP_COUNT" ]; then
    echo "You chose to keep $KEEP_COUNT backups, but there are only $BACKUP_COUNT backups."
    echo "No backups will be deleted."
    exit 0
fi

# Calculate how many backups to delete
DELETE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
TO_DELETE=($(ls -t "$BACKUP_DIR"/*.tar.gz | tail -n "$DELETE_COUNT"))

# Show which backups will be deleted
echo "The following $DELETE_COUNT backup(s) will be deleted:"
for file in "${TO_DELETE[@]}"; do
    SIZE=$(du -h "$file" | cut -f1)
    echo "$(basename "$file") ($SIZE)"
done

# Confirm deletion
echo ""
echo "Are you sure you want to delete these backups? (y/N):"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled. No backups were deleted."
    exit 0
fi

# Delete the backups
echo ""
echo "Deleting old backups..."
for file in "${TO_DELETE[@]}"; do
    echo "Deleting: $(basename "$file")"
    rm "$file"
done

# Show results
NEW_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo ""
echo "Cleanup complete!"
echo "Kept the $KEEP_COUNT most recent backup(s)."
echo "Deleted $DELETE_COUNT old backup(s)."
echo "New total backup size: $NEW_SIZE (was $TOTAL_SIZE)"