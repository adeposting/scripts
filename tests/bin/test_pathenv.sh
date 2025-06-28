#!/bin/bash

# Tests for pathenv.sh
# Comprehensive test coverage for the pathenv utility

shelltest test_suite "pathenv"

# Test: pathenv command exists
shelltest test_case "pathenv command exists"
shelltest assert_command_exists "pathenv" "pathenv command should be available"

# Test: pathenv get command
shelltest test_case "pathenv get command"
output=$(pathenv get 2>/dev/null)
shelltest assert_not_equal "" "$output" "pathenv get should return non-empty PATH"
shelltest assert_contains "$output" ":" "pathenv get should contain PATH separator"

# Test: pathenv list command
shelltest test_case "pathenv list command"
output=$(pathenv list 2>/dev/null)
shelltest assert_not_equal "" "$output" "pathenv list should return non-empty output"
# Each line should be a directory path
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        shelltest assert_not_contains "$line" ":" "pathenv list should not contain colons in individual entries"
    fi
done <<< "$output"

# Test: pathenv contains command with existing directory
shelltest test_case "pathenv contains command with existing directory"
# Get first directory from PATH
first_dir=$(pathenv list | head -n1)
if [[ -n "$first_dir" ]]; then
    output=$(pathenv contains "$first_dir" 2>/dev/null)
    shelltest assert_equal "0" "$?" "pathenv contains should return success for existing directory"
else
    shelltest test_skip "No directories in PATH for testing"
fi

# Test: pathenv contains command with non-existing directory
shelltest test_case "pathenv contains command with non-existing directory"
output=$(pathenv contains "/nonexistent/directory" 2>/dev/null)
shelltest assert_equal "1" "$?" "pathenv contains should return failure for non-existing directory"

# Test: pathenv contains command with empty argument
shelltest test_case "pathenv contains command with empty argument"
output=$(pathenv contains "" 2>&1)
shelltest assert_contains "$output" "No directory provided" "pathenv contains should error with empty argument"

# Test: pathenv contains command with no argument
shelltest test_case "pathenv contains command with no argument"
output=$(pathenv contains 2>&1)
shelltest assert_contains "$output" "No directory provided" "pathenv contains should error with no argument"

# Test: pathenv help command
shelltest test_case "pathenv help command"
output=$(pathenv help 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "get" "help should mention get command"
shelltest assert_contains "$output" "list" "help should mention list command"
shelltest assert_contains "$output" "contains" "help should mention contains command"

# Test: pathenv with --help flag
shelltest test_case "pathenv --help flag"
output=$(pathenv --help 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "--help should show script name"

# Test: pathenv with -h flag
shelltest test_case "pathenv -h flag"
output=$(pathenv -h 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "-h should show script name"

# Test: pathenv with no arguments
shelltest test_case "pathenv with no arguments"
output=$(pathenv 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "pathenv should show help with no arguments"

# Test: pathenv with invalid command
shelltest test_case "pathenv invalid command"
output=$(pathenv invalid_cmd 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "invalid command should show help"

# Test: pathenv function directly
shelltest test_case "pathenv function direct call"
# Command should be available on PATH

# Test get_path_env function
output=$(get_path_env)
shelltest assert_not_equal "" "$output" "get_path_env function should return non-empty PATH"

# Test list_path_env function
output=$(list_path_env)
shelltest assert_not_equal "" "$output" "list_path_env function should return non-empty output"

# Test is_on_path_env function with existing directory
first_dir=$(list_path_env | head -n1)
if [[ -n "$first_dir" ]]; then
    is_on_path_env "$first_dir"
    shelltest assert_equal "0" "$?" "is_on_path_env function should return success for existing directory"
else
    shelltest test_skip "No directories in PATH for function testing"
fi

# Test is_on_path_env function with non-existing directory
is_on_path_env "/nonexistent/directory"
shelltest assert_equal "1" "$?" "is_on_path_env function should return failure for non-existing directory"

# Test: pathenv PATH consistency
shelltest test_case "pathenv PATH consistency"
get_output=$(pathenv get 2>/dev/null)
list_output=$(pathenv list 2>/dev/null | tr '\n' ':')
# Remove trailing colon from list output
list_output="${list_output%:}"
shelltest assert_equal "$get_output" "$list_output" "pathenv get and list should be consistent"

# Test: pathenv contains with exact match
shelltest test_case "pathenv contains with exact match"
first_dir=$(pathenv list | head -n1)
if [[ -n "$first_dir" ]]; then
    output=$(pathenv contains "$first_dir" 2>/dev/null)
    shelltest assert_equal "0" "$?" "pathenv contains should match exact directory"
else
    shelltest test_skip "No directories in PATH for exact match testing"
fi

# Test: pathenv contains with partial match (should fail)
shelltest test_case "pathenv contains with partial match"
first_dir=$(pathenv list | head -n1)
if [[ -n "$first_dir" ]]; then
    # Remove last character to create partial match
    partial_dir="${first_dir%?}"
    if [[ "$partial_dir" != "$first_dir" ]]; then
        output=$(pathenv contains "$partial_dir" 2>/dev/null)
        shelltest assert_equal "1" "$?" "pathenv contains should not match partial directory"
    else
        shelltest test_skip "Could not create partial match for testing"
    fi
else
    shelltest test_skip "No directories in PATH for partial match testing"
fi

# Test: pathenv help text content
shelltest test_case "pathenv help text content"
output=$(pathenv help 2>&1)
shelltest assert_contains "$output" "Commands:" "help should show commands section"
shelltest assert_contains "$output" "get" "help should mention get command"
shelltest assert_contains "$output" "list" "help should mention list command"
shelltest assert_contains "$output" "contains" "help should mention contains command"
shelltest assert_contains "$output" "help, --help, -h" "help should mention help options"

# Test: pathenv with empty argument
shelltest test_case "pathenv with empty argument"
output=$(pathenv "" 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "pathenv should show help with empty argument"

# Test: pathenv with whitespace argument
shelltest test_case "pathenv with whitespace argument"
output=$(pathenv "   " 2>&1)
shelltest assert_contains "$output" "pathenv.sh" "pathenv should show help with whitespace argument"

