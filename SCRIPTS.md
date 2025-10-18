# Love2D CI Container Helper Scripts

This document describes the helper scripts available in the Love2D CI container for capturing screenshots, recording video, and extracting game outputs.

## Available Scripts

All scripts are located in the root directory (`/`) of the container and are executable.

### `/run-and-record.sh` - Complete Visual Capture (Recommended)

**Purpose**: Run game and capture video, animated GIF, and screenshots in one command.

**Usage**:
```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/output:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-record.sh
```

**Outputs** (saved to `/output`):
- `game-recording.mp4` - Full quality video (30 FPS, H.264)
- `game-recording.gif` - Animated GIF for inline embedding (~27KB, 10 FPS)
- `frame_*.png` - Individual screenshots (if game captures them)
- `audio-status.txt` - Audio system verification (if generated)
- `audio-info.txt` - Audio test information (if generated)

**Features**:
- Starts Xvfb for headless rendering
- Records video with ffmpeg at 30 FPS
- Converts video to optimized animated GIF
- Extracts screenshots from Love2D save directory
- Handles cleanup and permission setting (chmod 644)

**Best for**: PR reviews, visual regression testing, automated CI/CD workflows

---

### `/run-and-screenshot.sh` - Screenshots Only

**Purpose**: Run game and extract screenshots (no video recording).

**Usage**:
```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/screenshots:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-screenshot.sh
```

**Outputs** (saved to `/output`):
- `frame_*.png` - Screenshot PNG files
- `audio-status.txt` - Audio verification (if generated)
- `audio-info.txt` - Audio information (if generated)

**Features**:
- Starts Xvfb for headless rendering
- Runs the game
- Extracts screenshots from Love2D save directory
- Lighter weight than video recording

**Best for**: Quick screenshot capture, testing without video overhead

---

### `/extract-screenshots.sh` - Extract Only

**Purpose**: Extract screenshots from Love2D save directory (game already ran).

**Usage**:
```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/output:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /extract-screenshots.sh
```

**Outputs** (saved to `/output`):
- Screenshots from `~/.local/share/love/<identity>/screenshots/`
- `audio-status.txt` - If present in save directory
- `audio-info.txt` - If present in save directory

**Features**:
- Automatically detects Love2D game identity from `conf.lua`
- Copies screenshots from save directory to `/output`
- Sets proper file permissions (chmod 644)
- Works with previously run games

**Best for**: Extracting screenshots after manual game execution, debugging

---

### `/run-with-audio.sh` - Audio-Enabled Execution

**Purpose**: Run game with PulseAudio enabled for audio testing.

**Usage**:
```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-with-audio.sh
```

**Features**:
- Starts PulseAudio with null sink
- Runs game with audio enabled
- Uses SDL dummy driver (no actual audio output)
- Verifies audio API functionality

**Best for**: Testing games that use audio APIs, verifying audio system works

---

## Game Integration

### Capturing Screenshots in Your Game

To capture screenshots from your Love2D game, use `love.graphics.captureScreenshot` in `love.draw()`:

```lua
function love.load()
  love.frame = 0
end

function love.update(dt)
  love.frame = love.frame + 1
  
  -- Exit after 180 frames (~3 seconds at 60 FPS)
  if love.frame >= 180 then
    love.event.quit()
  end
end

function love.draw()
  -- Your drawing code here
  love.graphics.print("Frame: " .. love.frame, 10, 10)
  
  -- Capture screenshots at specific frames
  if love.frame == 30 or love.frame == 90 or love.frame == 150 then
    love.graphics.captureScreenshot("frame_" .. love.frame .. ".png")
  end
end
```

Screenshots are saved to Love2D's save directory:
- Location: `~/.local/share/love/<identity>/screenshots/`
- Format: PNG
- Extracted automatically by helper scripts

### Setting Game Identity

Set your game identity in `conf.lua` for consistent save directory location:

```lua
function love.conf(t)
  t.identity = "my-game-name"  -- Used for save directory
  t.window.width = 800
  t.window.height = 600
  -- Other config options...
end
```

---

## Output Directory Structure

After running `/run-and-record.sh`, your output directory will contain:

