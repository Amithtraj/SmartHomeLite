#!/usr/bin/env python3
"""
Configuration settings for SmartHomeLite

This module loads configuration from environment variables and provides
default values for all settings.
"""

import os
from pydantic import BaseSettings
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()


class Settings(BaseSettings):
    """Application settings"""

    # Server settings
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", 8000))
    DEBUG: bool = os.getenv("DEBUG", "False").lower() in ("true", "1", "t")

    # Bluetooth settings
    BLUETOOTH_ENABLED: bool = os.getenv("BLUETOOTH_ENABLED", "True").lower() in (
        "true",
        "1",
        "t",
    )
    BLUETOOTH_SCAN_INTERVAL: int = int(os.getenv("BLUETOOTH_SCAN_INTERVAL", 60))  # seconds

    # MQTT settings (optional)
    MQTT_ENABLED: bool = os.getenv("MQTT_ENABLED", "False").lower() in ("true", "1", "t")
    MQTT_BROKER: str = os.getenv("MQTT_BROKER", "localhost")
    MQTT_PORT: int = int(os.getenv("MQTT_PORT", 1883))
    MQTT_USERNAME: str = os.getenv("MQTT_USERNAME", "")
    MQTT_PASSWORD: str = os.getenv("MQTT_PASSWORD", "")
    MQTT_CLIENT_ID: str = os.getenv("MQTT_CLIENT_ID", "smarthomelite")
    MQTT_TOPIC_PREFIX: str = os.getenv("MQTT_TOPIC_PREFIX", "smarthomelite")

    # Voice recognition settings (optional)
    VOICE_ENABLED: bool = os.getenv("VOICE_ENABLED", "False").lower() in (
        "true",
        "1",
        "t",
    )
    VOICE_ENGINE: str = os.getenv("VOICE_ENGINE", "vosk")  # 'vosk' or 'google'

    # Security settings
    API_KEY: str = os.getenv("API_KEY", "")
    API_KEY_ENABLED: bool = os.getenv("API_KEY_ENABLED", "False").lower() in (
        "true",
        "1",
        "t",
    )

    class Config:
        """Pydantic config"""

        env_file = ".env"


# Create settings instance
settings = Settings()