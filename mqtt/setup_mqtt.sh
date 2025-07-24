#!/bin/bash

# Script to set up MQTT directories for Docker

set -e  # Exit on error

echo "=== Setting up MQTT for SmartHomeLite ==="

# Create required directories
mkdir -p "$(dirname "$0")/config"
mkdir -p "$(dirname "$0")/data"
mkdir -p "$(dirname "$0")/log"

# Copy config file if it doesn't exist
if [ ! -f "$(dirname "$0")/config/mosquitto.conf" ]; then
    if [ -f "$(dirname "$0")/config/mosquitto.conf.example" ]; then
        cp "$(dirname "$0")/config/mosquitto.conf.example" "$(dirname "$0")/config/mosquitto.conf"
    else
        # Create a basic config file
        cat > "$(dirname "$0")/config/mosquitto.conf" << EOF
# Mosquitto MQTT Broker Configuration

# Basic configuration
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
log_type all

# Allow anonymous connections (for development)
allow_anonymous true

# Uncomment and modify for authentication
# password_file /mosquitto/config/passwd

# Listeners
listener 1883
protocol mqtt

listener 9001
protocol websockets
EOF
    fi
    echo "Created default mosquitto.conf file."
fi

# Set permissions
chmod -R 755 "$(dirname "$0")/config"
chmod -R 755 "$(dirname "$0")/data"
chmod -R 755 "$(dirname "$0")/log"

echo "=== MQTT setup complete ==="
echo "You can now start the MQTT broker using Docker Compose:"
echo "  docker-compose up -d mqtt"
echo ""
echo "To create MQTT users for authentication:"
echo "  ./mqtt/create_mqtt_user.sh <username> <password>"
echo ""