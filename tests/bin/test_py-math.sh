#!/bin/bash

# Tests for py-math.py
# Comprehensive test coverage for the py-math utility

shelltest test_suite "py-math"

# Test: py-math command exists
shelltest test_case "py-math command exists"
shelltest assert_command_exists "py-math" "py-math command should be available"

# Test: py-math help command
shelltest test_case "py-math help command"
output=$(py-math --help 2>&1)
shelltest assert_contains "$output" "py-math" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"

# Test: sqrt command
shelltest test_case "sqrt command"
result=$(py-math sqrt 16)
shelltest assert_equal "4.0" "$result" "sqrt command should return 4.0"

# Test: ceil command
shelltest test_case "ceil command"
result=$(py-math ceil 3.7)
shelltest assert_equal "4" "$result" "ceil command should return 4"

# Test: floor command
shelltest test_case "floor command"
result=$(py-math floor 3.7)
shelltest assert_equal "3" "$result" "floor command should return 3"

# Test: log command
shelltest test_case "log command"
result=$(py-math log 100)
shelltest assert_contains "$result" "." "log command should return a float"

# Test: log command with base
shelltest test_case "log command with base"
result=$(py-math log 100 --base 10)
shelltest assert_equal "2.0" "$result" "log command with base should return 2.0"

# Test: exp command
shelltest test_case "exp command"
result=$(py-math exp 1)
shelltest assert_contains "$result" "." "exp command should return a float"

# Test: factorial command
shelltest test_case "factorial command"
result=$(py-math factorial 5)
shelltest assert_equal "120" "$result" "factorial command should return 120"

# Test: gcd command
shelltest test_case "gcd command"
result=$(py-math gcd 12 18 24)
shelltest assert_equal "6" "$result" "gcd command should return 6"

# Test: lcm command
shelltest test_case "lcm command"
result=$(py-math lcm 12 18)
shelltest assert_equal "36" "$result" "lcm command should return 36"

# Test: sin command
shelltest test_case "sin command"
result=$(py-math sin 0)
shelltest assert_equal "0.0" "$result" "sin command should return 0.0"

# Test: cos command
shelltest test_case "cos command"
result=$(py-math cos 0)
shelltest assert_equal "1.0" "$result" "cos command should return 1.0"

# Test: tan command
shelltest test_case "tan command"
result=$(py-math tan 0)
shelltest assert_equal "0.0" "$result" "tan command should return 0.0"

# Test: pow command
shelltest test_case "pow command"
result=$(py-math pow 2 10)
shelltest assert_equal "1024" "$result" "pow command should return 1024"

# Test: fabs command
shelltest test_case "fabs command"
result=$(py-math fabs -3.7)
shelltest assert_equal "3.7" "$result" "fabs command should return 3.7"

# Test: pi constant
shelltest test_case "pi constant"
result=$(py-math pi)
shelltest assert_contains "$result" "3.14" "pi constant should contain 3.14"

# Test: e constant
shelltest test_case "e constant"
result=$(py-math e)
shelltest assert_contains "$result" "2.71" "e constant should contain 2.71"

# Test: degrees command
shelltest test_case "degrees command"
result=$(py-math degrees 3.141592653589793)
shelltest assert_contains "$result" "180" "degrees command should return approximately 180"

# Test: radians command
shelltest test_case "radians command"
result=$(py-math radians 180)
shelltest assert_contains "$result" "3.14" "radians command should return approximately 3.14"

# Test: Error handling for invalid input
shelltest test_case "error handling for invalid input"
output=$(py-math sqrt "invalid" 2>&1)
shelltest assert_contains "$output" "Error" "should show error for invalid input"

# Test: Error handling for factorial with negative number
shelltest test_case "error handling for factorial with negative number"
output=$(py-math factorial -1 2>&1)
shelltest assert_contains "$output" "Error" "should show error for negative factorial" 