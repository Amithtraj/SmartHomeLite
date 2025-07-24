import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from main import app
from app.models.device import Device, DeviceType, DeviceAction


@pytest.fixture
def client():
    """Create a test client for the FastAPI app"""
    return TestClient(app)


@pytest.fixture
def mock_device_service():
    """Mock the DeviceService for API tests"""
    with patch('app.api.devices.DeviceService') as mock_service:
        # Create a mock instance
        mock_instance = MagicMock()
        mock_service.return_value = mock_instance
        
        # Setup sample devices
        sample_device = Device(
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
        
        # Configure mock methods
        mock_instance.get_devices.return_value = [sample_device]
        mock_instance.get_device_by_id.return_value = sample_device
        mock_instance.create_device.return_value = sample_device
        mock_instance.update_device.return_value = True
        mock_instance.delete_device.return_value = True
        mock_instance.execute_action.return_value = True
        
        yield mock_instance


def test_get_devices(client, mock_device_service):
    """Test GET /api/devices endpoint"""
    response = client.get("/api/devices")
    
    # Verify the response
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["id"] == "test-device-1"
    assert data[0]["name"] == "Test Device"
    
    # Verify the service method was called
    mock_device_service.get_devices.assert_called_once()


def test_get_device_by_id(client, mock_device_service):
    """Test GET /api/devices/{device_id} endpoint"""
    response = client.get("/api/devices/test-device-1")
    
    # Verify the response
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "test-device-1"
    assert data["name"] == "Test Device"
    
    # Verify the service method was called
    mock_device_service.get_device_by_id.assert_called_once_with("test-device-1")
    
    # Test with non-existent ID
    mock_device_service.get_device_by_id.return_value = None
    response = client.get("/api/devices/non-existent-id")
    assert response.status_code == 404


def test_create_device(client, mock_device_service):
    """Test POST /api/devices endpoint"""
    device_data = {
        "name": "New Device",
        "type": "bluetooth",
        "address": "00:11:22:33:44:55",
        "properties": {"manufacturer": "Test"}
    }
    
    response = client.post("/api/devices", json=device_data)
    
    # Verify the response
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Device"  # From the mock
    
    # Verify the service method was called
    mock_device_service.create_device.assert_called_once()


def test_update_device(client, mock_device_service):
    """Test PUT /api/devices/{device_id} endpoint"""
    device_data = {
        "name": "Updated Device",
        "status": "online"
    }
    
    response = client.put("/api/devices/test-device-1", json=device_data)
    
    # Verify the response
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    
    # Verify the service method was called
    mock_device_service.update_device.assert_called_once()
    
    # Test with failed update
    mock_device_service.update_device.return_value = False
    response = client.put("/api/devices/test-device-1", json=device_data)
    assert response.status_code == 404


def test_delete_device(client, mock_device_service):
    """Test DELETE /api/devices/{device_id} endpoint"""
    response = client.delete("/api/devices/test-device-1")
    
    # Verify the response
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    
    # Verify the service method was called
    mock_device_service.delete_device.assert_called_once_with("test-device-1")
    
    # Test with failed deletion
    mock_device_service.delete_device.return_value = False
    response = client.delete("/api/devices/test-device-1")
    assert response.status_code == 404


def test_execute_action(client, mock_device_service):
    """Test POST /api/devices/{device_id}/actions endpoint"""
    action_data = {
        "action": "power",
        "value": "on"
    }
    
    response = client.post("/api/devices/test-device-1/actions", json=action_data)
    
    # Verify the response
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    
    # Verify the service method was called
    mock_device_service.execute_action.assert_called_once_with(
        "test-device-1", "power", {"value": "on"}
    )
    
    # Test with failed action
    mock_device_service.execute_action.return_value = False
    response = client.post("/api/devices/test-device-1/actions", json=action_data)
    assert response.status_code == 400


def test_discover_devices(client):
    """Test POST /api/devices/discover endpoint"""
    with patch('app.api.devices.bluetooth_manager') as mock_bluetooth:
        # Configure mock
        mock_instance = MagicMock()
        mock_bluetooth.return_value = mock_instance
        mock_instance.discover_devices.return_value = [
            {"address": "00:11:22:33:44:55", "name": "Test Device"}
        ]
        
        response = client.post("/api/devices/discover")
        
        # Verify the response
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["address"] == "00:11:22:33:44:55"
        
        # Verify the bluetooth manager method was called
        mock_instance.discover_devices.assert_called_once()