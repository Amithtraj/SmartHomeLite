#!/usr/bin/env python3
"""
SmartHomeLite - Run Script

This script provides a convenient way to start the SmartHomeLite application.
It handles command-line arguments for configuration and starts the server.
"""

import argparse
import os
import sys
import uvicorn
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()


def parse_args():
    """Parse command-line arguments"""
    parser = argparse.ArgumentParser(description="SmartHomeLite - Local Smart Home Hub")
    
    parser.add_argument(
        "--host", 
        type=str, 
        default=os.getenv("SERVER_HOST", "0.0.0.0"),
        help="Host to bind the server to (default: 0.0.0.0)"
    )
    
    parser.add_argument(
        "--port", 
        type=int, 
        default=int(os.getenv("SERVER_PORT", "8000")),
        help="Port to bind the server to (default: 8000)"
    )
    
    parser.add_argument(
        "--debug", 
        action="store_true", 
        default=os.getenv("DEBUG_MODE", "false").lower() in ("true", "1", "yes"),
        help="Enable debug mode"
    )
    
    parser.add_argument(
        "--reload", 
        action="store_true", 
        default=False,
        help="Enable auto-reload for development"
    )
    
    return parser.parse_args()


def main():
    """Main entry point"""
    args = parse_args()
    
    print(f"Starting SmartHomeLite on {args.host}:{args.port}")
    print(f"Debug mode: {'enabled' if args.debug else 'disabled'}")
    print(f"Auto-reload: {'enabled' if args.reload else 'disabled'}")
    
    # Set environment variables based on arguments
    os.environ["SERVER_HOST"] = args.host
    os.environ["SERVER_PORT"] = str(args.port)
    os.environ["DEBUG_MODE"] = str(args.debug).lower()
    
    # Create data directory if it doesn't exist
    data_dir = os.getenv("DATA_DIR", "./data")
    os.makedirs(data_dir, exist_ok=True)
    
    # Start the server
    uvicorn.run(
        "main:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
        log_level="debug" if args.debug else "info"
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nShutting down SmartHomeLite...")
        sys.exit(0)