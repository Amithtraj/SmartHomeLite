#!/bin/bash

# SmartHomeLite - Docker Restart Script
# This script helps restart the SmartHomeLite application running in Docker

echo "=== SmartHomeLite Docker Restart ==="
echo "This script will restart SmartHomeLite running in Docker."
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

# Check if containers are running
if ! docker-compose ps | grep -q "smarthome-lite"; then
    echo "SmartHomeLite is not currently running."
    echo "Starting it instead..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "SmartHomeLite has been started successfully."
        exit 0
    else
        echo ""
        echo "Failed to start SmartHomeLite."
        echo "Please check the error messages above."
        exit 1
    fi
fi

# Restart the container
echo "Restarting SmartHomeLite..."
docker-compose restart smarthome-lite

# Check if restart was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "SmartHomeLite has been restarted successfully."
    echo "You can access the web interface at:"
    echo "  http://localhost:8000"
    exit 0
else
    echo ""
    echo "Failed to restart SmartHomeLite."
    echo "Please check the error messages above."
    exit 1
fi