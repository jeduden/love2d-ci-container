#!/bin/bash
# Run Love2D game and extract screenshots
# Usage: docker run --rm -v $(pwd)/game:/game -v $(pwd)/output:/output love2d-ci /run-and-screenshot.sh

set -e

# Start Xvfb
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
sleep 1

# Run the game
echo "Running Love2D game..."
love /game

# Extract screenshots if they exist
echo "Extracting screenshots..."
/extract-screenshots.sh
