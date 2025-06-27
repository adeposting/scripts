#!/bin/bash

# Tests for color.sh
# Comprehensive test coverage for the color utility

shelltest test_suite "color"

# Test: color command exists
shelltest test_case "color command exists"
shelltest assert_command_exists "color" "color command should be available"

# Test: color get valid colors
shelltest test_case "color get valid colors"
for color in red green blue yellow cyan magenta white black; do
    output=$(color get "$color" 2>/dev/null)
    shelltest assert_not_equal "" "$output" "color get $color should return non-empty output"
done

# Test: color get bright colors
shelltest test_case "color get bright colors"
for color in bright-red bright-green bright-blue bright-yellow bright-cyan bright-magenta bright-white bright-black; do
    output=$(color get "$color" 2>/dev/null)
    shelltest assert_not_equal "" "$output" "color get $color should return non-empty output"
done

# Test: color get reset/default
shelltest test_case "color get reset/default"
output=$(color get default 2>/dev/null)
shelltest assert_not_equal "" "$output" "color get default should return non-empty output"

# Test: color get invalid color
shelltest test_case "color get invalid color"
output=$(color get invalid_color 2>/dev/null)
shelltest assert_equal "" "$output" "color get invalid color should return empty string"

# Test: color set command
shelltest test_case "color set command"
output=$(color set red 2>&1)
shelltest assert_not_contains "$output" "Unknown color" "color set red should not error"

# Test: color set invalid color
shelltest test_case "color set invalid color"
output=$(color set invalid_color 2>&1)
shelltest assert_contains "$output" "Unknown color" "color set invalid color should error"

# Test: color list command
shelltest test_case "color list command"
output=$(color list 2>/dev/null)
shelltest assert_not_equal "" "$output" "color list should return non-empty output"
shelltest assert_contains "$output" "red" "color list should contain red"
shelltest assert_contains "$output" "green" "color list should contain green"
shelltest assert_contains "$output" "blue" "color list should contain blue"

# Test: color echo command
shelltest test_case "color echo command"
output=$(color echo red "test message" 2>/dev/null)
shelltest assert_contains "$output" "test message" "color echo should output the message"

# Test: color echo invalid color
shelltest test_case "color echo invalid color"
output=$(color echo invalid_color "test message" 2>&1)
shelltest assert_contains "$output" "Unknown color" "color echo invalid color should error"

# Test: color cat existing file
shelltest test_case "color cat existing file"
temp_file=$(mktemp)
echo "test content" > "$temp_file"
output=$(color cat red "$temp_file" 2>/dev/null)
shelltest assert_contains "$output" "test content" "color cat should output file content"
rm -f "$temp_file"

# Test: color cat non-existing file
shelltest test_case "color cat non-existing file"
output=$(color cat red "nonexisting_file.txt" 2>&1)
shelltest assert_contains "$output" "File not found" "color cat should error for non-existing file"

# Test: color help command
shelltest test_case "color help command"
output=$(color help 2>&1)
shelltest assert_contains "$output" "color.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "get" "help should mention get command"
shelltest assert_contains "$output" "set" "help should mention set command"
shelltest assert_contains "$output" "list" "help should mention list command"
shelltest assert_contains "$output" "echo" "help should mention echo command"
shelltest assert_contains "$output" "cat" "help should mention cat command"

# Test: color with --help flag
shelltest test_case "color --help flag"
output=$(color --help 2>&1)
shelltest assert_contains "$output" "color.sh" "--help should show script name"

# Test: color with -h flag
shelltest test_case "color -h flag"
output=$(color -h 2>&1)
shelltest assert_contains "$output" "color.sh" "-h should show script name"

# Test: color with invalid command
shelltest test_case "color invalid command"
output=$(color invalid_cmd 2>&1)
shelltest assert_contains "$output" "color.sh" "invalid command should show help"

# Test: color function directly
shelltest test_case "color function direct call"
output=$(color get red 2>/dev/null)
shelltest assert_not_equal "" "$output" "color function get should return non-empty output"

