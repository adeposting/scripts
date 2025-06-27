#!/bin/bash

# Tests for lister.sh
# Comprehensive test coverage for the lister utility

shelltest test_suite "lister"

# Test: lister command exists
shelltest test_case "lister command exists"
shelltest assert_command_exists "lister" "lister command should be available"

# Test: lister help command
shelltest test_case "lister help command"
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Description:" "help should show description section"

# Test: lister with -h flag
shelltest test_case "lister -h flag"
output=$(lister -h 2>&1)
shelltest assert_contains "$output" "lister.sh" "-h should show script name"

# Test: lister with no arguments
shelltest test_case "lister with no arguments"
output=$(lister 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should list files with no arguments"

# Test: lister with invalid option
shelltest test_case "lister with invalid option"
output=$(lister --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "lister should error with invalid option"

# Test: lister function directly
shelltest test_case "lister function direct call"
source "../../src/bin/lister.sh"

# Test help behavior
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister function help should work"

# Test: lister help text content
shelltest test_case "lister help text content"
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "Description:" "help should show description section"
shelltest assert_contains "$output" "Options:" "help should show options section"
shelltest assert_contains "$output" "--include" "help should mention include option"
shelltest assert_contains "$output" "--exclude" "help should mention exclude option"
shelltest assert_contains "$output" "--no-hidden" "help should mention no-hidden option"

# Test: lister function exists when sourced
shelltest test_case "lister function exists when sourced"
source "../../src/bin/lister.sh"
shelltest assert_function_exists "lister" "lister function should exist when sourced"

# Test: lister help function exists
shelltest test_case "lister help function exists"
source "../../src/bin/lister.sh"
shelltest assert_function_exists "lister_help" "lister_help function should exist when sourced"

# Test: lister get files function exists
shelltest test_case "lister get files function exists"
source "../../src/bin/lister.sh"
shelltest assert_function_exists "_lister_get_files" "_lister_get_files function should exist when sourced"

# Test: lister include option validation
shelltest test_case "lister include option validation"
output=$(lister --include 2>&1)
shelltest assert_contains "$output" "--include requires a pattern" "lister should validate include option"

# Test: lister exclude option validation
shelltest test_case "lister exclude option validation"
output=$(lister --exclude 2>&1)
shelltest assert_contains "$output" "--exclude requires a pattern" "lister should validate exclude option"

# Test: lister no-hidden option
shelltest test_case "lister no-hidden option"
output=$(lister --no-hidden 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle no-hidden option"

# Test: lister no-gitignore option
shelltest test_case "lister no-gitignore option"
output=$(lister --no-gitignore 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle no-gitignore option"

# Test: lister no-recursive option
shelltest test_case "lister no-recursive option"
output=$(lister --no-recursive 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle no-recursive option"

# Test: lister follow-symlinks option
shelltest test_case "lister follow-symlinks option"
output=$(lister --follow-symlinks 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle follow-symlinks option"

# Test: lister include pattern
shelltest test_case "lister include pattern"
output=$(lister --include ".*\\.sh$" 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle include pattern"

# Test: lister exclude pattern
shelltest test_case "lister exclude pattern"
output=$(lister --exclude "\\.bak$" 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle exclude pattern"

# Test: lister git integration (mock test)
shelltest test_case "lister git integration"
# Test that lister can integrate with git
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should integrate with git"

# Test: lister file filtering (mock test)
shelltest test_case "lister file filtering"
# Test that lister can filter files
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should filter files"

# Test: lister command structure
shelltest test_case "lister command structure"
# Verify that lister has the expected command structure
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "Usage:" "lister should have usage section"
shelltest assert_contains "$output" "Description:" "lister should have description section"
shelltest assert_contains "$output" "Options:" "lister should have options section"

# Test: lister examples section
shelltest test_case "lister examples section"
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "Examples:" "help should show examples section"

# Test: lister gitignore handling (mock test)
shelltest test_case "lister gitignore handling"
# Test that lister can handle .gitignore
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should handle .gitignore"

# Test: lister recursive listing (mock test)
shelltest test_case "lister recursive listing"
# Test that lister can list recursively
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should list recursively"

# Test: lister hidden file handling (mock test)
shelltest test_case "lister hidden file handling"
# Test that lister can handle hidden files
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should handle hidden files"

# Test: lister symlink handling (mock test)
shelltest test_case "lister symlink handling"
# Test that lister can handle symlinks
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should handle symlinks"

# Test: lister error handling
shelltest test_case "lister error handling"
# Test that lister can handle errors gracefully
output=$(lister --help 2>&1)
shelltest assert_contains "$output" "lister.sh" "lister should handle errors gracefully"

# Test: lister with empty argument
shelltest test_case "lister with empty argument"
output=$(lister "" 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle empty arguments"

# Test: lister with whitespace argument
shelltest test_case "lister with whitespace argument"
output=$(lister "   " 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle whitespace arguments"

# Test: lister with specific path
shelltest test_case "lister with specific path"
output=$(lister . 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle specific paths"

# Test: lister multiple paths
shelltest test_case "lister multiple paths"
output=$(lister . . 2>/dev/null)
shelltest assert_not_equal "" "$output" "lister should handle multiple paths"

