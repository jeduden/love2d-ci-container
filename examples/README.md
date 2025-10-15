# Examples

This directory contains examples of how to use the Love2D CI container.

## GitHub Actions

See [github-actions-example.yml](github-actions-example.yml) for an example of how to use the container in GitHub Actions CI/CD pipelines.

## Docker Compose

See [docker-compose.yml](docker-compose.yml) for an example of how to use the container with Docker Compose.

## Basic Usage

### Run a game from the command line

```bash
docker run --rm -v /path/to/your/game:/game ghcr.io/jeduden/love2d-ci-container:latest
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
