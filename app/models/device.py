"""Device Models

This module contains data models for devices in the SmartHomeLite application.
"""

from enum import Enum
from typing import Dict, Any, Optional, List
from pydantic import BaseModel, Field
import uuid


class DeviceType(str, Enum):
    """Device types"""

    BLUETOOTH = "bluetooth"
    MQTT = "mqtt"
    VIRTUAL = "virtual"
    OTHER = "other"


class DeviceAction(BaseModel):
    """Device action model"""

    action_type: str = Field(..., description="Type of action to perform")
    value: Any = Field(None, description="Value for the action")


class DeviceCreate(BaseModel):
    """Model for creating a new device"""

    name: str = Field(..., description="Device name")
    type: DeviceType = Field(..., description="Device type")
    address: Optional[str] = Field(None, description="Device address (e.g., MAC address)")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Device properties")


class DeviceUpdate(BaseModel):
    """Model for updating an existing device"""

    name: Optional[str] = Field(None, description="Device name")
    type: Optional[DeviceType] = Field(None, description="Device type")
    address: Optional[str] = Field(None, description="Device address (e.g., MAC address)")
    status: Optional[str] = Field(None, description="Device status")
    properties: Optional[Dict[str, Any]] = Field(None, description="Device properties")


class Device(BaseModel):
    """Device model"""

    id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="Device ID")
    name: str = Field(..., description="Device name")
    type: DeviceType = Field(..., description="Device type")
    address: Optional[str] = Field(None, description="Device address (e.g., MAC address)")
    status: str = Field("unknown", description="Device status")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Device properties")
    last_seen: Optional[str] = Field(None, description="Last time the device was seen")
    actions: List[str] = Field(default_factory=list, description="Available actions")

    class Config:
        """Pydantic config"""

        schema_extra = {
            "example": {
                "id": "550e8400-e29b-41d4-a716-446655440000",
                "name": "Living Room Speaker",
                "type": "bluetooth",
                "address": "00:11:22:33:44:55",
                "status": "online",
                "properties": {"class": "audio", "services": ["a2dp"]},
                "last_seen": "2023-04-01T12:00:00Z",
                "actions": ["connect", "disconnect", "play", "pause"],
            }
        }