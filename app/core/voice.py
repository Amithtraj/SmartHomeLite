"""Voice Recognition

This module handles voice recognition for the SmartHomeLite application.
It is optional and only enabled if VOICE_ENABLED is set to True in the settings.
"""

import asyncio
import os
import json
from typing import Dict, Any, Callable, List, Optional
from loguru import logger

from config import settings

# Try to import speech_recognition, but don't fail if it's not available
try:
    import speech_recognition as sr
    SPEECH_RECOGNITION_AVAILABLE = True
except ImportError:
    SPEECH_RECOGNITION_AVAILABLE = False
    logger.warning("speech_recognition not available, voice recognition will be limited")

# Try to import vosk, but don't fail if it's not available
try:
    from vosk import Model, KaldiRecognizer
    VOSK_AVAILABLE = True
except ImportError:
    VOSK_AVAILABLE = False
    logger.warning("vosk not available, offline voice recognition will be disabled")


class VoiceRecognizer:
    """Voice recognition for SmartHomeLite"""

    def __init__(self):
        """Initialize the voice recognizer"""
        self.recognizer = None
        self.microphone = None
        self.vosk_model = None
        self.vosk_recognizer = None
        self.running = False
        self.recognition_task = None
        self.command_callbacks: Dict[str, Callable] = {}
        self.commands: Dict[str, List[str]] = {
            "turn_on": ["turn on", "switch on", "power on"],
            "turn_off": ["turn off", "switch off", "power off"],
            "status": ["status", "state", "how is"],
            "discover": ["discover", "find", "search"],
        }

    async def start(self) -> bool:
        """Start voice recognition"""
        if not settings.VOICE_ENABLED:
            logger.info("Voice recognition disabled in settings")
            return False

        if self.running:
            logger.warning("Voice recognition already running")
            return True

        # Initialize the appropriate voice recognition engine
        if settings.VOICE_ENGINE == "vosk":
            success = await self._init_vosk()
        else:  # Default to Google/speech_recognition
            success = await self._init_speech_recognition()

        if not success:
            logger.error("Failed to initialize voice recognition")
            return False

        # Start the recognition loop
        self.running = True
        self.recognition_task = asyncio.create_task(self._recognition_loop())
        logger.info("Started voice recognition")
        return True

    async def stop(self) -> None:
        """Stop voice recognition"""
        if not self.running:
            return

        self.running = False
        if self.recognition_task:
            self.recognition_task.cancel()
            try:
                await self.recognition_task
            except asyncio.CancelledError:
                pass
        logger.info("Stopped voice recognition")

    async def _init_speech_recognition(self) -> bool:
        """Initialize the speech_recognition engine"""
        if not SPEECH_RECOGNITION_AVAILABLE:
            logger.error("speech_recognition not available")
            return False

        try:
            self.recognizer = sr.Recognizer()
            self.microphone = sr.Microphone()

            # Adjust for ambient noise
            with self.microphone as source:
                self.recognizer.adjust_for_ambient_noise(source)

            logger.info("Initialized speech_recognition engine")
            return True

        except Exception as e:
            logger.error(f"Error initializing speech_recognition: {e}")
            return False

    async def _init_vosk(self) -> bool:
        """Initialize the vosk engine"""
        if not VOSK_AVAILABLE:
            logger.error("vosk not available")
            return False

        try:
            # Check if model exists
            model_path = os.path.join(os.path.dirname(__file__), "../../models/vosk-model-small-en-us")
            if not os.path.exists(model_path):
                logger.error(f"Vosk model not found at {model_path}")
                return False

            # Initialize vosk model and recognizer
            self.vosk_model = Model(model_path)
            self.vosk_recognizer = KaldiRecognizer(self.vosk_model, 16000)

            logger.info("Initialized vosk engine")
            return True

        except Exception as e:
            logger.error(f"Error initializing vosk: {e}")
            return False

    async def _recognition_loop(self) -> None:
        """Run continuous voice recognition"""
        if settings.VOICE_ENGINE == "vosk":
            await self._vosk_recognition_loop()
        else:  # Default to Google/speech_recognition
            await self._speech_recognition_loop()

    async def _speech_recognition_loop(self) -> None:
        """Run continuous voice recognition with speech_recognition"""
        while self.running:
            try:
                with self.microphone as source:
                    logger.debug("Listening for commands...")
                    audio = self.recognizer.listen(source, timeout=5, phrase_time_limit=5)

                try:
                    # Use Google's speech recognition
                    text = self.recognizer.recognize_google(audio)
                    logger.info(f"Recognized: {text}")

                    # Process the command
                    await self._process_command(text)

                except sr.UnknownValueError:
                    logger.debug("Could not understand audio")
                except sr.RequestError as e:
                    logger.error(f"Error with speech recognition service: {e}")

            except Exception as e:
                logger.error(f"Error in speech recognition loop: {e}")

            # Small delay to prevent CPU overuse
            await asyncio.sleep(0.1)

    async def _vosk_recognition_loop(self) -> None:
        """Run continuous voice recognition with vosk"""
        # This is a simplified implementation
        # In a real application, you would need to handle audio input from the microphone
        # and feed it to the vosk recognizer
        logger.warning("Vosk recognition loop not fully implemented")
        while self.running:
            # Placeholder for actual implementation
            await asyncio.sleep(1)

    async def _process_command(self, text: str) -> None:
        """Process a recognized voice command"""
        text = text.lower()
        logger.debug(f"Processing command: {text}")

        # Check for device commands
        for command_type, phrases in self.commands.items():
            for phrase in phrases:
                if phrase in text:
                    # Extract device name (if any)
                    # This is a simple implementation that assumes the device name
                    # comes after the command phrase
                    parts = text.split(phrase)
                    if len(parts) > 1:
                        device_name = parts[1].strip()
                    else:
                        device_name = ""

                    # Call the appropriate callback if registered
                    if command_type in self.command_callbacks:
                        await self.command_callbacks[command_type](device_name)
                    return

        logger.debug(f"No matching command found for: {text}")

    def register_command_callback(
        self, command_type: str, callback: Callable[[str], None]
    ) -> None:
        """Register a callback for a specific command type"""
        self.command_callbacks[command_type] = callback
        logger.debug(f"Registered callback for command type: {command_type}")

    def add_command_phrases(self, command_type: str, phrases: List[str]) -> None:
        """Add additional phrases for a command type"""
        if command_type in self.commands:
            self.commands[command_type].extend(phrases)
        else:
            self.commands[command_type] = phrases
        logger.debug(f"Added phrases for command type {command_type}: {phrases}")