#!/bin/bash

# Test helper script - sources test functions from shelltest.sh
# This allows test files to use test functions without sourcing shelltest.sh directly

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the test functions from shelltest.sh
source "$SCRIPT_DIR/shelltest.sh"

# Export all test functions so they're available in test files
export -f test_init test_suite test_case test_pass test_fail test_skip
export -f assert_success assert_failure assert_equal assert_not_equal
export -f assert_contains assert_not_contains assert_file_exists assert_file_not_exists
export -f assert_dir_exists assert_dir_not_exists assert_command_exists assert_command_not_exists
export -f assert_stderr_contains assert_stderr_equals
export -f capture_output capture_stdout capture_stderr
export -f create_temp_file create_temp_dir cleanup_temp 