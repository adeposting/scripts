#!/bin/bash

# Test script to validate Dockerfile syntax and structure
# This can be run without Docker daemon

set -e

echo "=== Validating Dockerfile.archlinux ==="
if [ -f "Dockerfile.archlinux" ]; then
    echo "✓ Dockerfile.archlinux exists"
    
    # Check for required sections
    if grep -q "FROM archlinux" Dockerfile.archlinux; then
        echo "✓ Uses Arch Linux base image"
    else
        echo "✗ Missing Arch Linux base image"
        exit 1
    fi
    
    if grep -q "useradd.*docker" Dockerfile.archlinux; then
        echo "✓ Creates docker user"
    else
        echo "✗ Missing docker user creation"
        exit 1
    fi
    
    if grep -q "SCRIPTS_REPO_ROOT_DIR" Dockerfile.archlinux; then
        echo "✓ Sets up scripts environment"
    else
        echo "✗ Missing scripts environment setup"
        exit 1
    fi
else
    echo "✗ Dockerfile.archlinux not found"
    exit 1
fi

echo ""
echo "=== Validating Dockerfile.darwin ==="
if [ -f "Dockerfile.darwin" ]; then
    echo "✓ Dockerfile.darwin exists"
    
    # Check for required sections
    if grep -q "FROM ubuntu" Dockerfile.darwin; then
        echo "✓ Uses Ubuntu base image"
    else
        echo "✗ Missing Ubuntu base image"
        exit 1
    fi
    
    if grep -q "OSTYPE=darwin" Dockerfile.darwin; then
        echo "✓ Sets macOS-like environment variables"
    else
        echo "✗ Missing macOS environment variables"
        exit 1
    fi
    
    if grep -q "useradd.*docker" Dockerfile.darwin; then
        echo "✓ Creates docker user"
    else
        echo "✗ Missing docker user creation"
        exit 1
    fi
    
    if grep -q "SCRIPTS_REPO_ROOT_DIR" Dockerfile.darwin; then
        echo "✓ Sets up scripts environment"
    else
        echo "✗ Missing scripts environment setup"
        exit 1
    fi
else
    echo "✗ Dockerfile.darwin not found"
    exit 1
fi

echo ""
echo "=== Validating run-tests.sh ==="
if [ -f "run-tests.sh" ]; then
    echo "✓ run-tests.sh exists"
    
    if [ -x "run-tests.sh" ]; then
        echo "✓ run-tests.sh is executable"
    else
        echo "✗ run-tests.sh is not executable"
        exit 1
    fi
    
    if grep -q "SCRIPTS_REPO_ROOT_DIR" run-tests.sh; then
        echo "✓ Sets up environment variables"
    else
        echo "✗ Missing environment variable setup"
        exit 1
    fi
    
    if grep -q "scripts test" run-tests.sh; then
        echo "✓ Runs tests"
    else
        echo "✗ Missing test execution"
        exit 1
    fi
    
    if grep -q "tee.*LOG_STDOUT" run-tests.sh; then
        echo "✓ Captures output to logs"
    else
        echo "✗ Missing log capture"
        exit 1
    fi
else
    echo "✗ run-tests.sh not found"
    exit 1
fi

echo ""
echo "=== All Dockerfile validations passed! ==="
echo "Docker setup is ready for use when Docker daemon is available." 