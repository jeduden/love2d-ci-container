#!/bin/bash
# Run Love2D game and record video
# Usage: docker run --rm -v $(pwd)/game:/game -v $(pwd)/output:/output love2d-ci /run-and-record.sh

set -e

# Start Xvfb
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

# Start ffmpeg recording
echo "Starting video recording..."
ffmpeg -f x11grab -video_size 800x600 -framerate 30 -i :99.0 -c:v libx264 -preset ultrafast -pix_fmt yuv420p -t 10 /tmp/game-recording.mp4 > /dev/null 2>&1 &
FFMPEG_PID=$!

# Give ffmpeg a moment to start
sleep 1

# Run the game
echo "Running Love2D game..."
love /game

# Wait a moment for the game to fully exit
sleep 1

# Stop ffmpeg gracefully
kill -INT $FFMPEG_PID 2>/dev/null || true
wait $FFMPEG_PID 2>/dev/null || true

# Stop Xvfb
kill $XVFB_PID 2>/dev/null || true

echo "Video recording complete"

# Copy video to output if available
if [ -f /tmp/game-recording.mp4 ] && [ -d /output ]; then
    cp /tmp/game-recording.mp4 /output/
    chmod 644 /output/game-recording.mp4
    echo "Video saved to /output/game-recording.mp4"
fi

# Also run screenshot extraction
if [ -f /extract-screenshots.sh ]; then
    /extract-screenshots.sh
fi
