#!/bin/bash

echo "Testing the build system..."

# Test 1: Check if we can create directories
echo "Test 1: Creating dist directory..."
mkdir -p ./dist/bin
if [[ -d "./dist/bin" ]]; then
    echo "✓ dist/bin directory created"
else
    echo "✗ Failed to create dist/bin directory"
    exit 1
fi

# Test 2: Copy scripts
echo "Test 2: Copying scripts..."
cp -r ./src/bin/* ./dist/bin/
if [[ -f "./dist/bin/ostype.sh" ]]; then
    echo "✓ Scripts copied successfully"
else
    echo "✗ Failed to copy scripts"
    exit 1
fi

# Test 3: Make executable
echo "Test 3: Making scripts executable..."
chmod +x ./dist/bin/*.sh
if [[ -x "./dist/bin/ostype.sh" ]]; then
    echo "✓ Scripts made executable"
else
    echo "✗ Failed to make scripts executable"
    exit 1
fi

# Test 4: Test ostype command
echo "Test 4: Testing ostype command..."
export PATH="./dist/bin:$PATH"
if ./dist/bin/ostype.sh get >/dev/null 2>&1; then
    echo "✓ ostype command works"
else
    echo "✗ ostype command failed"
fi

echo "All tests completed successfully!" 