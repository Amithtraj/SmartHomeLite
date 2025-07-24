#!/bin/bash

# SmartHomeLite - Docker Logs Script
# This script helps view logs of the SmartHomeLite application running in Docker

echo "=== SmartHomeLite Docker Logs ==="
echo "This script will show logs of SmartHomeLite running in Docker."
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
    echo "Start it first with ./docker_run.sh"
    exit 1
fi

# Show logs
echo "Showing SmartHomeLite logs (press Ctrl+C to exit)..."
echo ""
docker-compose logs -f smarthome-lite