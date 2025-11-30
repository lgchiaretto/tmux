# Build Static tmux

This directory contains scripts and configuration to build a fully static tmux binary for Linux using musl libc.

## Overview

The build process compiles the following components from source:
1. **musl libc** - Provides static C library and `musl-gcc` wrapper
2. **libevent** - Event notification library
3. **ncurses** - Terminal handling library
4. **tmux** - Terminal multiplexer

The resulting binary is completely static and runs on any Linux distribution without dynamic library dependencies.

## Requirements

### For direct build on Fedora/RHEL:
- gcc
- make
- wget
- tar
- gzip
- xz
- bison

Install with:
```bash
sudo dnf install -y gcc make wget tar gzip xz bison
```

### For container build:
- Podman or Docker

## Usage

### Method 1: Direct Build

Build directly on your system:

```bash
# Make script executable
chmod +x build-static-tmux.sh

# Build with default settings (tmux 3.6)
./build-static-tmux.sh

# Build specific version
./build-static-tmux.sh -v 3.4

# Build with UPX compression
./build-static-tmux.sh -c

# Build with verbose error output
./build-static-tmux.sh -d
```

### Method 2: Build with Podman/Docker

Use a container to build (recommended for isolation):

```bash
# Make script executable
chmod +x build-with-podman.sh

# Build with default settings
./build-with-podman.sh

# Build specific version
./build-with-podman.sh -v 3.4

# Build with UPX compression
./build-with-podman.sh -c
```

### Method 3: Manual Container Build

```bash
# Build container image
podman build -t tmux-static-builder -f Containerfile .

# Run build
podman run --rm -v $(pwd)/output:/output:Z tmux-static-builder

# Build specific version with UPX
podman run --rm \
    -e TMUX_VERSION=3.5 \
    -e USE_UPX=1 \
    -v $(pwd)/output:/output:Z \
    tmux-static-builder
```

## Output Files

After building, the following files are created:

| File | Description |
|------|-------------|
| `tmux.linux-amd64.gz` | Standard static binary (gzipped) |
| `tmux.linux-amd64.stripped.gz` | Stripped binary, smaller size (gzipped) |
| `tmux.linux-amd64.upx.gz` | UPX compressed binary, smallest (gzipped, if -c used) |

### Using the Binary

```bash
# Extract
gunzip tmux.linux-amd64.stripped.gz

# Make executable
chmod +x tmux.linux-amd64.stripped

# Run
./tmux.linux-amd64.stripped

# Or copy to your PATH
sudo mv tmux.linux-amd64.stripped /usr/local/bin/tmux
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TMUX_VERSION` | tmux version to build | 3.6 |
| `MUSL_VERSION` | musl libc version | 1.2.5 |
| `NCURSES_VERSION` | ncurses version | 6.5 |
| `LIBEVENT_VERSION` | libevent version | 2.1.12 |
| `UPX_VERSION` | UPX version | 5.0.2 |
| `TMUX_STATIC_HOME` | Build directory | /tmp/tmux-static |
| `USE_UPX` | Enable UPX compression (1/0) | 0 |
| `DUMP_LOG_ON_ERROR` | Show logs on error (1/0) | 0 |

## GitHub Actions

The workflow in `.github/workflows/build-static-tmux.yml` automatically:

1. Builds on releases - when a new release is published
2. Supports manual trigger with version selection
3. Tests the built binary
4. Uploads artifacts
5. Attaches binaries to releases

### Triggering Manual Build

1. Go to Actions tab in GitHub
2. Select "Build Static tmux" workflow
3. Click "Run workflow"
4. Enter tmux version and options
5. Click "Run workflow"

## Supported Architectures

- `linux-amd64` (x86_64)
- `linux-arm64` (aarch64) - when building on ARM systems

## Troubleshooting

### Build fails with dependency error
```bash
# Install all dependencies
sudo dnf install -y gcc make wget tar gzip xz bison binutils
```

### Build fails in container
```bash
# Check container logs
podman logs <container_id>

# Run with verbose output
podman run --rm -e DUMP_LOG_ON_ERROR=1 -v $(pwd)/output:/output:Z tmux-static-builder
```

### Binary doesn't run on target system
- Ensure you're using the correct architecture (amd64/arm64)
- Check if terminfo is available: `ls /usr/share/terminfo`

## License

This build script is part of the TMux OpenShift Tools project.
