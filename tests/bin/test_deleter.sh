#!/bin/bash

# Tests for deleter.sh
# TODO: Add more comprehensive tests

shelltest test_suite "deleter"

# Test: deleter command exists
shelltest test_case "deleter command exists"
shelltest assert_command_exists "deleter" "deleter command should be available"

# Test: deleter help command
shelltest test_case "deleter help command"
output=$(deleter help 2>&1)
shelltest assert_contains "$output" "deleter.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"

# Test: deleter with --help flag
shelltest test_case "deleter --help flag"
output=$(deleter --help 2>&1)
shelltest assert_contains "$output" "deleter.sh" "--help should show script name"

# Test: deleter with -h flag
shelltest test_case "deleter -h flag"
output=$(deleter -h 2>&1)
shelltest assert_contains "$output" "deleter.sh" "-h should show script name"

# Test: deleter with invalid command
shelltest test_case "deleter invalid command"
output=$(deleter invalid_cmd 2>&1)
shelltest assert_contains "$output" "deleter.sh" "invalid command should show help"

