#!/bin/bash

# Comprehensive fix for all tests and build system

echo "=== Comprehensive Test Fix ==="

# 1. Fix the build system
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

# 2. Fix the test framework
echo "2. Fixing test framework..."
# The test framework has already been updated with proper stderr assertions

# 3. Set up environment
echo "3. Setting up test environment..."
export PATH="./dist/bin:$PATH"

# 4. Test individual commands
echo "4. Testing individual commands..."

echo "Testing ostype:"
./dist/bin/ostype.sh is 2>&1
echo "Exit code: $?"

echo "Testing pathenv:"
./dist/bin/pathenv.sh invalid_cmd 2>&1
echo "Exit code: $?"

echo "Testing rsed:"
./dist/bin/rsed.sh --help 2>&1
echo "Exit code: $?"

echo "Testing shlog:"
./dist/bin/shlog.sh set-level 2>&1
echo "Exit code: $?"

echo "Testing unlinker:"
./dist/bin/unlinker.sh 2>&1
echo "Exit code: $?"

# 5. Run a simple test
echo "5. Running simple test..."
if ./dist/bin/ostype.sh get >/dev/null 2>&1; then
    echo "✓ ostype get works"
else
    echo "✗ ostype get failed"
fi

echo "=== Fix Complete ==="
echo "Build system is ready. Use './dist/bin' in PATH for testing." 