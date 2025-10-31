# Examples

This directory contains examples of how to use the Love2D CI container.

## GitHub Actions

See [github-actions-example.yml](github-actions-example.yml) for a complete example showing:
- Basic game testing
- Screenshot capture
- Uploading screenshots as artifacts
- Posting screenshots to pull requests for review by teams and AI agents

## Docker Compose

See [docker-compose.yml](docker-compose.yml) for an example of how to use the container with Docker Compose.

## Basic Usage

### Run a game from the command line

```bash
docker run --rm -v /path/to/your/game:/game ghcr.io/jeduden/love2d-ci-container:latest
```

### Run game and capture screenshots

```bash
docker run --rm \
  -v /path/to/your/game:/game \
  -v $(pwd)/screenshots:/output \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-and-screenshot.sh
```

Screenshots will be available in `./screenshots/` directory.

### Run with audio enabled

```bash
docker run --rm \
  -v /path/to/your/game:/game \
  ghcr.io/jeduden/love2d-ci-container:latest \
  /run-with-audio.sh
```

### Run a Lua script with LuaJIT

```bash
docker run --rm -v $(pwd):/game ghcr.io/jeduden/love2d-ci-container:latest luajit /game/script.lua
```

### Install a Lua package with Luarocks

```bash
docker run --rm -v $(pwd):/game ghcr.io/jeduden/love2d-ci-container:latest \
  luarocks install luasocket
```

### Interactive shell

```bash
docker run --rm -it -v $(pwd):/game ghcr.io/jeduden/love2d-ci-container:latest /bin/bash
```

## Screenshot Integration for AI Agents

The screenshot functionality is particularly useful for AI agents like GitHub Copilot to:

1. **Visual Regression Testing**: Compare screenshots across commits to detect visual changes
2. **Automated Review**: AI can analyze screenshots and provide feedback on visual issues
3. **Documentation**: Automatically generate visual documentation of game states
4. **Debugging**: Capture game state at specific moments for analysis

The example workflow shows how to embed screenshots directly in PR comments using base64 encoding, making them immediately visible to reviewers and agents without requiring additional storage services.
