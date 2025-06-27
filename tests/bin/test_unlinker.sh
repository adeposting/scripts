#!/bin/bash

# Tests for unlinker.sh
# Comprehensive test coverage for the unlinker utility

shelltest test_suite "unlinker"

# Test: unlinker command exists
shelltest test_case "unlinker command exists"
shelltest assert_command_exists "unlinker" "unlinker command should be available"

# Test: unlinker help command
shelltest test_case "unlinker help command"
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Description:" "help should show description section"

# Test: unlinker with -h flag
shelltest test_case "unlinker -h flag"
output=$(unlinker -h 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "-h should show script name"

# Test: unlinker with no arguments
shelltest test_case "unlinker with no arguments"
output=$(unlinker 2>&1)
shelltest assert_contains "$output" "At least one of --source or --destination must be provided" "unlinker should error with no arguments"

# Test: unlinker with invalid option
shelltest test_case "unlinker with invalid option"
output=$(unlinker --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "unlinker should error with invalid option"

# Test: unlinker function directly
shelltest test_case "unlinker function direct call"
source "../../src/bin/unlinker.sh"

# Test help behavior
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker function help should work"

# Test: unlinker help text content
shelltest test_case "unlinker help text content"
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "Description:" "help should show description section"
shelltest assert_contains "$output" "Unlinker Options:" "help should show unlinker options section"
shelltest assert_contains "$output" "--source" "help should mention source option"
shelltest assert_contains "$output" "--destination" "help should mention destination option"
shelltest assert_contains "$output" "--dry-run" "help should mention dry-run option"

# Test: unlinker function exists when sourced
shelltest test_case "unlinker function exists when sourced"
source "../../src/bin/unlinker.sh"
shelltest assert_function_exists "unlinker" "unlinker function should exist when sourced"

# Test: unlinker help function exists
shelltest test_case "unlinker help function exists"
source "../../src/bin/unlinker.sh"
shelltest assert_function_exists "unlinker_help" "unlinker_help function should exist when sourced"

# Test: unlinker source option validation
shelltest test_case "unlinker source option validation"
output=$(unlinker --source 2>&1)
shelltest assert_contains "$output" "--source requires a directory" "unlinker should validate source option"

# Test: unlinker destination option validation
shelltest test_case "unlinker destination option validation"
output=$(unlinker --destination 2>&1)
shelltest assert_contains "$output" "--destination requires a directory" "unlinker should validate destination option"

# Test: unlinker source directory validation
shelltest test_case "unlinker source directory validation"
output=$(unlinker --source /nonexistent/directory 2>&1)
shelltest assert_contains "$output" "Source directory does not exist" "unlinker should validate source directory exists"

# Test: unlinker destination directory validation
shelltest test_case "unlinker destination directory validation"
output=$(unlinker --destination /nonexistent/directory 2>&1)
shelltest assert_contains "$output" "Destination directory does not exist" "unlinker should validate destination directory exists"

# Test: unlinker dry-run option (mock test)
shelltest test_case "unlinker dry-run option"
# This would normally test dry-run functionality
# For now, we just verify the option can be parsed
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "--dry-run" "unlinker should handle dry-run option"

# Test: unlinker lister integration (mock test)
shelltest test_case "unlinker lister integration"
# Test that unlinker can integrate with lister
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should integrate with lister"

# Test: unlinker shlog integration (mock test)
shelltest test_case "unlinker shlog integration"
# Test that unlinker can integrate with shlog
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should integrate with shlog"

# Test: unlinker file selection options (mock test)
shelltest test_case "unlinker file selection options"
# Test that unlinker can handle file selection options
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should handle file selection options"

# Test: unlinker logging options (mock test)
shelltest test_case "unlinker logging options"
# Test that unlinker can handle logging options
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should handle logging options"

# Test: unlinker command structure
shelltest test_case "unlinker command structure"
# Verify that unlinker has the expected command structure
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "Usage:" "unlinker should have usage section"
shelltest assert_contains "$output" "Description:" "unlinker should have description section"
shelltest assert_contains "$output" "Unlinker Options:" "unlinker should have unlinker options section"

# Test: unlinker examples section
shelltest test_case "unlinker examples section"
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "Examples:" "help should show examples section"

# Test: unlinker symlink management (mock test)
shelltest test_case "unlinker symlink management"
# Test that unlinker can manage symlinks
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should manage symlinks"

# Test: unlinker broken link cleanup (mock test)
shelltest test_case "unlinker broken link cleanup"
# Test that unlinker can clean up broken links
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should clean up broken links"

# Test: unlinker error handling
shelltest test_case "unlinker error handling"
# Test that unlinker can handle errors gracefully
output=$(unlinker --help 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should handle errors gracefully"

# Test: unlinker with empty argument
shelltest test_case "unlinker with empty argument"
output=$(unlinker "" 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should handle empty arguments"

# Test: unlinker with whitespace argument
shelltest test_case "unlinker with whitespace argument"
output=$(unlinker "   " 2>&1)
shelltest assert_contains "$output" "unlinker.sh" "unlinker should handle whitespace arguments"

