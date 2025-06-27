# Docker Testing Setup

This directory contains Docker configurations for testing the scripts collection in different environments.

## Overview

The Docker setup provides two testing environments:
- **Ubuntu Linux**: Tests scripts in a Linux environment
- **macOS-like**: Tests scripts in an environment that mimics macOS as closely as possible

## Files

- `Dockerfile.archlinux`: Ubuntu Linux container with essential tools (legacy filename)
- `Dockerfile.darwin`: Ubuntu-based container configured to mimic macOS
- `run-tests.sh`: Test runner script executed inside containers
- `Makefile`: Docker-specific Makefile targets
- `.dockerignore`: Excludes unnecessary files from Docker builds

## Usage

### Running Tests

From the `dev/docker` directory, use the Makefile targets:

```bash
# Navigate to docker directory
cd dev/docker

# Run tests in Ubuntu Linux container
make test-linux

# Run tests in macOS-like container
make test-darwin

# Run tests in both environments
make test-all

# Build Docker images only
make build-linux
make build-darwin

# Clean up Docker artifacts
make clean
```

### Alternative Usage (from project root)

You can also run Docker tests from the project root by changing to the docker directory:

```bash
# From project root
cd dev/docker && make test-linux
cd dev/docker && make test-darwin
cd dev/docker && make test-all
```

### Test Output

Test results and logs are captured in:
- `../.docker/linux/test-output/` - Linux test results
- `../.docker/darwin/test-output/` - macOS-like test results

Each test run creates:
- `tests.stdout.log` - Standard output
- `tests.stderr.log` - Standard error

### Container Environment

Both containers:
- Use the `docker` user (non-root)
- Mount the entire project at `/home/docker/scripts`
- Set up PATH to include the scripts
- Install essential tools (git, shellcheck, gpg, etc.)

### macOS-like Environment

The macOS-like container sets these environment variables:
- `OSTYPE=darwin`
- `MACHTYPE=x86_64-apple-darwin`
- `HOSTTYPE=x86_64`
- `HOST=x86_64-apple-darwin`

This allows scripts to detect they're running in a macOS-like environment.

## Troubleshooting

### Build Issues
- Ensure Docker is running
- Check available disk space
- Verify network connectivity for package downloads

### Test Failures
- Check the log files in `../.docker/*/test-output/`
- Verify the scripts are executable
- Ensure all dependencies are available in the container

### Permission Issues
- The containers run as the `docker` user
- All files are mounted with appropriate permissions
- The test runner script handles executable permissions 