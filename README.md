Project overview

Use case with Android phone + Windows laptop + ADB

Setup instructions for both environments

Port forwarding for remote access

API usage examples

Extras like background running and Bluetooth control

markdown
Copy
Edit
# SmartHomeLite

SmartHomeLite is a lightweight, modular **Python-based smart home hub** that runs directly on an **Android phone** using **Termux**. The phone acts as the local brain, and you can control the entire setup from a **Windows laptop** via **ADB (Android Debug Bridge)** and a web-based interface or REST API.

This allows you to turn an old phone into a private, offline-ready smart hub for home automation, IoT prototyping, or educational projects.

---

## 🚀 Features

- Run on Android (Termux) with Python 3 and FastAPI
- Bluetooth device discovery & control (e.g. speakers)
- REST API for managing smart devices
- Minimal web UI (HTML + HTMX) for easy control
- ADB port forwarding for remote control via Windows laptop
- Optional voice control (Vosk, SpeechRecognition)

---

## 📸 Architecture Overview

[ Windows Laptop ]
│ ADB
▼
[ Android Phone (Poco X3) ]
│ Termux + Python
▼
[ FastAPI Server + Bluetooth Scripts ]
│
├── REST API
└── Web Dashboard (localhost:8000)

yaml
Copy
Edit

---

## 🖥️ Control via Windows Laptop (with ADB)

### ✅ Prerequisites

- Android phone (Poco X3 recommended)
- Termux (from [F-Droid](https://f-droid.org/en/packages/com.termux/))
- ADB installed on Windows  
  Download: [Android Platform Tools](https://developer.android.com/tools/releases/platform-tools)
- USB Debugging enabled on Android  
  _Settings → Developer Options → USB Debugging_

---

## ⚙️ Setup Instructions

### 1. 📱 Install on Phone (Termux)

```bash
pkg update && pkg upgrade
pkg install git python
git clone https://github.com/YOUR_USERNAME/SmartHomeLite.git
cd SmartHomeLite
bash termux_setup.sh
This will:

Set up a virtual environment

Install required Python packages

Configure FastAPI and Bluetooth dependencies

2. 🧠 Start the Hub on Android
bash
Copy
Edit
cd ~/SmartHomeLite
source venv/bin/activate
python run.py --host 127.0.0.1 --port 8000
3. 💻 Set Up ADB Port Forwarding (on Windows)
cmd
Copy
Edit
adb devices
adb forward tcp:8000 tcp:8000
This lets you access the phone’s SmartHomeLite server from your laptop via localhost:8000.

🌐 Access Web Interface
Open your browser on your Windows laptop:

arduino
Copy
Edit
http://localhost:8000
Explore:

Device list

Discover Bluetooth devices

Toggle speakers

(Optional) Voice control triggers

🔌 API Endpoints
You can use Postman or curl to test these endpoints.

Device Management
Method	Endpoint	Description
GET	/api/devices	List all registered devices
POST	/api/devices	Register new device
GET	/api/devices/discover	Scan for nearby BT devices
POST	/api/devices/{device_id}/action	Trigger an action (e.g., play)

Example:

http
Copy
Edit
POST /api/devices/abc123/action
{
  "action_type": "on",
  "value": null
}
🔒 Optional: Enable API Key Security
Edit .env:

env
Copy
Edit
API_KEY_REQUIRED=true
API_KEY=your_secure_api_key
Then in your headers:

http
Copy
Edit
X-API-Key: your_secure_api_key
🧪 Run as a Background Service
To keep the app running after closing Termux:

Install Termux:Boot add-on

Create ~/.termux/boot/start_smarthomelite.sh

bash
Copy
Edit
#!/data/data/com.termux/files/usr/bin/bash
cd ~/SmartHomeLite
source venv/bin/activate
nohup python run.py --host 127.0.0.1 --port 8000 &
Make it executable:

bash
Copy
Edit
chmod +x ~/.termux/boot/start_smarthomelite.sh
🔊 Control Bluetooth Speakers
Ensure Bluetooth is enabled on your phone

Visit the web dashboard or use the /discover endpoint

Connect to your speaker

Use /action to send commands like play, pause, or disconnect

🧱 Project Structure
php
Copy
Edit
SmartHomeLite/
├── app/
│   ├── main.py               # FastAPI entrypoint
│   ├── bluetooth_control.py  # Bluetooth scan & control
│   ├── device_registry.py    # Store connected device state
│   └── voice_control.py      # Optional voice logic
├── templates/                # Web UI (HTMX/Jinja)
├── static/                   # JS/CSS assets
├── termux_setup.sh
├── run.py                    # Entry script
├── requirements.txt
└── .env.example
👨‍💻 Author
Amith T Raj
Built with ❤️ for offline-first smart home control via Python.

📜 License
MIT License

✅ TODO / Future Enhancements
✅ Add MQTT integration for ESP8266 sensors

✅ Add offline voice trigger ("Turn on speaker")

🔄 Sync device states with cloud (optional)

🔐 Role-based access & user accounts

🛜 Remote control via Ngrok or dynamic DNS

💡 Turn your old phone into a self-hosted smart home controller — private, offline, hackable.
