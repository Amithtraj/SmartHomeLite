#!/bin/bash

# SmartHomeLite - Docker Setup Script
# This script helps set up the SmartHomeLite application using Docker

set -e  # Exit on error

echo "=== SmartHomeLite Docker Setup ==="
echo "This script will set up SmartHomeLite using Docker."
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

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "=== Creating configuration file ==="
    cp example.env .env
    echo "Created .env file. You may want to edit it with your preferred settings."
fi

# Create data directory
echo "=== Creating data directory ==="
mkdir -p data

# Set up MQTT if needed
echo "=== Setting up MQTT ==="
chmod +x mqtt/setup_mqtt.sh
./mqtt/setup_mqtt.sh

# Build and start the containers
echo "=== Building and starting containers ==="
docker-compose build
docker-compose up -d

# Setup complete
echo ""
echo "=== Setup Complete! ==="
echo "SmartHomeLite is now running in Docker."
echo "You can access the web interface at:"
echo "  http://localhost:8000"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f smarthome-lite"
echo ""
echo "To stop the application:"
echo "  docker-compose down"
echo ""
echo "Note: For Bluetooth functionality, the container needs access to the host's Bluetooth hardware."
echo "This may require additional configuration depending on your system."