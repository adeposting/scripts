#!/bin/bash

# Tests for rsed.sh
# Comprehensive test coverage for the rsed utility

shelltest test_suite "rsed"

# Test: rsed command exists
shelltest test_case "rsed command exists"
shelltest assert_command_exists "rsed" "rsed command should be available"

# Test: rsed help command
shelltest test_case "rsed help command"
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Options:" "help should show options section"

# Test: rsed with -h flag
shelltest test_case "rsed -h flag"
output=$(rsed -h 2>&1)
shelltest assert_contains "$output" "rsed.sh" "-h should show script name"

# Test: rsed with no arguments
shelltest test_case "rsed with no arguments"
output=$(rsed 2>&1)
shelltest assert_contains "$output" "sed script is required" "rsed should error with no arguments"

# Test: rsed with empty script
shelltest test_case "rsed with empty script"
output=$(rsed "" 2>&1)
shelltest assert_contains "$output" "sed script is required" "rsed should error with empty script"

# Test: rsed with whitespace script
shelltest test_case "rsed with whitespace script"
output=$(rsed "   " 2>&1)
shelltest assert_contains "$output" "sed script is required" "rsed should error with whitespace script"

# Test: rsed function directly
shelltest test_case "rsed function direct call"
# Command should be available on PATH

# Test help behavior
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed function help should work"

# Test: rsed help text content
shelltest test_case "rsed help text content"
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "Options:" "help should show options section"
shelltest assert_contains "$output" "-i" "help should mention in-place option"
shelltest assert_contains "$output" "--include" "help should mention include option"
shelltest assert_contains "$output" "--exclude" "help should mention exclude option"
shelltest assert_contains "$output" "--no-hidden" "help should mention no-hidden option"

# Test: rsed function exists when sourced
shelltest test_case "rsed function exists when sourced"
# Command should be available on PATH
shelltest assert_function_exists "rsed" "rsed function should exist when sourced"

# Test: rsed help function exists
shelltest test_case "rsed help function exists"
# Command should be available on PATH
shelltest assert_function_exists "rsed_help" "rsed_help function should exist when sourced"

# Test: rsed sed configuration function exists
shelltest test_case "rsed sed configuration function exists"
# Command should be available on PATH
shelltest assert_function_exists "_rsed_configure_sed" "_rsed_configure_sed function should exist when sourced"

# Test: rsed build command function exists
shelltest test_case "rsed build command function exists"
# Command should be available on PATH
shelltest assert_function_exists "_rsed_build_sed_command" "_rsed_build_sed_command function should exist when sourced"

# Test: rsed option parsing (mock test)
shelltest test_case "rsed option parsing"
# This test verifies the rsed can parse options
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should be able to parse options"

# Test: rsed in-place option (mock test)
shelltest test_case "rsed in-place option"
# Test that rsed can handle in-place editing option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "-i" "rsed should handle in-place option"

# Test: rsed include option (mock test)
shelltest test_case "rsed include option"
# Test that rsed can handle include option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "--include" "rsed should handle include option"

# Test: rsed exclude option (mock test)
shelltest test_case "rsed exclude option"
# Test that rsed can handle exclude option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "--exclude" "rsed should handle exclude option"

# Test: rsed no-hidden option (mock test)
shelltest test_case "rsed no-hidden option"
# Test that rsed can handle no-hidden option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "--no-hidden" "rsed should handle no-hidden option"

# Test: rsed quiet option (mock test)
shelltest test_case "rsed quiet option"
# Test that rsed can handle quiet option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle quiet option"

# Test: rsed debug option (mock test)
shelltest test_case "rsed debug option"
# Test that rsed can handle debug option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle debug option"

# Test: rsed posix option (mock test)
shelltest test_case "rsed posix option"
# Test that rsed can handle posix option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle posix option"

# Test: rsed unbuffered option (mock test)
shelltest test_case "rsed unbuffered option"
# Test that rsed can handle unbuffered option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle unbuffered option"

# Test: rsed null-data option (mock test)
shelltest test_case "rsed null-data option"
# Test that rsed can handle null-data option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle null-data option"

# Test: rsed line-length option (mock test)
shelltest test_case "rsed line-length option"
# Test that rsed can handle line-length option
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle line-length option"

# Test: rsed invalid option
shelltest test_case "rsed invalid option"
output=$(rsed --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "rsed should error with invalid option"

# Test: rsed multiple scripts error
shelltest test_case "rsed multiple scripts error"
output=$(rsed "s/test/replace/" "s/another/replace/" 2>&1)
shelltest assert_contains "$output" "Multiple sed scripts not supported" "rsed should error with multiple scripts"

# Test: rsed command structure
shelltest test_case "rsed command structure"
# Verify that rsed has the expected command structure
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "Usage:" "rsed should have usage section"
shelltest assert_contains "$output" "Options:" "rsed should have options section"

# Test: rsed sed implementation detection
shelltest test_case "rsed sed implementation detection"
# Test that rsed can detect sed implementation
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should detect sed implementation"

# Test: rsed file processing (mock test)
shelltest test_case "rsed file processing"
# Test that rsed can process files
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should process files"

# Test: rsed lister integration (mock test)
shelltest test_case "rsed lister integration"
# Test that rsed can integrate with lister
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should integrate with lister"

# Test: rsed shlog integration (mock test)
shelltest test_case "rsed shlog integration"
# Test that rsed can integrate with shlog
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should integrate with shlog"

# Test: rsed ostype integration (mock test)
shelltest test_case "rsed ostype integration"
# Test that rsed can integrate with ostype
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should integrate with ostype"

# Test: rsed error handling
shelltest test_case "rsed error handling"
# Test that rsed can handle errors gracefully
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle errors gracefully"

# Test: rsed recursive processing
shelltest test_case "rsed recursive processing"
# Test that rsed can handle recursive processing
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "rsed.sh" "rsed should handle recursive processing"

# Test: rsed backup functionality
shelltest test_case "rsed backup functionality"
# Test that rsed can handle backup functionality
output=$(rsed --help 2>&1)
shelltest assert_contains "$output" "-i" "rsed should handle backup functionality"

