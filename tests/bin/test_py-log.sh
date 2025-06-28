#!/bin/bash

# Tests for shlog.sh
# Comprehensive test coverage for the shlog utility

shelltest test_suite "shlog"

# Test: shlog command exists
shelltest test_case "shlog command exists"
shelltest assert_command_exists "shlog" "shlog command should be available"

# Test: shlog help command
shelltest test_case "shlog help command"
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "shlog.sh" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"
shelltest assert_contains "$output" "Commands:" "help should show commands section"

# Test: shlog with --help flag
shelltest test_case "shlog --help flag"
output=$(shlog --help 2>&1)
shelltest assert_contains "$output" "shlog.sh" "--help should show script name"

# Test: shlog with -h flag
shelltest test_case "shlog -h flag"
output=$(shlog -h 2>&1)
shelltest assert_contains "$output" "shlog.sh" "-h should show script name"

# Test: shlog with no arguments
shelltest test_case "shlog with no arguments"
output=$(shlog 2>&1)
shelltest assert_contains "$output" "shlog.sh" "shlog should show help with no arguments"

# Test: shlog with invalid command
shelltest test_case "shlog with invalid command"
output=$(shlog invalid_cmd 2>&1)
shelltest assert_contains "$output" "shlog.sh" "invalid command should show help"

# Test: shlog function directly
shelltest test_case "shlog function direct call"
# Command should be available on PATH

# Test help behavior
output=$(shlog help)
shelltest assert_contains "$output" "shlog.sh" "shlog function help should work"

# Test: shlog help text content
shelltest test_case "shlog help text content"
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "Commands:" "help should show commands section"
shelltest assert_contains "$output" "info" "help should mention info command"
shelltest assert_contains "$output" "warn" "help should mention warn command"
shelltest assert_contains "$output" "error" "help should mention error command"
shelltest assert_contains "$output" "debug" "help should mention debug command"
shelltest assert_contains "$output" "note" "help should mention note command"

# Test: shlog info command
shelltest test_case "shlog info command"
output=$(shlog info "test message" 2>&1)
shelltest assert_contains "$output" "[INFO]" "shlog info should output INFO tag"

# Test: shlog warn command
shelltest test_case "shlog warn command"
output=$(shlog warn "test warning" 2>&1)
shelltest assert_contains "$output" "[WARN]" "shlog warn should output WARN tag"

# Test: shlog error command
shelltest test_case "shlog error command"
output=$(shlog error "test error" 2>&1)
shelltest assert_contains "$output" "[ERROR]" "shlog error should output ERROR tag"

# Test: shlog debug command
shelltest test_case "shlog debug command"
output=$(shlog debug "test debug" 2>&1)
shelltest assert_contains "$output" "[DEBUG]" "shlog debug should output DEBUG tag"

# Test: shlog note command
shelltest test_case "shlog note command"
output=$(shlog note "test note" 2>&1)
shelltest assert_contains "$output" "[NOTE]" "shlog note should output NOTE tag"

# Test: shlog set-verbose command
shelltest test_case "shlog set-verbose command"
output=$(shlog set-verbose 2>&1)
shelltest assert_contains "$output" "Verbose mode enabled" "shlog set-verbose should enable verbose mode"

# Test: shlog set-quiet command
shelltest test_case "shlog set-quiet command"
output=$(shlog set-quiet 2>&1)
shelltest assert_contains "$output" "Quiet mode enabled" "shlog set-quiet should enable quiet mode"

# Test: shlog set-debug command
shelltest test_case "shlog set-debug command"
output=$(shlog set-debug 2>&1)
shelltest assert_contains "$output" "Debug mode enabled" "shlog set-debug should enable debug mode"

# Test: shlog set-level command
shelltest test_case "shlog set-level command"
output=$(shlog set-level "warn" 2>&1)
shelltest assert_contains "$output" "Log level set to: warn" "shlog set-level should set log level"

# Test: shlog set-level with empty argument
shelltest test_case "shlog set-level with empty argument"
output=$(shlog set-level "" 2>&1)
shelltest assert_contains "$output" "log level required" "shlog set-level should error with empty argument"

# Test: shlog set-file command
shelltest test_case "shlog set-file command"
output=$(shlog set-file "/tmp/test.log" 2>&1)
shelltest assert_contains "$output" "Log file set to: /tmp/test.log" "shlog set-file should set log file"

# Test: shlog set-file with empty argument
shelltest test_case "shlog set-file with empty argument"
output=$(shlog set-file "" 2>&1)
shelltest assert_contains "$output" "log file path required" "shlog set-file should error with empty argument"

# Test: shlog get-level command
shelltest test_case "shlog get-level command"
output=$(shlog get-level 2>/dev/null)
shelltest assert_not_equal "" "$output" "shlog get-level should return non-empty level"

# Test: shlog get-level-number command
shelltest test_case "shlog get-level-number command"
output=$(shlog get-level-number 2>/dev/null)
shelltest assert_not_equal "" "$output" "shlog get-level-number should return non-empty number"

# Test: shlog get-level-color command
shelltest test_case "shlog get-level-color command"
output=$(shlog get-level-color 2>/dev/null)
shelltest assert_not_equal "" "$output" "shlog get-level-color should return non-empty color"

# Test: shlog get-file command
shelltest test_case "shlog get-file command"
# Set a log file first
shlog set-file "/tmp/test.log" >/dev/null 2>&1
output=$(shlog get-file 2>/dev/null)
shelltest assert_contains "$output" "/tmp/test.log" "shlog get-file should return set log file"

