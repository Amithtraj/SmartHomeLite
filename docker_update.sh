#!/bin/bash

# SmartHomeLite - Docker Update Script
# This script helps update the SmartHomeLite application running in Docker

echo "=== SmartHomeLite Docker Update ==="
echo "This script will update SmartHomeLite running in Docker."
echo ""

# Check for Docker installation
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH."
    echo "Please install Docker from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for Docker Compose installation
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed or not in PATH."
    echo "Please install Docker Compose from https://docs.docker.com/compose/install/"
    exit 1
fi

# Check for Git installation
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed or not in PATH."
    echo "Please install Git from https://git-scm.com/downloads"
    exit 1
fi

# Check if this is a Git repository
if [ ! -d ".git" ]; then
    echo "Error: This does not appear to be a Git repository."
    echo "This script is intended to be run from the root of the SmartHomeLite Git repository."
    exit 1
fi

# Pull latest changes from Git
echo "Pulling latest changes from Git repository..."
git pull

if [ $? -ne 0 ]; then
    echo ""
    echo "Failed to pull latest changes from Git repository."
    echo "Please resolve any conflicts and try again."
    exit 1
fi

# Check if containers are running
WAS_RUNNING=false
if docker-compose ps | grep -q "smarthome-lite"; then
    WAS_RUNNING=true
    echo "Stopping SmartHomeLite..."
    docker-compose down
fi

# Rebuild and start the containers
echo "Rebuilding SmartHomeLite..."
docker-compose build --no-cache smarthome-lite

if [ $? -ne 0 ]; then
    echo ""
    echo "Failed to rebuild SmartHomeLite."
    echo "Please check the error messages above."
    exit 1
fi

# Start the containers if they were running before
if [ "$WAS_RUNNING" = true ]; then
    echo "Starting SmartHomeLite..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "SmartHomeLite has been updated and restarted successfully."
        echo "You can access the web interface at:"
        echo "  http://localhost:8000"
    else
        echo ""
        echo "Failed to start SmartHomeLite after update."
        echo "Please check the error messages above."
        exit 1
    fi
else
    echo ""
    echo "SmartHomeLite has been updated successfully."
    echo "You can start it with ./docker_run.sh"
fi

exit 0