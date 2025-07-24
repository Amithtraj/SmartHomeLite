"""System API Endpoints

This module contains all the API endpoints for system control.
"""

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Dict, Any
from loguru import logger
import platform
import psutil
import os

from config import settings

router = APIRouter()


class SystemInfo(BaseModel):
    """System information model"""

    hostname: str
    platform: str
    python_version: str
    cpu_usage: float
    memory_usage: float
    disk_usage: float
    uptime: float
    app_version: str


class SystemSettings(BaseModel):
    """System settings model"""

    settings: Dict[str, Any]


@router.get("/info", response_model=SystemInfo)
async def get_system_info():
    """Get system information"""
    try:
        # Get system information
        hostname = platform.node()
        platform_info = f"{platform.system()} {platform.release()}"
        python_version = platform.python_version()
        cpu_usage = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        memory_usage = memory.percent
        disk = psutil.disk_usage("/")
        disk_usage = disk.percent
        uptime = psutil.boot_time()
        app_version = "0.1.0"  # This should match the version in app/__init__.py

        return SystemInfo(
            hostname=hostname,
            platform=platform_info,
            python_version=python_version,
            cpu_usage=cpu_usage,
            memory_usage=memory_usage,
            disk_usage=disk_usage,
            uptime=uptime,
            app_version=app_version,
        )
    except Exception as e:
        logger.error(f"Error getting system information: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting system information: {str(e)}",
        )


@router.get("/settings", response_model=SystemSettings)
async def get_system_settings():
    """Get system settings"""
    try:
        # Convert settings to dictionary
        settings_dict = settings.dict()
        # Remove sensitive information
        if "MQTT_PASSWORD" in settings_dict:
            settings_dict["MQTT_PASSWORD"] = "*****" if settings_dict["MQTT_PASSWORD"] else ""
        if "API_KEY" in settings_dict:
            settings_dict["API_KEY"] = "*****" if settings_dict["API_KEY"] else ""

        return SystemSettings(settings=settings_dict)
    except Exception as e:
        logger.error(f"Error getting system settings: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting system settings: {str(e)}",
        )


@router.post("/restart", status_code=status.HTTP_202_ACCEPTED)
async def restart_system():
    """Restart the application (not the device)"""
    try:
        # This is a simple implementation that just exits the process
        # In a production environment, you would want to use a process manager
        # like systemd or supervisor to restart the application
        logger.info("Restarting application...")
        os._exit(0)
    except Exception as e:
        logger.error(f"Error restarting system: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error restarting system: {str(e)}",
        )