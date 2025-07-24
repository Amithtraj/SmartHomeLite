#!/bin/bash

# SmartHomeLite - Generate Sample Device Script
# This script generates a sample device configuration file

echo "=== SmartHomeLite Sample Device Generator ==="
echo "This script will generate a sample device configuration file."
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}
DEVICES_DIR="$DATA_DIR/devices"

# Create the devices directory if it doesn't exist
mkdir -p "$DEVICES_DIR"

# Check if devices.json exists
DEVICES_FILE="$DEVICES_DIR/devices.json"
if [ ! -f "$DEVICES_FILE" ]; then
    echo "Creating empty devices.json file..."
    echo '[]' > "$DEVICES_FILE"
fi

# Ask for device type
echo "Select device type:"
echo "1. Light"
echo "2. Thermostat"
echo "3. Lock"
echo "4. Camera"
echo "5. Speaker"
echo "6. Sensor"
read -p "Enter choice [1-6]: " DEVICE_TYPE_CHOICE

# Set device type based on choice
case $DEVICE_TYPE_CHOICE in
    1) DEVICE_TYPE="light";;
    2) DEVICE_TYPE="thermostat";;
    3) DEVICE_TYPE="lock";;
    4) DEVICE_TYPE="camera";;
    5) DEVICE_TYPE="speaker";;
    6) DEVICE_TYPE="sensor";;
    *) echo "Invalid choice. Using 'light' as default."; DEVICE_TYPE="light";;
esac

# Ask for connection type
echo ""
echo "Select connection type:"
echo "1. Bluetooth"
echo "2. MQTT"
echo "3. HTTP"
read -p "Enter choice [1-3]: " CONNECTION_TYPE_CHOICE

# Set connection type based on choice
case $CONNECTION_TYPE_CHOICE in
    1) CONNECTION_TYPE="bluetooth";;
    2) CONNECTION_TYPE="mqtt";;
    3) CONNECTION_TYPE="http";;
    *) echo "Invalid choice. Using 'mqtt' as default."; CONNECTION_TYPE="mqtt";;
esac

# Generate a unique device ID
DEVICE_ID="sample_${DEVICE_TYPE}_$(date +%s)"

# Ask for device name
echo ""
read -p "Enter device name [Sample $DEVICE_TYPE]: " DEVICE_NAME
DEVICE_NAME=${DEVICE_NAME:-"Sample $DEVICE_TYPE"}

# Create device configuration based on type
echo ""
echo "Generating sample $DEVICE_TYPE device configuration..."

# Create the device JSON structure
case $DEVICE_TYPE in
    "light")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"power":"off","brightness":50,"color":"#FFFFFF"},"actions":["turn_on","turn_off","set_brightness","set_color"],"config":{"room":"Living Room"}}'
        ;;
    "thermostat")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"power":"off","temperature":21,"target_temperature":22,"mode":"heat"},"actions":["turn_on","turn_off","set_temperature","set_mode"],"config":{"room":"Living Room","modes":["heat","cool","auto","off"]}}'
        ;;
    "lock")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"state":"locked","battery":100},"actions":["lock","unlock"],"config":{"room":"Front Door"}}'
        ;;
    "camera")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"power":"off","recording":false,"motion_detected":false},"actions":["turn_on","turn_off","start_recording","stop_recording"],"config":{"room":"Front Door","resolution":"1080p","stream_url":"http://localhost:8080/stream"}}'
        ;;
    "speaker")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"power":"off","volume":50,"playing":false,"current_track":"None"},"actions":["turn_on","turn_off","set_volume","play","pause","next_track"],"config":{"room":"Living Room"}}'
        ;;
    "sensor")
        DEVICE_JSON='{"id":"'$DEVICE_ID'","name":"'$DEVICE_NAME'","type":"'$DEVICE_TYPE'","connection_type":"'$CONNECTION_TYPE'","status":"offline","properties":{"temperature":21,"humidity":45,"battery":100},"actions":[],"config":{"room":"Living Room","update_interval":60}}'
        ;;
esac

# Add connection-specific configuration
case $CONNECTION_TYPE in
    "bluetooth")
        # Extract the device JSON without the closing brace
        DEVICE_JSON_WITHOUT_BRACE=${DEVICE_JSON%?}
        # Add Bluetooth-specific configuration
        DEVICE_JSON="$DEVICE_JSON_WITHOUT_BRACE,\"connection_config\":{\"address\":\"00:11:22:33:44:55\",\"service_uuid\":\"0000180a-0000-1000-8000-00805f9b34fb\"}}" 
        ;;
    "mqtt")
        # Extract the device JSON without the closing brace
        DEVICE_JSON_WITHOUT_BRACE=${DEVICE_JSON%?}
        # Add MQTT-specific configuration
        DEVICE_JSON="$DEVICE_JSON_WITHOUT_BRACE,\"connection_config\":{\"broker\":\"localhost\",\"port\":1883,\"topic\":\"smarthome/$DEVICE_TYPE/$DEVICE_ID\"}}" 
        ;;
    "http")
        # Extract the device JSON without the closing brace
        DEVICE_JSON_WITHOUT_BRACE=${DEVICE_JSON%?}
        # Add HTTP-specific configuration
        DEVICE_JSON="$DEVICE_JSON_WITHOUT_BRACE,\"connection_config\":{\"url\":\"http://localhost:8080/api/devices/$DEVICE_ID\"}}" 
        ;;
esac

# Read the current devices.json file
CURRENT_DEVICES=$(cat "$DEVICES_FILE")

# Check if the file is empty or not a valid JSON array
if [ "$CURRENT_DEVICES" == "" ] || [ "$CURRENT_DEVICES" == "[]" ]; then
    # If empty, create a new array with just this device
    echo "[$DEVICE_JSON]" > "$DEVICES_FILE"
else
    # If not empty, append this device to the array
    # Remove the closing bracket, add the new device, and close the array
    CURRENT_DEVICES_WITHOUT_BRACKET=${CURRENT_DEVICES%?}
    echo "$CURRENT_DEVICES_WITHOUT_BRACKET,$DEVICE_JSON]" > "$DEVICES_FILE"
fi

# Create a standalone file for this device
SAMPLE_FILE="$DEVICES_DIR/${DEVICE_ID}.json"
echo "$DEVICE_JSON" > "$SAMPLE_FILE"

echo ""
echo "=== Sample Device Created! ==="
echo "Device ID: $DEVICE_ID"
echo "Device Type: $DEVICE_TYPE"
echo "Connection Type: $CONNECTION_TYPE"
echo ""
echo "The device has been added to: $DEVICES_FILE"
echo "A standalone device file has been created at: $SAMPLE_FILE"
echo ""
echo "You can now start the application to see the sample device."