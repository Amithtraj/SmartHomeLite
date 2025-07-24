#!/bin/bash

# SmartHomeLite - Docker Stop Script
# This script helps stop the SmartHomeLite application running in Docker

echo "=== SmartHomeLite Docker Stop ==="
echo "This script will stop SmartHomeLite running in Docker."
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
    exit 0
fi

# Stop the containers
echo "Stopping SmartHomeLite..."
docker-compose down

# Check if shutdown was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "SmartHomeLite has been stopped successfully."
    exit 0
else
    echo ""
    echo "Failed to stop SmartHomeLite."
    echo "Please check the error messages above."
    exit 1
fi