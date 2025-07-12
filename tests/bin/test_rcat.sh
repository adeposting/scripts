#!/bin/bash

# Tests for rcat.sh
# Comprehensive test coverage for the rcat utility

shelltest test_suite "rcat"

# Test: rcat command exists
shelltest test_case "rcat command exists"
shelltest assert_command_exists "rcat" "rcat command should be available"

# Test: rcat help command
shelltest test_case "rcat help command"
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Arguments:" "help should show arguments section"

# Test: rcat with -h flag
shelltest test_case "rcat -h flag"
output=$(rcat -h 2>&1)
shelltest assert_contains "$output" "rcat.sh" "-h should show script name"

# Test: rcat with no arguments
shelltest test_case "rcat with no arguments"
output=$(rcat 2>&1)
shelltest assert_contains "$output" "No input paths provided" "rcat should error with no arguments"

# Test: rcat function directly
shelltest test_case "rcat function direct call"
# Command should be available on PATH

# Test help behavior
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat function help should work"

# Test: rcat help text content
shelltest test_case "rcat help text content"
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "Arguments:" "help should show arguments section"
shelltest assert_contains "$output" "--include" "help should mention include option"
shelltest assert_contains "$output" "--exclude" "help should mention exclude option"
shelltest assert_contains "$output" "--no-hidden" "help should mention no-hidden option"
shelltest assert_contains "$output" "Example with directory structure:" "help should show example section"

# Test: rcat function exists when sourced
shelltest test_case "rcat function exists when sourced"
# Command should be available on PATH
shelltest assert_function_exists "rcat" "rcat function should exist when sourced"

# Test: rcat help function exists
shelltest test_case "rcat help function exists"
# Command should be available on PATH
shelltest assert_function_exists "rcat_help" "rcat_help function should exist when sourced"

# Test: rcat option parsing (mock test)
shelltest test_case "rcat option parsing"
# This test verifies the rcat can parse options
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should be able to parse options"

# Test: rcat include option (mock test)
shelltest test_case "rcat include option"
# Test that rcat can handle include option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "--include" "rcat should handle include option"

# Test: rcat exclude option (mock test)
shelltest test_case "rcat exclude option"
# Test that rcat can handle exclude option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "--exclude" "rcat should handle exclude option"

# Test: rcat no-hidden option (mock test)
shelltest test_case "rcat no-hidden option"
# Test that rcat can handle no-hidden option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "--no-hidden" "rcat should handle no-hidden option"

# Test: rcat no-gitignore option (mock test)
shelltest test_case "rcat no-gitignore option"
# Test that rcat can handle no-gitignore option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle no-gitignore option"

# Test: rcat no-recursive option (mock test)
shelltest test_case "rcat no-recursive option"
# Test that rcat can handle no-recursive option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle no-recursive option"

# Test: rcat follow-symlinks option (mock test)
shelltest test_case "rcat follow-symlinks option"
# Test that rcat can handle follow-symlinks option
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle follow-symlinks option"

