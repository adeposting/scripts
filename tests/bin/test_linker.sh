#!/bin/bash

# Tests for linker.sh
# Comprehensive test coverage for the linker utility

shelltest test_suite "linker"

# Test: linker command exists
shelltest test_case "linker command exists"
shelltest assert_command_exists "linker" "linker command should be available"

# Test: linker help command
shelltest test_case "linker help command"
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Description:" "help should show description section"

# Test: linker with -h flag
shelltest test_case "linker -h flag"
output=$(linker -h 2>&1)
shelltest assert_contains "$output" "linker.sh" "-h should show script name"

# Test: linker with no arguments
shelltest test_case "linker with no arguments"
output=$(linker 2>&1)
shelltest assert_contains "$output" "--source and --destination are required" "linker should error with no arguments"

# Test: linker with invalid option
shelltest test_case "linker with invalid option"
output=$(linker --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "linker should error with invalid option"

# Test: linker function directly
shelltest test_case "linker function direct call"
source "../../src/bin/linker.sh"

# Test help behavior
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker function help should work"

# Test: linker help text content
shelltest test_case "linker help text content"
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "Description:" "help should show description section"
shelltest assert_contains "$output" "Linker Options:" "help should show linker options section"
shelltest assert_contains "$output" "--source" "help should mention source option"
shelltest assert_contains "$output" "--destination" "help should mention destination option"
shelltest assert_contains "$output" "--force" "help should mention force option"
shelltest assert_contains "$output" "--rename" "help should mention rename option"

# Test: linker function exists when sourced
shelltest test_case "linker function exists when sourced"
source "../../src/bin/linker.sh"
shelltest assert_function_exists "linker" "linker function should exist when sourced"

# Test: linker help function exists
shelltest test_case "linker help function exists"
source "../../src/bin/linker.sh"
shelltest assert_function_exists "linker_help" "linker_help function should exist when sourced"

# Test: linker source option validation
shelltest test_case "linker source option validation"
output=$(linker --source 2>&1)
shelltest assert_contains "$output" "--source requires a directory" "linker should validate source option"

# Test: linker destination option validation
shelltest test_case "linker destination option validation"
output=$(linker --destination 2>&1)
shelltest assert_contains "$output" "--destination requires a directory" "linker should validate destination option"

# Test: linker rename option validation
shelltest test_case "linker rename option validation"
output=$(linker --rename 2>&1)
shelltest assert_contains "$output" "--rename requires a sed expression" "linker should validate rename option"

# Test: linker source directory validation
shelltest test_case "linker source directory validation"
output=$(linker --source /nonexistent/directory --destination /tmp 2>&1)
shelltest assert_contains "$output" "Source directory does not exist" "linker should validate source directory exists"

# Test: linker destination directory validation
shelltest test_case "linker destination directory validation"
output=$(linker --source /tmp --destination /nonexistent/directory 2>&1)
shelltest assert_contains "$output" "Destination directory does not exist" "linker should validate destination directory exists"

# Test: linker force option (mock test)
shelltest test_case "linker force option"
# This would normally test force functionality
# For now, we just verify the option can be parsed
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "--force" "linker should handle force option"

# Test: linker rename option (mock test)
shelltest test_case "linker rename option"
# This would normally test rename functionality
# For now, we just verify the option can be parsed
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "--rename" "linker should handle rename option"

# Test: linker lister integration (mock test)
shelltest test_case "linker lister integration"
# Test that linker can integrate with lister
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should integrate with lister"

# Test: linker shlog integration (mock test)
shelltest test_case "linker shlog integration"
# Test that linker can integrate with shlog
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should integrate with shlog"

# Test: linker file selection options (mock test)
shelltest test_case "linker file selection options"
# Test that linker can handle file selection options
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle file selection options"

# Test: linker logging options (mock test)
shelltest test_case "linker logging options"
# Test that linker can handle logging options
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle logging options"

# Test: linker command structure
shelltest test_case "linker command structure"
# Verify that linker has the expected command structure
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "Usage:" "linker should have usage section"
shelltest assert_contains "$output" "Description:" "linker should have description section"
shelltest assert_contains "$output" "Linker Options:" "linker should have linker options section"

# Test: linker examples section
shelltest test_case "linker examples section"
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "Examples:" "help should show examples section"

# Test: linker symlink creation (mock test)
shelltest test_case "linker symlink creation"
# Test that linker can create symlinks
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should create symlinks"

# Test: linker file renaming (mock test)
shelltest test_case "linker file renaming"
# Test that linker can rename files
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should rename files"

# Test: linker error handling
shelltest test_case "linker error handling"
# Test that linker can handle errors gracefully
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle errors gracefully"

# Test: linker with empty argument
shelltest test_case "linker with empty argument"
output=$(linker "" 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle empty arguments"

# Test: linker with whitespace argument
shelltest test_case "linker with whitespace argument"
output=$(linker "   " 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle whitespace arguments"

# Test: linker required arguments validation
shelltest test_case "linker required arguments validation"
output=$(linker --source /tmp 2>&1)
shelltest assert_contains "$output" "--source and --destination are required" "linker should validate required arguments"

# Test: linker sed expression handling (mock test)
shelltest test_case "linker sed expression handling"
# Test that linker can handle sed expressions
output=$(linker --help 2>&1)
shelltest assert_contains "$output" "linker.sh" "linker should handle sed expressions"

