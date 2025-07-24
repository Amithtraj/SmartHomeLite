"""Device Service

This module contains the business logic for device management.
"""

import json
import os
import uuid
from datetime import datetime
from typing import Dict, List, Optional, Any
from loguru import logger

from app.models.device import Device, DeviceCreate, DeviceUpdate, DeviceAction, DeviceType
from app.core.bluetooth import BluetoothManager

# Try to import the MQTT client, but don't fail if it's not available
try:
    from app.core.mqtt import MQTTClient
    MQTT_CLIENT_AVAILABLE = True
except ImportError:
    MQTT_CLIENT_AVAILABLE = False


class DeviceService:
    """Service for managing devices"""

    def __init__(self):
        """Initialize the device service"""
        self.devices: Dict[str, Device] = {}
        self.devices_file = os.path.join(os.path.dirname(__file__), "../../data/devices.json")
        self.bluetooth_manager = BluetoothManager()
        
        # Load devices from file
        self._load_devices()

    async def get_devices(self, device_type: Optional[str] = None) -> List[Device]:
        """Get all devices or filter by type"""
        if device_type:
            return [d for d in self.devices.values() if d.type == device_type]
        return list(self.devices.values())

    async def get_device(self, device_id: str) -> Optional[Device]:
        """Get a specific device by ID"""
        return self.devices.get(device_id)

    async def create_device(self, device_create: DeviceCreate) -> Device:
        """Create a new device"""
        # Generate a new device ID
        device_id = str(uuid.uuid4())
        
        # Create the device
        device = Device(
            id=device_id,
            name=device_create.name,
            type=device_create.type,
            address=device_create.address,
            status="offline",
            properties=device_create.properties,
            last_seen=datetime.now().isoformat(),
        )
        
        # Add default actions based on device type
        if device.type == DeviceType.BLUETOOTH:
            device.actions = ["connect", "disconnect"]
        elif device.type == DeviceType.MQTT:
            device.actions = ["publish", "subscribe"]
        elif device.type == DeviceType.VIRTUAL:
            device.actions = ["on", "off"]
        
        # Add the device to the collection
        self.devices[device_id] = device
        
        # Save devices to file
        self._save_devices()
        
        logger.info(f"Created device: {device.name} ({device.id})")
        return device

    async def update_device(self, device_id: str, device_update: DeviceUpdate) -> Optional[Device]:
        """Update an existing device"""
        device = self.devices.get(device_id)
        if not device:
            return None
        
        # Update device fields
        if device_update.name is not None:
            device.name = device_update.name
        if device_update.type is not None:
            device.type = device_update.type
        if device_update.address is not None:
            device.address = device_update.address
        if device_update.status is not None:
            device.status = device_update.status
        if device_update.properties is not None:
            device.properties = device_update.properties
        
        # Update last_seen timestamp
        device.last_seen = datetime.now().isoformat()
        
        # Save devices to file
        self._save_devices()
        
        logger.info(f"Updated device: {device.name} ({device.id})")
        return device

    async def delete_device(self, device_id: str) -> bool:
        """Delete a device"""
        if device_id not in self.devices:
            return False
        
        # Remove the device from the collection
        device = self.devices.pop(device_id)
        
        # Save devices to file
        self._save_devices()
        
        logger.info(f"Deleted device: {device.name} ({device.id})")
        return True

    async def execute_action(self, device_id: str, action: DeviceAction) -> Optional[Device]:
        """Execute an action on a device"""
        device = self.devices.get(device_id)
        if not device:
            return None
        
        logger.info(f"Executing action {action.action_type} on device {device.name} ({device.id})")
        
        # Handle different device types
        if device.type == DeviceType.BLUETOOTH:
            await self._execute_bluetooth_action(device, action)
        elif device.type == DeviceType.MQTT:
            await self._execute_mqtt_action(device, action)
        elif device.type == DeviceType.VIRTUAL:
            await self._execute_virtual_action(device, action)
        else:
            logger.warning(f"Unsupported device type: {device.type}")
        
        # Update last_seen timestamp
        device.last_seen = datetime.now().isoformat()
        
        # Save devices to file
        self._save_devices()
        
        return device

    async def _execute_bluetooth_action(self, device: Device, action: DeviceAction) -> None:
        """Execute an action on a Bluetooth device"""
        if action.action_type == "connect":
            success = await self.bluetooth_manager.connect_device(device.id)
            if success:
                device.status = "connected"
            else:
                logger.error(f"Failed to connect to device {device.name} ({device.id})")
        elif action.action_type == "disconnect":
            success = await self.bluetooth_manager.disconnect_device(device.id)
            if success:
                device.status = "disconnected"
            else:
                logger.error(f"Failed to disconnect from device {device.name} ({device.id})")
        else:
            # For other actions, just send the command to the device
            await self.bluetooth_manager.send_command(device.id, action.action_type)

    async def _execute_mqtt_action(self, device: Device, action: DeviceAction) -> None:
        """Execute an action on an MQTT device"""
        if not MQTT_CLIENT_AVAILABLE:
            logger.error("MQTT client not available")
            return
        
        # This is a placeholder for MQTT actions
        # In a real application, you would need to implement specific
        # actions for MQTT devices
        logger.info(f"MQTT action {action.action_type} not implemented yet")

    async def _execute_virtual_action(self, device: Device, action: DeviceAction) -> None:
        """Execute an action on a virtual device"""
        if action.action_type == "on":
            device.status = "on"
            device.properties["state"] = "on"
        elif action.action_type == "off":
            device.status = "off"
            device.properties["state"] = "off"
        else:
            # For other actions, just update the properties
            device.properties[action.action_type] = action.value

    def _load_devices(self) -> None:
        """Load devices from file"""
        try:
            # Create data directory if it doesn't exist
            os.makedirs(os.path.dirname(self.devices_file), exist_ok=True)
            
            # Load devices from file if it exists
            if os.path.exists(self.devices_file):
                with open(self.devices_file, "r") as f:
                    devices_data = json.load(f)
                    for device_data in devices_data:
                        device = Device(**device_data)
                        self.devices[device.id] = device
                logger.info(f"Loaded {len(self.devices)} devices from file")
        except Exception as e:
            logger.error(f"Error loading devices from file: {e}")

    def _save_devices(self) -> None:
        """Save devices to file"""
        try:
            # Create data directory if it doesn't exist
            os.makedirs(os.path.dirname(self.devices_file), exist_ok=True)
            
            # Save devices to file
            with open(self.devices_file, "w") as f:
                devices_data = [device.dict() for device in self.devices.values()]
                json.dump(devices_data, f, indent=2)
            logger.debug(f"Saved {len(self.devices)} devices to file")
        except Exception as e:
            logger.error(f"Error saving devices to file: {e}")