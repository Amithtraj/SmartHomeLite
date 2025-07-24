"""Bluetooth Manager

This module handles Bluetooth device discovery and control.
It tries to use PyBluez if available, otherwise falls back to bluetoothctl.
"""

import asyncio
import subprocess
import re
import uuid
from typing import List, Dict, Any, Optional
from loguru import logger
import platform

from app.models.device import Device, DeviceType
from config import settings

# Try to import PyBluez, but don't fail if it's not available
try:
    import bluetooth
    PYBLUEZ_AVAILABLE = True
except ImportError:
    PYBLUEZ_AVAILABLE = False
    logger.warning("PyBluez not available, falling back to bluetoothctl")


class BluetoothManager:
    """Manages Bluetooth device discovery and control"""

    def __init__(self):
        """Initialize the Bluetooth manager"""
        self.devices: Dict[str, Device] = {}
        self.discovery_running = False
        self.discovery_task = None

    async def start_discovery(self) -> None:
        """Start periodic Bluetooth device discovery"""
        if not settings.BLUETOOTH_ENABLED:
            logger.info("Bluetooth discovery disabled in settings")
            return

        if self.discovery_running:
            logger.warning("Bluetooth discovery already running")
            return

        self.discovery_running = True
        self.discovery_task = asyncio.create_task(self._discovery_loop())
        logger.info("Started Bluetooth discovery")

    async def stop_discovery(self) -> None:
        """Stop Bluetooth device discovery"""
        if not self.discovery_running:
            return

        self.discovery_running = False
        if self.discovery_task:
            self.discovery_task.cancel()
            try:
                await self.discovery_task
            except asyncio.CancelledError:
                pass
        logger.info("Stopped Bluetooth discovery")

    async def _discovery_loop(self) -> None:
        """Run periodic Bluetooth device discovery"""
        while self.discovery_running:
            try:
                await self.discover_devices()
            except Exception as e:
                logger.error(f"Error in Bluetooth discovery: {e}")

            # Wait for the next scan interval
            await asyncio.sleep(settings.BLUETOOTH_SCAN_INTERVAL)

    async def discover_devices(self) -> List[Device]:
        """Discover Bluetooth devices"""
        if PYBLUEZ_AVAILABLE:
            return await self._discover_with_pybluez()
        else:
            return await self._discover_with_bluetoothctl()

    async def _discover_with_pybluez(self) -> List[Device]:
        """Discover Bluetooth devices using PyBluez"""
        logger.info("Discovering Bluetooth devices with PyBluez")
        
        # This needs to run in a thread pool because bluetooth.discover_devices is blocking
        loop = asyncio.get_event_loop()
        nearby_devices = await loop.run_in_executor(
            None, bluetooth.discover_devices, True, 10, True
        )
        
        devices = []
        for addr, name, device_class in nearby_devices:
            device_id = addr.replace(":", "").lower()
            device = Device(
                id=device_id,
                name=name or f"Unknown Device ({addr})",
                type=DeviceType.BLUETOOTH,
                address=addr,
                status="online",
                properties={
                    "class": device_class,
                    "services": [],
                },
            )
            self.devices[device_id] = device
            devices.append(device)
            
        logger.info(f"Discovered {len(devices)} devices with PyBluez")
        return devices

    async def _discover_with_bluetoothctl(self) -> List[Device]:
        """Discover Bluetooth devices using bluetoothctl"""
        logger.info("Discovering Bluetooth devices with bluetoothctl")
        
        # Check if we're on Windows (bluetoothctl won't work)
        if platform.system() == "Windows":
            logger.warning("bluetoothctl not available on Windows")
            return []
        
        devices = []
        
        try:
            # Run bluetoothctl scan on
            process = await asyncio.create_subprocess_exec(
                "bluetoothctl",
                "scan",
                "on",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            # Let it scan for a few seconds
            await asyncio.sleep(5)
            
            # Kill the scan process
            process.terminate()
            await process.wait()
            
            # Now get the list of devices
            process = await asyncio.create_subprocess_exec(
                "bluetoothctl",
                "devices",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            stdout, stderr = await process.communicate()
            
            if process.returncode != 0:
                logger.error(f"bluetoothctl error: {stderr.decode()}")
                return []
            
            # Parse the output
            output = stdout.decode()
            device_regex = r"Device\s+([0-9A-F:]+)\s+(.+)"
            
            for line in output.splitlines():
                match = re.search(device_regex, line)
                if match:
                    addr = match.group(1)
                    name = match.group(2)
                    
                    device_id = addr.replace(":", "").lower()
                    device = Device(
                        id=device_id,
                        name=name or f"Unknown Device ({addr})",
                        type=DeviceType.BLUETOOTH,
                        address=addr,
                        status="online",
                        properties={
                            "class": "unknown",
                            "services": [],
                        },
                    )
                    self.devices[device_id] = device
                    devices.append(device)
            
            logger.info(f"Discovered {len(devices)} devices with bluetoothctl")
            return devices
            
        except Exception as e:
            logger.error(f"Error discovering devices with bluetoothctl: {e}")
            return []

    async def connect_device(self, device_id: str) -> bool:
        """Connect to a Bluetooth device"""
        device = self.devices.get(device_id)
        if not device:
            logger.error(f"Device {device_id} not found")
            return False
            
        logger.info(f"Connecting to device {device.name} ({device.address})")
        
        if PYBLUEZ_AVAILABLE:
            return await self._connect_with_pybluez(device)
        else:
            return await self._connect_with_bluetoothctl(device)

    async def _connect_with_pybluez(self, device: Device) -> bool:
        """Connect to a Bluetooth device using PyBluez"""
        try:
            # This is a simplified example. In a real application, you would
            # need to handle different types of Bluetooth connections (RFCOMM, L2CAP, etc.)
            sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
            sock.connect((device.address, 1))  # Channel 1 is just an example
            sock.close()
            
            device.status = "connected"
            return True
        except Exception as e:
            logger.error(f"Error connecting to device with PyBluez: {e}")
            return False

    async def _connect_with_bluetoothctl(self, device: Device) -> bool:
        """Connect to a Bluetooth device using bluetoothctl"""
        try:
            process = await asyncio.create_subprocess_exec(
                "bluetoothctl",
                "connect",
                device.address,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            stdout, stderr = await process.communicate()
            
            if process.returncode != 0:
                logger.error(f"bluetoothctl connect error: {stderr.decode()}")
                return False
                
            output = stdout.decode()
            if "successful" in output.lower():
                device.status = "connected"
                return True
            else:
                logger.error(f"Failed to connect to device: {output}")
                return False
                
        except Exception as e:
            logger.error(f"Error connecting to device with bluetoothctl: {e}")
            return False

    async def disconnect_device(self, device_id: str) -> bool:
        """Disconnect from a Bluetooth device"""
        device = self.devices.get(device_id)
        if not device:
            logger.error(f"Device {device_id} not found")
            return False
            
        logger.info(f"Disconnecting from device {device.name} ({device.address})")
        
        if PYBLUEZ_AVAILABLE:
            return await self._disconnect_with_pybluez(device)
        else:
            return await self._disconnect_with_bluetoothctl(device)

    async def _disconnect_with_pybluez(self, device: Device) -> bool:
        """Disconnect from a Bluetooth device using PyBluez"""
        # In a real application, you would need to keep track of open connections
        # For this example, we'll just update the status
        device.status = "disconnected"
        return True

    async def _disconnect_with_bluetoothctl(self, device: Device) -> bool:
        """Disconnect from a Bluetooth device using bluetoothctl"""
        try:
            process = await asyncio.create_subprocess_exec(
                "bluetoothctl",
                "disconnect",
                device.address,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            stdout, stderr = await process.communicate()
            
            if process.returncode != 0:
                logger.error(f"bluetoothctl disconnect error: {stderr.decode()}")
                return False
                
            output = stdout.decode()
            if "successful" in output.lower():
                device.status = "disconnected"
                return True
            else:
                logger.error(f"Failed to disconnect from device: {output}")
                return False
                
        except Exception as e:
            logger.error(f"Error disconnecting from device with bluetoothctl: {e}")
            return False

    async def send_command(self, device_id: str, command: str) -> bool:
        """Send a command to a Bluetooth device"""
        # This is a placeholder for device-specific commands
        # In a real application, you would need to implement specific
        # commands for different types of devices
        logger.info(f"Sending command {command} to device {device_id}")
        return True