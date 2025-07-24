#!/bin/bash

# SmartHomeLite - Docker Run Script
# This script helps run the SmartHomeLite application using Docker

set -e  # Exit on error

echo "=== SmartHomeLite Docker Run ==="
echo "This script will start SmartHomeLite using Docker."
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

# Check if containers are already running
if docker-compose ps | grep -q "smarthome-lite"; then
    echo "SmartHomeLite is already running."
    echo ""
    echo "To view logs:"
    echo "  docker-compose logs -f smarthome-lite"
    echo ""
    echo "To stop the application:"
    echo "  docker-compose down"
    echo ""
    echo "To restart the application:"
    echo "  docker-compose restart smarthome-lite"
    exit 0
fi

# Start the containers
echo "Starting SmartHomeLite..."
docker-compose up -d

# Check if startup was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "SmartHomeLite is now running."
    echo "You can access the web interface at:"
    echo "  http://localhost:8000"
    echo ""
    echo "To view logs:"
    echo "  docker-compose logs -f smarthome-lite"
    echo ""
    echo "To stop the application:"
    echo "  docker-compose down"
    exit 0
else
    echo ""
    echo "Failed to start SmartHomeLite."
    echo "Please check the error messages above."
    exit 1
fi