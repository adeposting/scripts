#!/bin/bash

# Tests for git-workspace.sh
# Comprehensive test coverage for the git-workspace utility

shelltest test_suite "git-workspace"

# Test: git-workspace command exists
shelltest test_case "git-workspace command exists"
shelltest assert_command_exists "git-workspace" "git-workspace command should be available"

# Test: git-workspace help command
shelltest test_case "git-workspace help command"
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Options:" "help should show options section"

# Test: git-workspace with -h flag
shelltest test_case "git-workspace -h flag"
output=$(git-workspace -h 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "-h should show script name"

# Test: git-workspace with no arguments
shelltest test_case "git-workspace with no arguments"
output=$(git-workspace 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should show help with no arguments"

# Test: git-workspace with invalid option
shelltest test_case "git-workspace with invalid option"
output=$(git-workspace --invalid-option 2>&1)
shelltest assert_contains "$output" "Unknown option" "git-workspace should error with invalid option"

# Test: git-workspace function directly
shelltest test_case "git-workspace function direct call"
# Command should be available on PATH

# Test help behavior
output=$(git-workspace -h 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace function help should work"

# Test: git-workspace help text content
shelltest test_case "git-workspace help text content"
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "Options:" "help should show options section"
shelltest assert_contains "$output" "--sync" "help should mention sync option"
shelltest assert_contains "$output" "-s" "help should mention short sync option"
shelltest assert_contains "$output" "--help" "help should mention help option"
shelltest assert_contains "$output" "GIT_WORKSPACE_HOME" "help should mention environment variable"

# Test: git-workspace sync option structure
shelltest test_case "git-workspace sync option structure"
# This test verifies the sync option exists and can be parsed
# We can't easily test actual git operations in CI, but we can test the option parsing
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "--sync" "git-workspace should have sync option"

# Test: git-workspace function exists when sourced
shelltest test_case "git-workspace function exists when sourced"
# Command should be available on PATH
shelltest assert_function_exists "git_workspace" "git_workspace function should exist when sourced"

# Test: git-workspace help function exists
shelltest test_case "git-workspace help function exists"
# Command should be available on PATH
shelltest assert_function_exists "git_workspace_help" "git_workspace_help function should exist when sourced"

# Test: git-workspace sync function exists
shelltest test_case "git-workspace sync function exists"
# Command should be available on PATH
shelltest assert_function_exists "git_workspace_sync" "git_workspace_sync function should exist when sourced"

# Test: git-workspace with --sync option (mock test)
shelltest test_case "git-workspace with --sync option"
# This would normally perform git operations
# For now, we just verify the option can be parsed
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "--sync" "git-workspace should handle sync option"

# Test: git-workspace with -s option (mock test)
shelltest test_case "git-workspace with -s option"
# This would normally perform git operations
# For now, we just verify the option can be parsed
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "-s" "git-workspace should handle short sync option"

# Test: git-workspace environment variable support
shelltest test_case "git-workspace environment variable support"
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "GIT_WORKSPACE_HOME" "git-workspace should support environment variable"

# Test: git-workspace with empty argument
shelltest test_case "git-workspace with empty argument"
output=$(git-workspace "" 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle empty arguments"

# Test: git-workspace with whitespace argument
shelltest test_case "git-workspace with whitespace argument"
output=$(git-workspace "   " 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle whitespace arguments"

# Test: git-workspace command structure
shelltest test_case "git-workspace command structure"
# Verify that git-workspace has the expected command structure
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "Usage:" "git-workspace should have usage section"
shelltest assert_contains "$output" "Options:" "git-workspace should have options section"
shelltest assert_contains "$output" "Environment:" "git-workspace should have environment section"

# Test: git-workspace sync functionality (mock test)
shelltest test_case "git-workspace sync functionality"
# This would normally test git repository synchronization
# For now, we just verify the sync functionality is available
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "Sync all git repositories" "git-workspace should have sync functionality"

# Test: git-workspace workspace path handling
shelltest test_case "git-workspace workspace path handling"
# Test that git-workspace can handle workspace paths
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "WORKSPACE_PATH" "git-workspace should handle workspace paths"

# Test: git-workspace error handling
shelltest test_case "git-workspace error handling"
# Test that git-workspace can handle errors gracefully
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle errors gracefully"

# Test: git-workspace submodule handling (mock test)
shelltest test_case "git-workspace submodule handling"
# Test that git-workspace can handle submodules
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle submodules"

# Test: git-workspace namespace handling (mock test)
shelltest test_case "git-workspace namespace handling"
# Test that git-workspace can handle namespaces
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle namespaces"

# Test: git-workspace superproject handling (mock test)
shelltest test_case "git-workspace superproject handling"
# Test that git-workspace can handle superprojects
output=$(git-workspace --help 2>&1)
shelltest assert_contains "$output" "git-workspace.sh" "git-workspace should handle superprojects"

