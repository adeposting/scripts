#!/bin/bash

# Test script for color using shelltest framework
# This script should be run with: shelltest run ./tests/bin/test_color.sh

# Start test suite
shelltest test_suite "color"

# Test 1: color command exists
shelltest test_case "color command exists"
if command -v color >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color command should be available"
fi

# Test 2: color help command
shelltest test_case "color help command"
if color help >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color help should work"
fi

# Test 3: color --help flag
shelltest test_case "color --help flag"
if color --help >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color --help should work"
fi

# Test 4: color -h flag
shelltest test_case "color -h flag"
if color -h >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color -h should work"
fi

# Test 5: color with no arguments
shelltest test_case "color with no arguments"
if color >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color with no arguments should work"
fi

# Test 6: color set command
shelltest test_case "color set command"
if color set red >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color set should work"
fi

# Test 7: color reset command
shelltest test_case "color reset command"
if color reset >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color reset should work"
fi

# Test 8: color list command
shelltest test_case "color list command"
if color list >/dev/null 2>&1; then
    shelltest test_pass
else
    shelltest test_fail "color list should work"
fi

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

# Test: color set invalid color
shelltest test_case "color set invalid color"
output=$(color set invalid_color 2>&1)
shelltest assert_contains "$output" "Unknown color" "color set invalid color should error"

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

# Test: color with invalid command
shelltest test_case "color invalid command"
output=$(color invalid_cmd 2>&1)
shelltest assert_contains "$output" "color.sh" "invalid command should show help"

# Test: color function directly
shelltest test_case "color function direct call"
output=$(color get red 2>/dev/null)
shelltest assert_not_equal "" "$output" "color function get should return non-empty output"

