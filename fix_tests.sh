#!/bin/bash

# Script to fix all tests and ensure they work with the build system

echo "Fixing all tests..."

# First, let's create the dist directory manually
echo "Creating dist directory..."
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

# Set PATH to use dist/bin first
export PATH="./dist/bin:$PATH"

echo "Testing ostype command..."
./dist/bin/ostype.sh is 2>&1

echo "Testing pathenv command..."
./dist/bin/pathenv.sh invalid_cmd 2>&1

echo "Testing rsed command..."
./dist/bin/rsed.sh --help 2>&1

echo "Testing shlog command..."
./dist/bin/shlog.sh set-level 2>&1

echo "Testing unlinker command..."
./dist/bin/unlinker.sh 2>&1

echo "All tests completed" 