# Test: shlog is-verbose command
shelltest test_case "shlog is-verbose command"
# Enable verbose mode first
shlog set-verbose >/dev/null 2>&1
output=$(shlog is-verbose 2>/dev/null)
shelltest assert_equal "0" "$?" "shlog is-verbose should return success when verbose is enabled"

# Test: shlog is-quiet command
shelltest test_case "shlog is-quiet command"
# Enable quiet mode first
shlog set-quiet >/dev/null 2>&1
output=$(shlog is-quiet 2>/dev/null)
shelltest assert_equal "0" "$?" "shlog is-quiet should return success when quiet is enabled"

# Test: shlog is-debug command
shelltest test_case "shlog is-debug command"
# Enable debug mode first
shlog set-debug >/dev/null 2>&1
output=$(shlog is-debug 2>/dev/null)
shelltest assert_equal "0" "$?" "shlog is-debug should return success when debug is enabled"

# Test: shlog function exists when sourced
shelltest test_case "shlog function exists when sourced"
# Command should be available on PATH
shelltest assert_function_exists "log" "log function should exist when sourced"

# Test: shlog help function exists
shelltest test_case "shlog help function exists"
# Command should be available on PATH
shelltest assert_function_exists "log_help" "log_help function should exist when sourced"

# Test: shlog level ranking function exists
shelltest test_case "shlog level ranking function exists"
# Command should be available on PATH
shelltest assert_function_exists "get_log_level_number" "get_log_level_number function should exist when sourced"

# Test: shlog level color function exists
shelltest test_case "shlog level color function exists"
# Command should be available on PATH
shelltest assert_function_exists "get_log_level_color" "get_log_level_color function should exist when sourced"

# Test: shlog get level function exists
shelltest test_case "shlog get level function exists"
# Command should be available on PATH
shelltest assert_function_exists "get_log_level" "get_log_level function should exist when sourced"

# Test: shlog level ranking
shelltest test_case "shlog level ranking"
# Command should be available on PATH
debug_num=$(get_log_level_number "debug")
info_num=$(get_log_level_number "info")
note_num=$(get_log_level_number "note")
warn_num=$(get_log_level_number "warn")
error_num=$(get_log_level_number "error")
shelltest assert_equal "0" "$debug_num" "debug should have rank 0"
shelltest assert_equal "1" "$info_num" "info should have rank 1"
shelltest assert_equal "2" "$note_num" "note should have rank 2"
shelltest assert_equal "3" "$warn_num" "warn should have rank 3"
shelltest assert_equal "4" "$error_num" "error should have rank 4"

# Test: shlog level colors
shelltest test_case "shlog level colors"
# Command should be available on PATH
debug_color=$(get_log_level_color "debug")
info_color=$(get_log_level_color "info")
note_color=$(get_log_level_color "note")
warn_color=$(get_log_level_color "warn")
error_color=$(get_log_level_color "error")
shelltest assert_equal "cyan" "$debug_color" "debug should have cyan color"
shelltest assert_equal "green" "$info_color" "info should have green color"
shelltest assert_equal "blue" "$note_color" "note should have blue color"
shelltest assert_equal "yellow" "$warn_color" "warn should have yellow color"
shelltest assert_equal "red" "$error_color" "error should have red color"

# Test: shlog environment variable support
shelltest test_case "shlog environment variable support"
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "Environment Variables:" "help should mention environment variables"
shelltest assert_contains "$output" "VERBOSE" "help should mention VERBOSE variable"
shelltest assert_contains "$output" "QUIET" "help should mention QUIET variable"
shelltest assert_contains "$output" "DEBUG" "help should mention DEBUG variable"
shelltest assert_contains "$output" "LOG_LEVEL" "help should mention LOG_LEVEL variable"
shelltest assert_contains "$output" "LOG_FILE" "help should mention LOG_FILE variable"

# Test: shlog setters section
shelltest test_case "shlog setters section"
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "Setters:" "help should show setters section"
shelltest assert_contains "$output" "set-verbose" "help should mention set-verbose"
shelltest assert_contains "$output" "set-quiet" "help should mention set-quiet"
shelltest assert_contains "$output" "set-debug" "help should mention set-debug"
shelltest assert_contains "$output" "set-level" "help should mention set-level"
shelltest assert_contains "$output" "set-file" "help should mention set-file"

# Test: shlog getters section
shelltest test_case "shlog getters section"
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "Getters:" "help should show getters section"
shelltest assert_contains "$output" "get-level" "help should mention get-level"
shelltest assert_contains "$output" "get-level-number" "help should mention get-level-number"
shelltest assert_contains "$output" "get-level-color" "help should mention get-level-color"
shelltest assert_contains "$output" "get-file" "help should mention get-file"
shelltest assert_contains "$output" "is-verbose" "help should mention is-verbose"
shelltest assert_contains "$output" "is-quiet" "help should mention is-quiet"
shelltest assert_contains "$output" "is-debug" "help should mention is-debug"

# Test: shlog command structure
shelltest test_case "shlog command structure"
# Verify that shlog has the expected command structure
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "Usage:" "shlog should have usage section"
shelltest assert_contains "$output" "Commands:" "shlog should have commands section"
shelltest assert_contains "$output" "Environment Variables:" "shlog should have environment section"
shelltest assert_contains "$output" "Setters:" "shlog should have setters section"
shelltest assert_contains "$output" "Getters:" "shlog should have getters section"

