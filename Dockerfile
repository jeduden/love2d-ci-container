# Use minimal Debian slim image
FROM debian:bookworm-slim

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Love2D headless mode
RUN apt-get update && apt-get install -y --no-install-recommends \
    # LuaJIT
    luajit \
    # Luarocks
    luarocks \
    # Required for headless operation
    xvfb \
    # Minimal X11 libraries for headless rendering
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    # PulseAudio for dummy audio driver
    pulseaudio \
    # For screenshot conversion (optional but recommended)
    imagemagick \
    # Install love but work around the postinst alternatives issue
    && apt-get install -y --no-install-recommends love || true \
    # Create the missing man page directory and file to fix the alternatives issue
    && mkdir -p /usr/share/man/man6 \
    && touch /usr/share/man/man6/love-11.4.6.gz \
    && dpkg --configure -a \
    # Clean up to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create game directory
RUN mkdir -p /game

# Copy helper scripts
COPY run-with-audio.sh /run-with-audio.sh
COPY extract-screenshots.sh /extract-screenshots.sh
COPY run-and-screenshot.sh /run-and-screenshot.sh
RUN chmod +x /run-with-audio.sh /extract-screenshots.sh /run-and-screenshot.sh

# Set working directory
WORKDIR /game

# Set up Xvfb for headless operation
ENV DISPLAY=:99

# Disable SDL audio to prevent ALSA errors in headless mode
# Set to "dummy" to enable audio module without hardware
ENV SDL_AUDIODRIVER=dummy

# Default command runs love on /game directory with Xvfb
CMD ["/bin/sh", "-c", "Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & sleep 1 && love /game"]
