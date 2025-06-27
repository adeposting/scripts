#!/bin/bash

# Test runner script for Docker containers
# This script runs all tests and captures stdout/stderr

set -e

# Set up environment - ensure ./dist/bin is first in PATH
export PATH="/home/docker/scripts/dist/bin:/home/docker/scripts/local/bin:/home/docker/scripts/src/bin:$PATH"
export SCRIPTS_REPO_ROOT_DIR="/home/docker/scripts"

# Change to scripts directory
cd /home/docker/scripts

# Create local installation directory
mkdir -p ./local/bin

# Build first to ensure we have dist/bin
echo "=== Building scripts distribution ==="
if scripts.sh build; then
    echo "Build completed successfully"
else
    echo "Build failed"
    exit 1
fi

# Install scripts to local/bin (create symlinks without .sh extension)
echo "=== Installing scripts to local/bin ==="
for script in ./src/bin/*.sh; do
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script" .sh)
        ln -sf "$(pwd)/$script" "./local/bin/$script_name"
        echo "Created symlink: $script_name -> $script"
    fi
done

# Create log files
LOG_STDOUT="/home/docker/scripts/tests.stdout.log"
LOG_STDERR="/home/docker/scripts/tests.stderr.log"

# Clear previous logs
> "$LOG_STDOUT"
> "$LOG_STDERR"

echo "=== Starting tests in $(uname -s) environment ===" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Environment: OSTYPE=$OSTYPE, MACHTYPE=$MACHTYPE" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Scripts directory: $SCRIPTS_REPO_ROOT_DIR" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "PATH: $PATH" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "" | tee -a "$LOG_STDOUT" "$LOG_STDERR"

# Make scripts executable
chmod +x src/bin/*.sh tests/bin/*.sh 2>&1 | tee -a "$LOG_STDOUT" "$LOG_STDERR"

# Run bootstrap
echo "=== Running bootstrap ===" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
if scripts.sh bootstrap 2>&1 | tee -a "$LOG_STDOUT" "$LOG_STDERR"; then
    echo "Bootstrap completed successfully" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
else
    echo "Bootstrap failed" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    exit 1
fi

echo "" | tee -a "$LOG_STDOUT" "$LOG_STDERR"

# Run init
echo "=== Running init ===" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
if scripts.sh init 2>&1 | tee -a "$LOG_STDOUT" "$LOG_STDERR"; then
    echo "Init completed successfully" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
else
    echo "Init failed" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    exit 1
fi

echo "" | tee -a "$LOG_STDOUT" "$LOG_STDERR"

# Run all tests
echo "=== Running all tests ===" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Running tests using shelltest CLI..." | tee -a "$LOG_STDOUT" "$LOG_STDERR"

# Find all test files and run them with shelltest
test_files=$(find ./tests/bin -name "test_*.sh" -type f | sort)
test_count=0
passed_count=0
failed_count=0

for test_file in $test_files; do
    test_count=$((test_count + 1))
    echo "Running test $test_count: $test_file" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    
    if shelltest run "$test_file" 2>&1 | tee -a "$LOG_STDOUT" "$LOG_STDERR"; then
        passed_count=$((passed_count + 1))
        echo "✓ Test passed: $test_file" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    else
        failed_count=$((failed_count + 1))
        echo "✗ Test failed: $test_file" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    fi
    
    echo "" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
done

echo "=== Test Summary ===" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Total tests: $test_count" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Passed: $passed_count" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
echo "Failed: $failed_count" | tee -a "$LOG_STDOUT" "$LOG_STDERR"

if [[ $failed_count -eq 0 ]]; then
    echo "All tests completed successfully" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    exit 0
else
    echo "Some tests failed" | tee -a "$LOG_STDOUT" "$LOG_STDERR"
    exit 1
fi 