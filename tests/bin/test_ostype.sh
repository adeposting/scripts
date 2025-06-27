#!/bin/bash

# Tests for ostype.sh
# Comprehensive test coverage for the ostype utility

shelltest test_suite "ostype"

# Test: ostype command exists
shelltest test_case "ostype command exists"
shelltest assert_command_exists "ostype" "ostype command should be available"

# Test: ostype get command
shelltest test_case "ostype get command"
output=$(ostype get 2>/dev/null)
shelltest assert_not_equal "" "$output" "ostype get should return non-empty OS name"
shelltest assert_not_contains "$output" "error" "ostype get should not contain error messages"

# Test: ostype is command with current OS
shelltest test_case "ostype is command with current OS"
current_os=$(ostype get 2>/dev/null)
if [[ -n "$current_os" ]]; then
    output=$(ostype is "$current_os" 2>/dev/null)
    shelltest assert_equal "0" "$?" "ostype is should return success for current OS"
else
    shelltest test_skip "Could not determine current OS for testing"
fi

# Test: ostype is command with invalid OS
shelltest test_case "ostype is command with invalid OS"
output=$(ostype is "InvalidOSName" 2>/dev/null)
shelltest assert_equal "1" "$?" "ostype is should return failure for invalid OS"

# Test: ostype is command with empty argument
shelltest test_case "ostype is command with empty argument"
output=$(ostype is "" 2>&1)
shelltest assert_contains "$output" "OS name required" "ostype is should error with empty argument"

# Test: ostype is command with no argument
shelltest test_case "ostype is command with no argument"
output=$(ostype is 2>&1)
shelltest assert_contains "$output" "OS name required" "ostype is should error with no argument"

# Test: ostype help command
shelltest test_case "ostype help command"
output=$(ostype help 2>&1)
shelltest assert_contains "$output" "ostype.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "get" "help should mention get command"
shelltest assert_contains "$output" "is" "help should mention is command"

# Test: ostype with --help flag
shelltest test_case "ostype --help flag"
output=$(ostype --help 2>&1)
shelltest assert_contains "$output" "ostype.sh" "--help should show script name"

# Test: ostype with -h flag
shelltest test_case "ostype -h flag"
output=$(ostype -h 2>&1)
shelltest assert_contains "$output" "ostype.sh" "-h should show script name"

# Test: ostype with invalid command
shelltest test_case "ostype invalid command"
output=$(ostype invalid_cmd 2>&1)
shelltest assert_contains "$output" "ostype.sh" "invalid command should show help"

# Test: ostype function directly
shelltest test_case "ostype function direct call"
source "../../src/bin/ostype.sh"

# Test get_ostype function
output=$(get_ostype)
shelltest assert_not_equal "" "$output" "get_ostype function should return non-empty OS name"

# Test is_ostype function with current OS
current_os=$(get_ostype)
if [[ -n "$current_os" ]]; then
    is_ostype "$current_os"
    shelltest assert_equal "0" "$?" "is_ostype function should return success for current OS"
else
    shelltest test_skip "Could not determine current OS for function testing"
fi

# Test is_ostype function with invalid OS
is_ostype "InvalidOSName"
shelltest assert_equal "1" "$?" "is_ostype function should return failure for invalid OS"

# Test: ostype case insensitive matching
shelltest test_case "ostype case insensitive matching"
current_os=$(ostype get 2>/dev/null)
if [[ -n "$current_os" ]]; then
    # Test with lowercase
    lower_os=$(echo "$current_os" | tr '[:upper:]' '[:lower:]')
    output=$(ostype is "$lower_os" 2>/dev/null)
    shelltest assert_equal "0" "$?" "ostype is should work with lowercase OS name"
    
    # Test with uppercase
    upper_os=$(echo "$current_os" | tr '[:lower:]' '[:upper:]')
    output=$(ostype is "$upper_os" 2>/dev/null)
    shelltest assert_equal "0" "$?" "ostype is should work with uppercase OS name"
else
    shelltest test_skip "Could not determine current OS for case testing"
fi

# Test: ostype help text content
shelltest test_case "ostype help text content"
output=$(ostype help 2>&1)
shelltest assert_contains "$output" "Commands:" "help should show commands section"
shelltest assert_contains "$output" "get" "help should mention get command"
shelltest assert_contains "$output" "is" "help should mention is command"
shelltest assert_contains "$output" "help, --help, -h" "help should mention help options"