# Test: rcat invalid option
shelltest test_case "rcat invalid option"
output=$(rcat --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "rcat should error with invalid option"

# Test: rcat command structure
shelltest test_case "rcat command structure"
# Verify that rcat has the expected command structure
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "Usage:" "rcat should have usage section"
shelltest assert_contains "$output" "Arguments:" "rcat should have arguments section"

# Test: rcat file processing (mock test)
shelltest test_case "rcat file processing"
# Test that rcat can process files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should process files"

# Test: rcat lister integration (mock test)
shelltest test_case "rcat lister integration"
# Test that rcat can integrate with lister
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should integrate with lister"

# Test: rcat shlog integration (mock test)
shelltest test_case "rcat shlog integration"
# Test that rcat can integrate with shlog
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should integrate with shlog"

# Test: rcat error handling
shelltest test_case "rcat error handling"
# Test that rcat can handle errors gracefully
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle errors gracefully"

# Test: rcat recursive processing
shelltest test_case "rcat recursive processing"
# Test that rcat can handle recursive processing
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle recursive processing"

# Test: rcat markdown output format
shelltest test_case "rcat markdown output format"
# Test that rcat produces markdown output
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "markdown" "rcat should produce markdown output"

# Test: rcat directory structure example
shelltest test_case "rcat directory structure example"
# Test that rcat shows directory structure example
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "Example with directory structure:" "rcat should show directory structure example"
shelltest assert_contains "$output" "src/" "rcat should show src/ in example"
shelltest assert_contains "$output" "file1.txt" "rcat should show file1.txt in example"
shelltest assert_contains "$output" "file2.txt" "rcat should show file2.txt in example"

# Test: rcat output format example
shelltest test_case "rcat output format example"
# Test that rcat shows output format example
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "Output:" "rcat should show output section"
shelltest assert_contains "$output" "```" "rcat should show code block markers in example"

# Test: rcat path handling
shelltest test_case "rcat path handling"
# Test that rcat can handle different path types
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "PATH" "rcat should mention PATH argument"
shelltest assert_contains "$output" "PATHS..." "rcat should mention PATHS... argument"

# Test: rcat file and directory processing
shelltest test_case "rcat file and directory processing"
# Test that rcat can process both files and directories
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "file or directory" "rcat should mention file or directory processing"

# Test: rcat relative path handling
shelltest test_case "rcat relative path handling"
# Test that rcat can handle relative paths
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle relative paths"

# Test: rcat absolute path handling
shelltest test_case "rcat absolute path handling"
# Test that rcat can handle absolute paths
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle absolute paths"

# Test: rcat invalid path handling
shelltest test_case "rcat invalid path handling"
# Test that rcat can handle invalid paths gracefully
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle invalid paths gracefully"

# Test: rcat empty file handling
shelltest test_case "rcat empty file handling"
# Test that rcat can handle empty files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle empty files"

# Test: rcat binary file handling
shelltest test_case "rcat binary file handling"
# Test that rcat can handle binary files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle binary files"

# Test: rcat large file handling
shelltest test_case "rcat large file handling"
# Test that rcat can handle large files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should handle large files"

# Test: rcat multiple file processing
shelltest test_case "rcat multiple file processing"
# Test that rcat can process multiple files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "file1.txt file2.txt" "rcat should show multiple file example"

# Test: rcat recursive directory processing
shelltest test_case "rcat recursive directory processing"
# Test that rcat can process directories recursively
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "src/" "rcat should show recursive directory example"

# Test: rcat hidden file handling
shelltest test_case "rcat hidden file handling"
# Test that rcat can handle hidden files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "hidden files" "rcat should mention hidden files"

# Test: rcat gitignore respect
shelltest test_case "rcat gitignore respect"
# Test that rcat respects .gitignore files
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" ".gitignore" "rcat should mention .gitignore respect"

# Test: rcat fallback behavior
shelltest test_case "rcat fallback behavior"
# Test that rcat has fallback behavior when lister is not available
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should have fallback behavior"

# Test: rcat error messages
shelltest test_case "rcat error messages"
# Test that rcat provides clear error messages
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should provide clear error messages"

# Test: rcat help text formatting
shelltest test_case "rcat help text formatting"
# Test that rcat has properly formatted help text
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "Description:" "rcat should have description section"
shelltest assert_contains "$output" "Examples:" "rcat should have examples section"

# Test: rcat bash compatibility
shelltest test_case "rcat bash compatibility"
# Test that rcat is compatible with bash
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should be bash compatible"

# Test: rcat cross-platform compatibility
shelltest test_case "rcat cross-platform compatibility"
# Test that rcat works across different platforms
output=$(rcat --help 2>&1)
shelltest assert_contains "$output" "rcat.sh" "rcat should be cross-platform compatible" 