"""Web Routes

This module contains web routes for the SmartHomeLite application.
"""

import os
from fastapi import APIRouter, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from loguru import logger

from app.services.device_service import DeviceService
from app.models.device import DeviceType

# Create router
router = APIRouter()

# Set up Jinja2 templates
templates_dir = os.path.join(os.path.dirname(__file__), "templates")
templates = Jinja2Templates(directory=templates_dir)

# Initialize services
device_service = DeviceService()


@router.get("/", response_class=HTMLResponse)
async def index(request: Request):
    """Render the dashboard page"""
    try:
        # Get all devices
        devices = await device_service.get_devices()
        
        # Count devices by type
        bluetooth_count = len([d for d in devices if d.type == DeviceType.BLUETOOTH])
        mqtt_count = len([d for d in devices if d.type == DeviceType.MQTT])
        virtual_count = len([d for d in devices if d.type == DeviceType.VIRTUAL])
        other_count = len([d for d in devices if d.type == DeviceType.OTHER])
        
        # Count devices by status
        online_count = len([d for d in devices if d.status in ["online", "connected", "on"]])
        offline_count = len([d for d in devices if d.status in ["offline", "disconnected", "off"]])
        unknown_count = len([d for d in devices if d.status == "unknown"])
        
        return templates.TemplateResponse(
            "index.html",
            {
                "request": request,
                "devices": devices,
                "device_counts": {
                    "total": len(devices),
                    "bluetooth": bluetooth_count,
                    "mqtt": mqtt_count,
                    "virtual": virtual_count,
                    "other": other_count,
                    "online": online_count,
                    "offline": offline_count,
                    "unknown": unknown_count,
                },
            },
        )
    except Exception as e:
        logger.error(f"Error rendering dashboard: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/devices", response_class=HTMLResponse)
async def devices_page(request: Request):
    """Render the devices page"""
    try:
        # Get all devices
        devices = await device_service.get_devices()
        
        return templates.TemplateResponse(
            "devices.html",
            {
                "request": request,
                "devices": devices,
            },
        )
    except Exception as e:
        logger.error(f"Error rendering devices page: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/devices/{device_id}", response_class=HTMLResponse)
async def device_detail(request: Request, device_id: str):
    """Render the device detail page"""
    try:
        # Get the device
        device = await device_service.get_device(device_id)
        if not device:
            raise HTTPException(status_code=404, detail="Device not found")
        
        return templates.TemplateResponse(
            "device_detail.html",
            {
                "request": request,
                "device": device,
            },
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error rendering device detail page: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/settings", response_class=HTMLResponse)
async def settings_page(request: Request):
    """Render the settings page"""
    try:
        return templates.TemplateResponse(
            "settings.html",
            {
                "request": request,
            },
        )
    except Exception as e:
        logger.error(f"Error rendering settings page: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/about", response_class=HTMLResponse)
async def about_page(request: Request):
    """Render the about page"""
    try:
        return templates.TemplateResponse(
            "about.html",
            {
                "request": request,
                "app_version": "0.1.0",
            },
        )
    except Exception as e:
        logger.error(f"Error rendering about page: {e}")
        raise HTTPException(status_code=500, detail=str(e))