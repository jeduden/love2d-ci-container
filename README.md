# love2d-ci-container

A minimal Debian-based Docker container for running Love2D games in headless/CI environments without requiring a graphics card or audio card.

## Features

- 🐧 **Debian-based**: Built on `debian:bookworm-slim` for minimal size
- 🎮 **Headless Love2D**: Runs Love2D games without GPU/audio hardware using Xvfb
- 🔧 **Development tools**: Includes LuaJIT and Luarocks
- 📦 **Minimal size**: Optimized for small container size
- 🚀 **CI/CD ready**: Perfect for automated testing and continuous integration
- 📸 **Screenshot support**: Capture and extract screenshots for visual regression testing
- 🔊 **Audio testing**: Dummy audio driver for testing audio-enabled games

## Quick Start

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/jeduden/love2d-ci-container:latest
```

### Run your Love2D game

```bash
docker run --rm -v /path/to/your/game:/game ghcr.io/jeduden/love2d-ci-container:latest
```

The container expects your Love2D game to be mounted at `/game`.

## Building Locally

```bash
docker build -t love2d-ci:local .
```

## Testing

Run the included test game:

```bash
docker run --rm -v $(pwd)/test-game:/game love2d-ci:local
```

### Screenshots and Video

Capture screenshots and video recordings from your game for visual testing or documentation:

```bash
# Run game and extract screenshots in one command
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/screenshots:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-screenshot.sh

# Run game and record video (includes screenshots)
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/output:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-record.sh
```

Your screenshots and video will be available in the output directory.

#### How to Use Screenshots in Your Game

In your Love2D game, save screenshots using `love.graphics.captureScreenshot`:

```lua
function love.draw()
    -- Your drawing code here
    love.graphics.print("Hello World", 10, 10)
    
    -- Capture screenshot (must be called from love.draw)
    if needScreenshot then
        love.graphics.captureScreenshot(function(imageData)
            local data = imageData:encode("png")
            love.filesystem.write("screenshots/my_screenshot.png", data)
            print("Screenshot saved!")
        end)
        needScreenshot = false
    end
end
```

Screenshots are saved to Love2D's save directory and can be extracted using the helper scripts.

#### Video Recording

The container includes ffmpeg for recording your game as it runs. The video recording:
- Captures the full game window at 30 FPS
- Outputs in MP4 format (H.264, compatible with GitHub)
- Records the actual visual output, perfect for PR reviews
- **Available in GitHub Actions artifacts** - Download to watch
- Summary shows video metadata and download instructions

## Usage Examples

### In GitHub Actions

#### Basic Test

```yaml
jobs:
  test-game:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test Love2D game
        run: |
          docker run --rm -v ${{ github.workspace }}:/game \
            ghcr.io/jeduden/love2d-ci-container:latest
```

#### With Video Recording and Screenshots

Capture video and screenshots, upload as artifacts:

```yaml
jobs:
  test-game:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run game and record video
        run: |
          mkdir -p output
          docker run --rm \
            -v ${{ github.workspace }}:/game \
            -v ${{ github.workspace }}/output:/output \
            ghcr.io/jeduden/love2d-ci-container:latest \
            /run-and-record.sh
      
      - name: Upload video and screenshots
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: game-recording
          path: output/
```

This captures both video (MP4) and screenshots (PNG) in one step.

This displays screenshots and audio test results directly in the GitHub Actions summary page.

#### Post Screenshots to PR (for Copilot/Agents)

Screenshots can be automatically posted to pull requests for review:

```yaml
jobs:
  test-game:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      
      - name: Run game and capture screenshots
        run: |
          mkdir -p screenshots
          docker run --rm \
            -v ${{ github.workspace }}:/game \
            -v ${{ github.workspace }}/screenshots:/output \
            ghcr.io/jeduden/love2d-ci-container:latest \
            /run-and-screenshot.sh
      
      - name: Post screenshots to PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const files = fs.readdirSync('screenshots').filter(f => f.endsWith('.png'));
            if (files.length === 0) return;
            
            let comment = '## 🎮 Game Screenshots\n\n';
            for (const file of files) {
              const content = fs.readFileSync(`screenshots/${file}`);
              comment += `### ${file}\n![${file}](data:image/png;base64,${content.toString('base64')})\n\n`;
            }
            
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: comment
            });
```

This workflow makes screenshots immediately visible to reviewers and AI agents like GitHub Copilot, enabling visual feedback on game changes.

### Running Luarocks

```bash
docker run --rm love2d-ci:local luarocks --version
```

### Running LuaJIT

```bash
docker run --rm love2d-ci:local luajit -v
```

## Advanced Usage

### Audio Testing

The container supports audio testing using SDL's dummy audio driver (SDL_AUDIODRIVER=dummy). Audio works out of the box without requiring actual audio hardware. Games can play sounds and music normally, output is just not heard.

### Manual Screenshot Extraction

If you've already run your game and want to extract screenshots separately:

```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/output:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /extract-screenshots.sh
```

## Development

The container includes:
- Love2D game engine (version 11.4)
- LuaJIT for high-performance Lua execution
- Luarocks for Lua package management
- Xvfb for headless display
- PulseAudio with null sink for audio testing
- ImageMagick for image processing

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Maintainer

- [@jeduden](https://github.com/jeduden) 
