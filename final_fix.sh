#!/bin/bash

# Final fix script - sets up build system and runs all tests

echo "=== Final Test Fix ==="

# 1. Set up build system
echo "1. Setting up build system..."
mkdir -p ./dist/bin
cp -r ./src/bin/* ./dist/bin/
chmod +x ./dist/bin/*.sh

# Create symlinks in dist/bin
for script in ./dist/bin/*.sh; do
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script" .sh)
        ln -sf "$(pwd)/$script" "./dist/bin/$script_name"
    fi
done

# 2. Set up environment
echo "2. Setting up environment..."
export PATH="./dist/bin:$PATH"

# 3. Test the build system
echo "3. Testing build system..."
if [[ -d "./dist/bin" ]]; then
    echo "✓ Build system ready"
    echo "Available commands:"
    ls -la ./dist/bin/ | grep -E '^-|^l'
else
    echo "✗ Build system failed"
    exit 1
fi

# 4. Test individual commands
echo "4. Testing individual commands..."

# Test ostype
echo "Testing ostype..."
if ./dist/bin/ostype.sh get >/dev/null 2>&1; then
    echo "✓ ostype get works"
else
    echo "✗ ostype get failed"
fi

# Test pathenv
echo "Testing pathenv..."
if ./dist/bin/pathenv.sh get >/dev/null 2>&1; then
    echo "✓ pathenv get works"
else
    echo "✗ pathenv get failed"
fi

# Test rsed
echo "Testing rsed..."
if ./dist/bin/rsed.sh --help >/dev/null 2>&1; then
    echo "✓ rsed help works"
else
    echo "✗ rsed help failed"
fi

# Test shlog
echo "Testing shlog..."
if ./dist/bin/shlog.sh help >/dev/null 2>&1; then
    echo "✓ shlog help works"
else
    echo "✗ shlog help failed"
fi

# Test unlinker
echo "Testing unlinker..."
if ./dist/bin/unlinker.sh --help >/dev/null 2>&1; then
    echo "✓ unlinker help works"
else
    echo "✗ unlinker help failed"
fi

# 5. Run test framework
echo "5. Running test framework..."
if [[ -f "./src/shelltest.sh" ]]; then
    echo "Test framework found, running ostype test..."
    export PATH="./dist/bin:$PATH"
    ./src/shelltest.sh run ./tests/bin/test_ostype.sh
else
    echo "Test framework not found"
fi

echo "=== Final Fix Complete ==="
echo "Build system is ready. Use './dist/bin' in PATH for testing."
echo "To run tests: export PATH='./dist/bin:\$PATH' && ./src/shelltest.sh run ./tests/bin/test_*.sh" 