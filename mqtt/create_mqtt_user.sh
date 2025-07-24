#!/bin/bash

# Script to create MQTT users for production use

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
 fi

USERNAME=$1
PASSWORD=$2

# Check if mosquitto_passwd is available
if ! command -v mosquitto_passwd &> /dev/null; then
    echo "Error: mosquitto_passwd command not found."
    echo "Please install the Mosquitto clients package:"
    echo "  - On Debian/Ubuntu: sudo apt-get install mosquitto-clients"
    echo "  - On RHEL/CentOS: sudo yum install mosquitto-clients"
    echo "  - On macOS: brew install mosquitto"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$0")/config"

# Path to password file
PASSWD_FILE="$(dirname "$0")/config/passwd"

# Create or update password file
if [ ! -f "$PASSWD_FILE" ]; then
    # Create new password file
    mosquitto_passwd -c "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
else
    # Add or update user in existing file
    mosquitto_passwd "$PASSWD_FILE" "$USERNAME" "$PASSWORD"
fi

if [ $? -eq 0 ]; then
    echo "User '$USERNAME' created successfully."
    echo "To enable authentication, edit mosquitto.conf and:"
    echo "1. Uncomment the 'password_file' line"
    echo "2. Set 'allow_anonymous' to 'false'"
    echo "3. Restart the MQTT broker"
else
    echo "Failed to create user."
    exit 1
fi