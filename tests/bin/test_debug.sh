#!/bin/bash

# Tests for debug.sh
# Comprehensive test coverage for the debug utility

shelltest test_suite "debug"

# Test: debug command exists
shelltest test_case "debug command exists"
shelltest assert_command_exists "debug" "debug command should be available"

# Test: debug enable command
shelltest test_case "debug enable command"
unset DEBUG
output=$(debug enable 2>/dev/null)
shelltest assert_contains "$output" "Debug mode enabled" "debug enable should output success message"
unset DEBUG

# Test: debug disable command
shelltest test_case "debug disable command"
export DEBUG=1
output=$(debug disable 2>/dev/null)
shelltest assert_contains "$output" "Debug mode disabled" "debug disable should output success message"
unset DEBUG

# Test: debug is_enabled when enabled
shelltest test_case "debug is_enabled when enabled"
# Enable debug mode first
debug enable >/dev/null 2>&1
output=$(debug is_enabled 2>/dev/null)
shelltest assert_contains "$output" "enabled" "debug is_enabled should return enabled when DEBUG is set"

# Test: debug is_enabled when disabled
shelltest test_case "debug is_enabled when disabled"
unset DEBUG
output=$(debug is_enabled 2>/dev/null)
shelltest assert_contains "$output" "disabled" "debug is_enabled should return disabled when DEBUG is not set"

# Test: debug help command
shelltest test_case "debug help command"
output=$(debug help 2>&1)
shelltest assert_contains "$output" "debug.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "enable" "help should mention enable command"
shelltest assert_contains "$output" "disable" "help should mention disable command"
shelltest assert_contains "$output" "is_enabled" "help should mention is_enabled command"

# Test: debug with --help flag
shelltest test_case "debug --help flag"
output=$(debug --help 2>&1)
shelltest assert_contains "$output" "debug.sh" "--help should show script name"

# Test: debug with -h flag
shelltest test_case "debug -h flag"
output=$(debug -h 2>&1)
shelltest assert_contains "$output" "debug.sh" "-h should show script name"

# Test: debug with invalid command
shelltest test_case "debug invalid command"
output=$(debug invalid_cmd 2>&1)
shelltest assert_contains "$output" "debug.sh" "invalid command should show help"

# Test: debug function directly
shelltest test_case "debug function direct call"
source "../../src/bin/debug.sh"

# Test enable
unset DEBUG
output=$(debug enable 2>/dev/null)
shelltest assert_contains "$output" "Debug mode enabled" "debug function enable should work"

# Test disable
output=$(debug disable 2>/dev/null)
shelltest assert_contains "$output" "Debug mode disabled" "debug function disable should work"

# Test debug_enable function
shelltest test_case "debug_enable function"
unset DEBUG
output=$(debug_enable)
shelltest assert_contains "$output" "Debug mode enabled" "debug_enable should output success message"

# Test debug_disable function
shelltest test_case "debug_disable function"
export DEBUG=1
output=$(debug_disable)
shelltest assert_contains "$output" "Debug mode disabled" "debug_disable should output success message"

# Test debug_is_enabled function when enabled
shelltest test_case "debug_is_enabled function when enabled"
export DEBUG=1
output=$(debug_is_enabled)
shelltest assert_contains "$output" "enabled" "debug_is_enabled should return enabled when DEBUG is set"

# Test debug_is_enabled function when disabled
shelltest test_case "debug_is_enabled function when disabled"
unset DEBUG
output=$(debug_is_enabled)
shelltest assert_contains "$output" "disabled" "debug_is_enabled should return disabled when DEBUG is not set"