```
output/
├── game-recording.mp4      # Full quality video (30 FPS, ~35KB)
├── game-recording.gif      # Animated GIF (10 FPS, ~27KB)
├── frame_30.png            # Screenshot at frame 30
├── frame_90.png            # Screenshot at frame 90
├── frame_150.png           # Screenshot at frame 150
├── audio-status.txt        # Audio system status (if generated)
└── audio-info.txt          # Audio test info (if generated)
```

All files have permissions set to 644 (rw-r--r--) for easy access.

---

## GitHub Actions Integration

### Example Workflow with Video and Screenshots

```yaml
name: Test Love2D Game

on: [push, pull_request]

jobs:
  test-game:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run game and capture video + screenshots
        run: |
          mkdir -p output
          docker run --rm \
            -v ${{ github.workspace }}/your-game:/game \
            -v ${{ github.workspace }}/output:/output \
            ghcr.io/jeduden/love2d-ci-container:latest \
            /run-and-record.sh
      
      - name: Upload outputs as artifacts
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: game-outputs
          path: output/
      
      - name: Post animated GIF to PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            
            // Read and encode animated GIF
            const gifData = fs.readFileSync('output/game-recording.gif');
            const gifBase64 = gifData.toString('base64');
            
            // Read screenshots
            const screenshots = fs.readdirSync('output')
              .filter(f => f.endsWith('.png'))
              .sort();
            
            // Build comment with embedded GIF and screenshots
            let comment = '## 🎮 Game Test Results\n\n';
            comment += '### Animated Recording\n\n';
            comment += `![Game Recording](data:image/gif;base64,${gifBase64})\n\n`;
            comment += '### Individual Screenshots\n\n';
            
            for (const file of screenshots) {
              const imgData = fs.readFileSync(`output/${file}`);
              const imgBase64 = imgData.toString('base64');
              comment += `**${file}**\n\n`;
              comment += `![${file}](data:image/png;base64,${imgBase64})\n\n`;
            }
            
            comment += '\nFull quality MP4 video available in artifacts.';
            
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: comment
            });
```

---

## Troubleshooting

### No screenshots generated

**Cause**: Game doesn't call `love.graphics.captureScreenshot()`

**Solution**: Add screenshot capture code to your game (see "Capturing Screenshots" above)

### Permission denied when accessing files

**Cause**: Files created with wrong permissions

**Solution**: All helper scripts automatically set permissions to 644. If issues persist, check Docker volume mounting.

### Video too short or too long

**Cause**: Default recording time is 10 seconds in `/run-and-record.sh`

**Solution**: Modify the script or control game exit time with `love.event.quit()` in your game code

### Audio not working

**Cause**: Audio hardware not available in container

**Solution**: This is expected. The container uses SDL dummy driver. Audio APIs work correctly, but no sound is produced. Use `/run-with-audio.sh` for audio testing.

---

## Performance Notes

- **Video recording**: ~35KB for 3 seconds at 30 FPS (H.264 ultrafast preset)
- **Animated GIF**: ~27KB for 3 seconds at 10 FPS (optimized with lanczos scaling)
- **Screenshots**: ~3-4KB each (800x600 PNG)
- **Container startup**: ~1-2 seconds for Xvfb initialization
- **Total execution time**: Game runtime + 2-3 seconds overhead

---

## Technical Details

### Video Encoding

- **Codec**: H.264 (libx264)
- **Frame rate**: 30 FPS
- **Preset**: ultrafast (for CI speed)
- **Pixel format**: yuv420p (compatibility)
- **Resolution**: 800x600 (from game config)

### GIF Conversion

- **Frame rate**: 10 FPS (reduced from 30 for size)
- **Scaling**: lanczos filter (high quality)
- **Width**: 800px (maintains aspect ratio)
- **Optimization**: ffmpeg gif codec

### Screenshot Format

- **Format**: PNG (lossless)
- **Bit depth**: 24-bit RGB
- **Resolution**: Matches game window size (typically 800x600)
- **Compression**: PNG default compression

---

## See Also

- [Main README](../README.md) - Container overview and quick start
- [Copilot Instructions](../.github/copilot-instructions.md) - AI agent integration
- [GitHub Actions Examples](../examples/github-actions-example.yml) - Complete workflow examples
- [Examples README](../examples/README.md) - More usage examples
