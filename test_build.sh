#!/bin/bash

# Simple test script to verify build system
echo "Testing build system..."

# Make scripts executable
chmod +x src/bin/*.sh

# Test build command
echo "Running build command..."
./src/bin/scripts.sh build

# Check if dist directory was created
if [[ -d "./dist" ]]; then
    echo "✓ Build successful - dist directory created"
    ls -la ./dist/
else
    echo "✗ Build failed - dist directory not created"
    exit 1
fi

echo "Build test completed" 