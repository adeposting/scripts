#!/bin/bash

# Tests for helloworld.sh
# Comprehensive test coverage for the helloworld utility

shelltest test_suite "helloworld"

# Test: helloworld command exists
shelltest test_case "helloworld command exists"
shelltest assert_command_exists "helloworld" "helloworld command should be available"

# Test: helloworld default behavior (no arguments)
shelltest test_case "helloworld default behavior"
output=$(helloworld 2>/dev/null)
shelltest assert_equal "hello world" "$output" "helloworld should output 'hello world' by default"

# Test: helloworld help command
shelltest test_case "helloworld help command"
output=$(helloworld help 2>&1)
shelltest assert_contains "$output" "helloworld.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "hello world" "help should mention default behavior"

# Test: helloworld with --help flag
shelltest test_case "helloworld --help flag"
output=$(helloworld --help 2>&1)
shelltest assert_contains "$output" "helloworld.sh" "--help should show script name"

# Test: helloworld with -h flag
shelltest test_case "helloworld -h flag"
output=$(helloworld -h 2>&1)
shelltest assert_contains "$output" "helloworld.sh" "-h should show script name"

# Test: helloworld with invalid command
shelltest test_case "helloworld invalid command"
output=$(helloworld invalid_cmd 2>&1)
shelltest assert_contains "$output" "helloworld.sh" "invalid command should show help"

# Test: helloworld function directly
shelltest test_case "helloworld function direct call"
# Command should be available on PATH

# Test default behavior
output=$(helloworld)
shelltest assert_equal "hello world" "$output" "helloworld function should output 'hello world' by default"

# Test help behavior
output=$(helloworld help)
shelltest assert_contains "$output" "helloworld.sh" "helloworld function help should work"

# Test: helloworld with empty string argument
shelltest test_case "helloworld empty string argument"
output=$(helloworld "" 2>/dev/null)
shelltest assert_equal "hello world" "$output" "helloworld should output 'hello world' with empty string"

# Test: helloworld with whitespace argument
shelltest test_case "helloworld whitespace argument"
output=$(helloworld "   " 2>&1)
shelltest assert_contains "$output" "helloworld.sh" "helloworld should show help with whitespace argument"

# Test: helloworld help text content
shelltest test_case "helloworld help text content"
output=$(helloworld help 2>&1)
shelltest assert_contains "$output" "Commands:" "help should show commands section"
shelltest assert_contains "$output" "help|--help|-h" "help should mention help options"
shelltest assert_contains "$output" "prints this help text" "help should describe default behavior"

