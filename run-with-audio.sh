#!/bin/bash
# Run Love2D game with audio enabled using dummy drivers
# This script sets up PulseAudio with a null sink for headless audio testing

set -e

# Start PulseAudio in the background with null sink
pulseaudio --start --exit-idle-time=-1 --log-target=stderr 2>/dev/null || true
pactl load-module module-null-sink 2>/dev/null || true

# Start Xvfb
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
sleep 1

# Run the game
love /game "$@"
