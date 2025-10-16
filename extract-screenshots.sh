#!/bin/bash
# Extract screenshots from Love2D game save directory
# Usage: docker run --rm -v $(pwd)/game:/game -v $(pwd)/output:/output love2d-ci /extract-screenshots.sh

set -e

# Love2D saves files to ~/.local/share/love/<identity>
# Find the identity from conf.lua or use default
IDENTITY="love2d-ci-test"

if [ -f /game/conf.lua ]; then
    # Try to extract identity from conf.lua
    FOUND_IDENTITY=$(grep -oP 't\.identity\s*=\s*"\K[^"]+' /game/conf.lua 2>/dev/null || echo "")
    if [ -n "$FOUND_IDENTITY" ]; then
        IDENTITY="$FOUND_IDENTITY"
    fi
fi

SAVE_DIR="$HOME/.local/share/love/$IDENTITY"

echo "Looking for screenshots in: $SAVE_DIR/screenshots"

if [ -d "$SAVE_DIR/screenshots" ]; then
    # Copy screenshots to output directory
    mkdir -p /output
    cp -v "$SAVE_DIR/screenshots"/* /output/ 2>/dev/null || echo "No screenshots found"
    # Fix permissions so files are readable by the host user
    chmod 644 /output/*.png 2>/dev/null || true
    echo "Screenshots extracted to /output"
else
    echo "No screenshots directory found at $SAVE_DIR/screenshots"
    exit 1
fi

# Also extract audio status file if it exists
if [ -f "$SAVE_DIR/audio-status.txt" ]; then
    cp -v "$SAVE_DIR/audio-status.txt" /output/
    chmod 644 /output/audio-status.txt 2>/dev/null || true
    echo "Audio status extracted to /output"
fi
