"""MQTT Client

This module handles MQTT communication for the SmartHomeLite application.
It is optional and only enabled if MQTT_ENABLED is set to True in the settings.
"""

import asyncio
import json
from typing import Dict, Any, Callable, Optional
from loguru import logger

# Try to import paho-mqtt, but don't fail if it's not available
try:
    import paho.mqtt.client as mqtt
    PAHO_MQTT_AVAILABLE = True
except ImportError:
    PAHO_MQTT_AVAILABLE = False
    logger.warning("paho-mqtt not available, MQTT functionality will be disabled")

from config import settings
from app.models.device import Device, DeviceAction


class MQTTClient:
    """MQTT Client for SmartHomeLite"""

    def __init__(self):
        """Initialize the MQTT client"""
        self.client = None
        self.connected = False
        self.message_callbacks: Dict[str, Callable] = {}

    async def start(self) -> bool:
        """Start the MQTT client"""
        if not settings.MQTT_ENABLED:
            logger.info("MQTT client disabled in settings")
            return False

        if not PAHO_MQTT_AVAILABLE:
            logger.error("paho-mqtt not available, cannot start MQTT client")
            return False

        if self.connected:
            logger.warning("MQTT client already connected")
            return True

        try:
            # Create a new client instance
            self.client = mqtt.Client(client_id=settings.MQTT_CLIENT_ID)

            # Set up callbacks
            self.client.on_connect = self._on_connect
            self.client.on_disconnect = self._on_disconnect
            self.client.on_message = self._on_message

            # Set up authentication if needed
            if settings.MQTT_USERNAME and settings.MQTT_PASSWORD:
                self.client.username_pw_set(
                    settings.MQTT_USERNAME, settings.MQTT_PASSWORD
                )

            # Connect to the broker
            self.client.connect_async(settings.MQTT_BROKER, settings.MQTT_PORT, 60)

            # Start the loop in a separate thread
            self.client.loop_start()

            # Wait for the connection to be established
            for _ in range(10):  # Wait up to 10 seconds
                if self.connected:
                    break
                await asyncio.sleep(1)

            if not self.connected:
                logger.error("Failed to connect to MQTT broker")
                self.client.loop_stop()
                return False

            logger.info(f"Connected to MQTT broker at {settings.MQTT_BROKER}:{settings.MQTT_PORT}")
            return True

        except Exception as e:
            logger.error(f"Error starting MQTT client: {e}")
            return False

    async def stop(self) -> None:
        """Stop the MQTT client"""
        if not self.client or not self.connected:
            return

        try:
            self.client.disconnect()
            self.client.loop_stop()
            self.connected = False
            logger.info("Disconnected from MQTT broker")
        except Exception as e:
            logger.error(f"Error stopping MQTT client: {e}")

    def _on_connect(self, client, userdata, flags, rc):
        """Callback for when the client connects to the broker"""
        if rc == 0:
            self.connected = True
            logger.info("Connected to MQTT broker")

            # Subscribe to topics
            topic = f"{settings.MQTT_TOPIC_PREFIX}/+/+"
            client.subscribe(topic)
            logger.info(f"Subscribed to topic: {topic}")
        else:
            logger.error(f"Failed to connect to MQTT broker with code {rc}")

    def _on_disconnect(self, client, userdata, rc):
        """Callback for when the client disconnects from the broker"""
        self.connected = False
        if rc != 0:
            logger.warning(f"Unexpected disconnection from MQTT broker with code {rc}")
        else:
            logger.info("Disconnected from MQTT broker")

    def _on_message(self, client, userdata, msg):
        """Callback for when a message is received from the broker"""
        try:
            topic = msg.topic
            payload = msg.payload.decode("utf-8")
            logger.debug(f"Received message on topic {topic}: {payload}")

            # Parse the topic to get device ID and action
            # Format: smarthomelite/device_id/action
            parts = topic.split("/")
            if len(parts) != 3:
                logger.warning(f"Invalid topic format: {topic}")
                return

            device_id = parts[1]
            action_type = parts[2]

            # Call the appropriate callback if registered
            if action_type in self.message_callbacks:
                try:
                    payload_data = json.loads(payload)
                except json.JSONDecodeError:
                    payload_data = {"value": payload}

                asyncio.create_task(
                    self.message_callbacks[action_type](device_id, payload_data)
                )

        except Exception as e:
            logger.error(f"Error processing MQTT message: {e}")

    def register_callback(
        self, action_type: str, callback: Callable[[str, Dict[str, Any]], None]
    ) -> None:
        """Register a callback for a specific action type"""
        self.message_callbacks[action_type] = callback
        logger.debug(f"Registered callback for action type: {action_type}")

    async def publish_device_state(self, device: Device) -> bool:
        """Publish device state to MQTT"""
        if not self.client or not self.connected:
            return False

        try:
            topic = f"{settings.MQTT_TOPIC_PREFIX}/{device.id}/state"
            payload = json.dumps(device.dict())
            result = self.client.publish(topic, payload, qos=1, retain=True)
            if result.rc != mqtt.MQTT_ERR_SUCCESS:
                logger.error(f"Failed to publish device state: {result}")
                return False

            logger.debug(f"Published device state to {topic}")
            return True

        except Exception as e:
            logger.error(f"Error publishing device state: {e}")
            return False

    async def publish_device_action(self, device_id: str, action: DeviceAction) -> bool:
        """Publish device action to MQTT"""
        if not self.client or not self.connected:
            return False

        try:
            topic = f"{settings.MQTT_TOPIC_PREFIX}/{device_id}/{action.action_type}"
            payload = json.dumps({"value": action.value})
            result = self.client.publish(topic, payload, qos=1)
            if result.rc != mqtt.MQTT_ERR_SUCCESS:
                logger.error(f"Failed to publish device action: {result}")
                return False

            logger.debug(f"Published device action to {topic}")
            return True

        except Exception as e:
            logger.error(f"Error publishing device action: {e}")
            return False