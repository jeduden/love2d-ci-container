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

### Screenshots

Capture and extract screenshots from your game for visual testing or documentation:

```bash
# Run game and extract screenshots in one command
docker run --rm \
  -v $(pwd)/your-game:/game \
  -v $(pwd)/screenshots:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-screenshot.sh
```

Your screenshots will be available in the `./screenshots` directory.

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

#### With Screenshot Capture

Capture screenshots during testing and upload them as artifacts:

```yaml
jobs:
  test-game:
    runs-on: ubuntu-latest
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
      
      - name: Upload screenshots
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: game-screenshots
          path: screenshots/
          retention-days: 30
```

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
      
      - name: Comment screenshots on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const path = require('path');
            
            // Read all screenshots
            const screenshotDir = 'screenshots';
            const files = fs.readdirSync(screenshotDir);
            
            // Create comment with screenshots
            let comment = '## 🎮 Game Screenshots\n\n';
            comment += 'Screenshots captured during test run:\n\n';
            
            for (const file of files) {
              if (file.endsWith('.png')) {
                const content = fs.readFileSync(path.join(screenshotDir, file));
                const base64 = content.toString('base64');
                comment += `### ${file}\n`;
                comment += `![${file}](data:image/png;base64,${base64})\n\n`;
              }
            }
            
            // Post comment
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

The container includes PulseAudio with dummy drivers for testing games with audio:

```bash
docker run --rm \
  -v $(pwd)/your-game:/game \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-with-audio.sh
```

Note: Audio is disabled by default in the test game for faster startup. Enable it in `conf.lua`:

```lua
function love.conf(t)
    t.modules.audio = true  -- Enable audio module
end
```

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
