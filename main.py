#!/usr/bin/env python3
"""
SmartHomeLite - A Python-based local smart home hub for Android (Termux)

This is the main entry point for the application.
It initializes the FastAPI app, sets up routes, and starts the server.
"""

import os
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from loguru import logger

# Import application modules
from app.api import devices, system
from app.web.routes import router as web_router
from app.core.bluetooth import BluetoothManager
from config import settings

# Configure logger
logger.add(
    "logs/smarthomelite.log",
    rotation="10 MB",
    retention="7 days",
    level="INFO",
    backtrace=True,
    diagnose=True,
)

# Create FastAPI app
app = FastAPI(
    title="SmartHomeLite",
    description="A Python-based local smart home hub for Android (Termux)",
    version="0.1.0",
)

# Initialize core components
bluetooth_manager = BluetoothManager()

# Include API routers
app.include_router(devices.router, prefix="/api/devices", tags=["devices"])
app.include_router(system.router, prefix="/api/system", tags=["system"])

# Include web routes
app.include_router(web_router)

# Mount static files
app.mount(
    "/static",
    StaticFiles(directory=os.path.join(os.path.dirname(__file__), "app/web/static")),
    name="static",
)


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    logger.info("Starting SmartHomeLite...")
    # Initialize Bluetooth discovery
    await bluetooth_manager.start_discovery()
    logger.info(f"Server running at http://{settings.HOST}:{settings.PORT}")


@app.on_event("shutdown")
async def shutdown_event():
    """Clean up resources on shutdown"""
    logger.info("Shutting down SmartHomeLite...")
    # Stop Bluetooth discovery
    await bluetooth_manager.stop_discovery()


if __name__ == "__main__":
    # Create logs directory if it doesn't exist
    os.makedirs("logs", exist_ok=True)
    
    # Run the application
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level="info",
    )