#!/bin/bash

# SmartHomeLite - Check Status Script
# This script checks the status of the SmartHomeLite application

echo "=== SmartHomeLite Status Check ==="
echo "This script will check the status of your SmartHomeLite application."
echo ""

# Get the data directory from environment variable or use default
DATA_DIR=${DATA_DIR:-"./data"}

# Check if data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "❌ Data directory '$DATA_DIR' does not exist."
    echo "   The application may not be properly set up."
    echo "   Run create_data_dir.sh to create the data directory."
else
    echo "✅ Data directory exists: $DATA_DIR"
    
    # Check devices directory
    if [ -d "$DATA_DIR/devices" ]; then
        echo "✅ Devices directory exists: $DATA_DIR/devices"
        
        # Check devices.json file
        if [ -f "$DATA_DIR/devices/devices.json" ]; then
            echo "✅ Devices configuration file exists: $DATA_DIR/devices/devices.json"
            
            # Count devices
            DEVICE_COUNT=$(grep -o '"id":' "$DATA_DIR/devices/devices.json" | wc -l)
            echo "   Found $DEVICE_COUNT device(s) in configuration."
        else
            echo "❌ Devices configuration file does not exist: $DATA_DIR/devices/devices.json"
            echo "   Run generate_sample_device.sh to create a sample device."
        fi
    else
        echo "❌ Devices directory does not exist: $DATA_DIR/devices"
    fi
    
    # Check logs directory
    if [ -d "$DATA_DIR/logs" ]; then
        echo "✅ Logs directory exists: $DATA_DIR/logs"
        
        # Count log files
        LOG_COUNT=$(find "$DATA_DIR/logs" -type f | wc -l)
        echo "   Found $LOG_COUNT log file(s)."
    else
        echo "❌ Logs directory does not exist: $DATA_DIR/logs"
    fi
    
    # Check voice directory
    if [ -d "$DATA_DIR/voice" ]; then
        echo "✅ Voice directory exists: $DATA_DIR/voice"
    else
        echo "❌ Voice directory does not exist: $DATA_DIR/voice"
    fi
fi

# Check .env file
if [ -f ".env" ]; then
    echo "✅ Environment file exists: .env"
    
    # Check if .env file has required variables
    if grep -q "HOST" ".env" && grep -q "PORT" ".env"; then
        echo "✅ Environment file contains basic configuration."
    else
        echo "⚠️ Environment file may be missing some configuration."
        echo "   Check example.env for required variables."
    fi
else
    echo "❌ Environment file does not exist: .env"
    echo "   Copy example.env to .env to set up the environment."
fi

# Check if application is running
echo ""
echo "Checking if application is running..."
PID=$(pgrep -f "python.*run\.py")

if [ -n "$PID" ]; then
    echo "✅ Application is running with PID: $PID"
    
    # Get the port from the process
    PORT=$(netstat -tlnp 2>/dev/null | grep "$PID" | awk '{print $4}' | awk -F: '{print $NF}' | head -1)
    
    if [ -n "$PORT" ]; then
        echo "✅ Application is listening on port: $PORT"
        echo "   You can access the web interface at: http://localhost:$PORT"
    else
        echo "⚠️ Could not determine the port the application is listening on."
    fi
else
    echo "❌ Application is not running."
    echo "   Start the application with: python run.py"
fi

# Check for Docker
if command -v docker &> /dev/null; then
    echo ""
    echo "Checking Docker status..."
    
    # Check if Docker container is running
    if docker ps | grep -q "smarthome-lite"; then
        echo "✅ Docker container is running."
        
        # Get the port mapping
        PORT_MAPPING=$(docker ps | grep "smarthome-lite" | grep -o "0.0.0.0:[0-9]*->8000/tcp" | head -1)
        
        if [ -n "$PORT_MAPPING" ]; then
            PORT=$(echo "$PORT_MAPPING" | cut -d':' -f2 | cut -d'-' -f1)
            echo "✅ Docker container is exposing port: $PORT"
            echo "   You can access the web interface at: http://localhost:$PORT"
        else
            echo "⚠️ Could not determine the port mapping for the Docker container."
        fi
    else
        echo "❌ Docker container is not running."
        echo "   Start the Docker container with: docker-compose up -d"
    fi
fi

# Check for MQTT broker
if command -v mosquitto &> /dev/null || command -v mosquitto_sub &> /dev/null; then
    echo ""
    echo "Checking MQTT broker status..."
    
    # Try to connect to MQTT broker
    timeout 2 mosquitto_sub -t "test" -C 1 &> /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ MQTT broker is running and accessible."
    else
        echo "❌ MQTT broker is not running or not accessible."
        echo "   Start the MQTT broker if you want to use MQTT devices."
    fi
fi

echo ""
echo "=== Status Check Complete! ==="