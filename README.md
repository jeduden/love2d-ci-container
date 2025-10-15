# love2d-ci-container

A minimal Debian-based Docker container for running Love2D games in headless/CI environments without requiring a graphics card or audio card.

## Features

- 🐧 **Debian-based**: Built on `debian:bookworm-slim` for minimal size
- 🎮 **Headless Love2D**: Runs Love2D games without GPU/audio hardware using Xvfb
- 🔧 **Development tools**: Includes LuaJIT and Luarocks
- 📦 **Minimal size**: Optimized for small container size
- 🚀 **CI/CD ready**: Perfect for automated testing and continuous integration

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

## Usage Examples

### In GitHub Actions

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

### Running Luarocks

```bash
docker run --rm love2d-ci:local luarocks --version
```

### Running LuaJIT

```bash
docker run --rm love2d-ci:local luajit -v
```

## Development

The container includes:
- Love2D game engine
- LuaJIT for high-performance Lua execution
- Luarocks for Lua package management
- Xvfb for headless display

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Maintainer

- [@jeduden](https://github.com/jeduden) 
