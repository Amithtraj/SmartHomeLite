"""Device API Endpoints

This module contains all the API endpoints for device control.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from loguru import logger

from app.models.device import Device, DeviceCreate, DeviceUpdate, DeviceAction
from app.services.device_service import DeviceService
from app.core.bluetooth import BluetoothManager

router = APIRouter()
device_service = DeviceService()
bluetooth_manager = BluetoothManager()


@router.get("/", response_model=List[Device])
async def get_devices(
    device_type: Optional[str] = Query(None, description="Filter by device type")
):
    """Get all devices or filter by type"""
    try:
        devices = await device_service.get_devices(device_type=device_type)
        return devices
    except Exception as e:
        logger.error(f"Error getting devices: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting devices: {str(e)}",
        )


@router.get("/discover", response_model=List[Device])
async def discover_devices():
    """Discover new Bluetooth devices"""
    try:
        devices = await bluetooth_manager.discover_devices()
        return devices
    except Exception as e:
        logger.error(f"Error discovering devices: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error discovering devices: {str(e)}",
        )


@router.get("/{device_id}", response_model=Device)
async def get_device(device_id: str):
    """Get a specific device by ID"""
    try:
        device = await device_service.get_device(device_id)
        if not device:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Device with ID {device_id} not found",
            )
        return device
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting device: {str(e)}",
        )


@router.post("/", response_model=Device, status_code=status.HTTP_201_CREATED)
async def create_device(device: DeviceCreate):
    """Add a new device manually"""
    try:
        new_device = await device_service.create_device(device)
        return new_device
    except Exception as e:
        logger.error(f"Error creating device: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating device: {str(e)}",
        )


@router.put("/{device_id}", response_model=Device)
async def update_device(device_id: str, device: DeviceUpdate):
    """Update an existing device"""
    try:
        updated_device = await device_service.update_device(device_id, device)
        if not updated_device:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Device with ID {device_id} not found",
            )
        return updated_device
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating device: {str(e)}",
        )


@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(device_id: str):
    """Delete a device"""
    try:
        success = await device_service.delete_device(device_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Device with ID {device_id} not found",
            )
        return None
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting device: {str(e)}",
        )


@router.post("/{device_id}/action", response_model=Device)
async def execute_device_action(device_id: str, action: DeviceAction):
    """Execute an action on a device"""
    try:
        device = await device_service.execute_action(device_id, action)
        if not device:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Device with ID {device_id} not found",
            )
        return device
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error executing action on device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error executing action: {str(e)}",
        )