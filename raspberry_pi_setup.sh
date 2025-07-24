#!/bin/bash

# SmartHomeLite - Raspberry Pi Setup Script
# This script helps set up the SmartHomeLite application on a Raspberry Pi

set -e  # Exit on error

echo "=== SmartHomeLite Raspberry Pi Setup ==="
echo "This script will install the necessary packages and set up SmartHomeLite on your Raspberry Pi."
echo ""

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "=== Installing system dependencies ==="
apt-get update
apt-get install -y python3 python3-pip python3-venv git bluetooth bluez libbluetooth-dev pkg-config libportaudio2 portaudio19-dev mosquitto mosquitto-clients

# Create a directory for the application
echo "=== Creating application directory ==="
mkdir -p /opt/smarthome-lite
chown -R pi:pi /opt/smarthome-lite

# Clone the repository
echo "=== Cloning SmartHomeLite repository ==="
cd /opt/smarthome-lite
if [ -d "SmartHomeLite" ]; then
    echo "Repository already exists, updating..."
    cd SmartHomeLite
    git pull
else
    git clone https://github.com/yourusername/SmartHomeLite.git
    cd SmartHomeLite
fi

# Set ownership
chown -R pi:pi /opt/smarthome-lite

# Create virtual environment and install dependencies
echo "=== Setting up Python environment ==="
su - pi -c "cd /opt/smarthome-lite/SmartHomeLite && python3 -m venv venv"
su - pi -c "cd /opt/smarthome-lite/SmartHomeLite && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"

# Create .env file if it doesn't exist
if [ ! -f "/opt/smarthome-lite/SmartHomeLite/.env" ]; then
    echo "=== Creating configuration file ==="
    su - pi -c "cd /opt/smarthome-lite/SmartHomeLite && cp example.env .env"
    echo "Created .env file. You may want to edit it with your preferred settings."
fi

# Create data directory
echo "=== Creating data directory ==="
su - pi -c "mkdir -p /opt/smarthome-lite/SmartHomeLite/data"

# Create systemd service
echo "=== Creating systemd service ==="
cat > /etc/systemd/system/smarthome-lite.service << EOF
[Unit]
Description=SmartHomeLite - Local Smart Home Hub
After=network.target bluetooth.target

[Service]
User=pi
WorkingDirectory=/opt/smarthome-lite/SmartHomeLite
ExecStart=/opt/smarthome-lite/SmartHomeLite/venv/bin/python /opt/smarthome-lite/SmartHomeLite/run.py
Restart=on-failure
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "=== Enabling and starting service ==="
systemctl daemon-reload
systemctl enable smarthome-lite.service
systemctl start smarthome-lite.service

# Setup complete
echo ""
echo "=== Setup Complete! ==="
echo "SmartHomeLite is now running as a service."
echo "You can access the web interface at:"
echo "  http://$(hostname -I | awk '{print $1}'):8000"
echo ""
echo "To check the service status:"
echo "  sudo systemctl status smarthome-lite"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u smarthome-lite -f"
echo ""
echo "To edit configuration:"
echo "  sudo nano /opt/smarthome-lite/SmartHomeLite/.env"
echo "  sudo systemctl restart smarthome-lite"