# SmartHomeLite Utility Scripts

This document provides an overview of the utility scripts available for managing your SmartHomeLite application.

## Setup Scripts

### Platform-Specific Setup

- **windows_setup.bat** - Setup script for Windows systems
- **macos_setup.sh** - Setup script for macOS systems
- **raspberry_pi_setup.sh** - Setup script for Raspberry Pi systems
- **termux_setup.sh** - Setup script for Android using Termux

### Docker Setup

- **docker_setup.sh** / **docker_setup.bat** - Set up SmartHomeLite using Docker
- **docker_run.sh** / **docker_run.bat** - Run SmartHomeLite in Docker
- **docker_stop.sh** / **docker_stop.bat** - Stop SmartHomeLite Docker containers
- **docker_logs.sh** / **docker_logs.bat** - View logs from SmartHomeLite Docker containers
- **docker_restart.sh** / **docker_restart.bat** - Restart SmartHomeLite Docker containers
- **docker_update.sh** / **docker_update.bat** - Update SmartHomeLite Docker containers

## MQTT Scripts

- **mqtt/setup_mqtt.sh** - Set up MQTT directories and configuration
- **mqtt/create_mqtt_user.sh** - Create MQTT user credentials

## Data Management Scripts

- **create_data_dir.sh** / **create_data_dir.bat** - Create the data directory structure
- **backup_data.sh** / **backup_data.bat** - Create a backup of your data
- **restore_backup.sh** / **restore_backup.bat** - Restore from a backup
- **cleanup_backups.sh** / **cleanup_backups.bat** - Clean up old backup files
- **reset_app.sh** / **reset_app.bat** - Reset the application to its initial state

## Device Management Scripts

- **generate_sample_device.sh** / **generate_sample_device.bat** - Generate a sample device configuration

## Diagnostic Scripts

- **check_requirements.sh** / **check_requirements.bat** - Check if your system meets the requirements
- **check_status.sh** / **check_status.bat** - Check the status of your SmartHomeLite application

## Usage Instructions

### On Unix-like Systems (Linux, macOS)

1. Make the script executable:
   ```bash
   chmod +x script_name.sh
   ```

2. Run the script:
   ```bash
   ./script_name.sh
   ```

### On Windows

1. Run the batch script by double-clicking it or from Command Prompt:
   ```cmd
   script_name.bat
   ```

## Common Tasks

### Setting Up the Application

1. Run the appropriate setup script for your platform
2. Create the data directory: `create_data_dir.sh` or `create_data_dir.bat`
3. Generate a sample device: `generate_sample_device.sh` or `generate_sample_device.bat`
4. Start the application: `python run.py`

### Using Docker

1. Run the Docker setup script: `docker_setup.sh` or `docker_setup.bat`
2. Start the application: `docker_run.sh` or `docker_run.bat`
3. View logs: `docker_logs.sh` or `docker_logs.bat`
4. Stop the application: `docker_stop.sh` or `docker_stop.bat`

### Backing Up and Restoring Data

1. Create a backup: `backup_data.sh` or `backup_data.bat`
2. Restore from a backup: `restore_backup.sh` or `restore_backup.bat`
3. Clean up old backups: `cleanup_backups.sh` or `cleanup_backups.bat`

### Troubleshooting

1. Check system requirements: `check_requirements.sh` or `check_requirements.bat`
2. Check application status: `check_status.sh` or `check_status.bat`
3. Reset the application: `reset_app.sh` or `reset_app.bat`

## Notes

- Most scripts will ask for confirmation before performing destructive actions
- Backup scripts automatically create a `backups` directory to store backup files
- Docker scripts require Docker and Docker Compose to be installed
- MQTT scripts are only needed if you're using MQTT devices