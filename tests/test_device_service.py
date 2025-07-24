import os
import json
import pytest
from unittest.mock import patch, MagicMock
from app.services.device_service import DeviceService
from app.models.device import Device, DeviceType, DeviceAction


@pytest.fixture
def mock_data_dir(tmp_path):
    """Create a temporary directory for test data"""
    data_dir = tmp_path / "data"
    data_dir.mkdir()
    return str(data_dir)


@pytest.fixture
def device_service(mock_data_dir):
    """Create a device service instance with mocked data directory"""
    with patch('app.services.device_service.DATA_DIR', mock_data_dir):
        service = DeviceService()
        yield service


@pytest.fixture
def sample_device():
    """Create a sample device for testing"""
    return Device(
        id="test-device-1",
        name="Test Device",
        type=DeviceType.BLUETOOTH,
        address="00:11:22:33:44:55",
        status="offline",
        properties={"manufacturer": "Test", "model": "v1.0"},
        actions=[
            DeviceAction(name="power", display_name="Power", parameters=["on", "off"])
        ]
    )


def test_create_device(device_service, sample_device):
    """Test creating a new device"""
    # Create a device
    created_device = device_service.create_device(sample_device)
    
    # Verify the device was created with the correct ID
    assert created_device.id == sample_device.id
    assert created_device.name == sample_device.name
    assert created_device.type == sample_device.type
    
    # Verify the device was saved to storage
    devices = device_service.get_devices()
    assert len(devices) == 1
    assert devices[0].id == sample_device.id


def test_get_device_by_id(device_service, sample_device):
    """Test retrieving a device by ID"""
    # Create a device first
    device_service.create_device(sample_device)
    
    # Get the device by ID
    device = device_service.get_device_by_id(sample_device.id)
    
    # Verify the correct device was retrieved
    assert device is not None
    assert device.id == sample_device.id
    assert device.name == sample_device.name
    
    # Test with non-existent ID
    non_existent = device_service.get_device_by_id("non-existent-id")
    assert non_existent is None


def test_update_device(device_service, sample_device):
    """Test updating a device"""
    # Create a device first
    device_service.create_device(sample_device)
    
    # Update the device
    updated_device = Device(
        id=sample_device.id,
        name="Updated Device",
        type=sample_device.type,
        address=sample_device.address,
        status="online",
        properties=sample_device.properties,
        actions=sample_device.actions
    )
    
    result = device_service.update_device(updated_device)
    
    # Verify the update was successful
    assert result is True
    
    # Verify the device was updated in storage
    device = device_service.get_device_by_id(sample_device.id)
    assert device.name == "Updated Device"
    assert device.status == "online"


def test_delete_device(device_service, sample_device):
    """Test deleting a device"""
    # Create a device first
    device_service.create_device(sample_device)
    
    # Delete the device
    result = device_service.delete_device(sample_device.id)
    
    # Verify the deletion was successful
    assert result is True
    
    # Verify the device was removed from storage
    devices = device_service.get_devices()
    assert len(devices) == 0
    
    # Test deleting non-existent device
    result = device_service.delete_device("non-existent-id")
    assert result is False


@patch('app.core.bluetooth.BluetoothManager')
def test_execute_action_bluetooth(mock_bluetooth, device_service, sample_device):
    """Test executing an action on a Bluetooth device"""
    # Setup mock
    mock_instance = MagicMock()
    mock_bluetooth.return_value = mock_instance
    mock_instance.send_command.return_value = True
    
    # Create a device
    device_service.create_device(sample_device)
    
    # Execute an action
    result = device_service.execute_action(sample_device.id, "power", {"value": "on"})
    
    # Verify the action was executed
    assert result is True
    mock_instance.send_command.assert_called_once_with(
        sample_device.address, "power", {"value": "on"}
    )


@patch('app.core.mqtt.MQTTClient')
def test_execute_action_mqtt(mock_mqtt, device_service):
    """Test executing an action on an MQTT device"""
    # Setup mock
    mock_instance = MagicMock()
    mock_mqtt.return_value = mock_instance
    mock_instance.publish_action.return_value = True
    
    # Create an MQTT device
    mqtt_device = Device(
        id="mqtt-device-1",
        name="MQTT Device",
        type=DeviceType.MQTT,
        address="home/device1",
        status="online",
        properties={},
        actions=[
            DeviceAction(name="power", display_name="Power", parameters=["on", "off"])
        ]
    )
    device_service.create_device(mqtt_device)
    
    # Execute an action
    result = device_service.execute_action(mqtt_device.id, "power", {"value": "on"})
    
    # Verify the action was executed
    assert result is True
    mock_instance.publish_action.assert_called_once_with(
        mqtt_device.address, "power", {"value": "on"}
    )