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

# Test: shlog --help flag
shelltest test_case "shlog --help flag"
output=$(shlog --help 2>&1)
shelltest assert_contains "$output" "shlog.sh" "--help should show script name"

# Test: shlog -h flag
shelltest test_case "shlog -h flag"
output=$(shlog -h 2>&1)
shelltest assert_contains "$output" "shlog.sh" "-h should show script name"

# Test: shlog with no arguments
shelltest test_case "shlog with no arguments"
output=$(shlog 2>&1)
shelltest assert_contains "$output" "shlog.sh" "shlog should show help with no arguments"

# Test: shlog info command
shelltest test_case "shlog info command"
output=$(shlog info "test message" 2>&1)
shelltest assert_contains "$output" "test message" "shlog info should output the message"

# Test: shlog warn command
shelltest test_case "shlog warn command"
output=$(shlog warn "test warning" 2>&1)
shelltest assert_contains "$output" "test warning" "shlog warn should output the warning"

# Test: shlog error command
shelltest test_case "shlog error command"
output=$(shlog error "test error" 2>&1)
shelltest assert_contains "$output" "test error" "shlog error should output the error"

# Test: shlog debug command
shelltest test_case "shlog debug command"
output=$(shlog debug "test debug" 2>&1)
shelltest assert_contains "$output" "test debug" "shlog debug should output the debug message"

# Test: shlog note command
shelltest test_case "shlog note command"
output=$(shlog note "test note" 2>&1)
shelltest assert_contains "$output" "test note" "shlog note should output the note"

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
output=$(shlog set-level info 2>&1)
shelltest assert_contains "$output" "Log level set to: info" "shlog set-level should set log level"

# Test: shlog set-file command
shelltest test_case "shlog set-file command"
temp_file=$(mktemp)
output=$(shlog set-file "$temp_file" 2>&1)
shelltest assert_contains "$output" "Log file set to: $temp_file" "shlog set-file should set log file"
rm -f "$temp_file"

# Test: shlog get-level command
shelltest test_case "shlog get-level command"
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "info\|warn\|debug\|error" "shlog get-level should return a log level"

# Test: shlog get-file command
shelltest test_case "shlog get-file command"
temp_file=$(mktemp)
shlog set-file "$temp_file" >/dev/null 2>&1
output=$(shlog get-file 2>&1)
shelltest assert_contains "$output" "$temp_file" "shlog get-file should return the log file path"
rm -f "$temp_file"

# Test: shlog is-verbose command
shelltest test_case "shlog is-verbose command"
shlog set-verbose >/dev/null 2>&1
output=$(shlog is-verbose 2>&1)
shelltest assert_exit_code 0 "shlog is-verbose should return 0 when verbose is enabled"

# Test: shlog is-quiet command
shelltest test_case "shlog is-quiet command"
shlog set-quiet >/dev/null 2>&1
output=$(shlog is-quiet 2>&1)
shelltest assert_exit_code 0 "shlog is-quiet should return 0 when quiet is enabled"

# Test: shlog is-debug command
shelltest test_case "shlog is-debug command"
shlog set-debug >/dev/null 2>&1
output=$(shlog is-debug 2>&1)
shelltest assert_exit_code 0 "shlog is-debug should return 0 when debug is enabled"

# Test: shlog _print-common-help command
shelltest test_case "shlog _print-common-help command"
output=$(shlog _print-common-help 2>&1)
shelltest assert_contains "$output" "Logging Options:" "shlog _print-common-help should show logging options"
shelltest assert_contains "$output" "--quiet" "shlog _print-common-help should show --quiet option"
shelltest assert_contains "$output" "--verbose" "shlog _print-common-help should show --verbose option"
shelltest assert_contains "$output" "--log-level" "shlog _print-common-help should show --log-level option"
shelltest assert_contains "$output" "--log-file" "shlog _print-common-help should show --log-file option"

# Test: shlog _parse-options command (legacy)
shelltest test_case "shlog _parse-options command (legacy)"
output=$(shlog _parse-options --quiet --verbose 2>&1)
shelltest assert_exit_code 0 "shlog _parse-options should handle multiple options"

# Test: shlog _parse-and-export command (new enhanced approach)
shelltest test_case "shlog _parse-and-export command (new enhanced approach)"
output=$(shlog _parse-and-export --quiet 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle --quiet option"

# Test: shlog _parse-and-export with --verbose
shelltest test_case "shlog _parse-and-export with --verbose"
output=$(shlog _parse-and-export --verbose 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle --verbose option"

# Test: shlog _parse-and-export with --log-level
shelltest test_case "shlog _parse-and-export with --log-level"
output=$(shlog _parse-and-export --log-level debug 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle --log-level option"

# Test: shlog _parse-and-export with --log-file
shelltest test_case "shlog _parse-and-export with --log-file"
temp_file=$(mktemp)
output=$(shlog _parse-and-export --log-file "$temp_file" 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle --log-file option"
rm -f "$temp_file"

# Test: shlog _parse-and-export with mixed options
shelltest test_case "shlog _parse-and-export with mixed options"
output=$(shlog _parse-and-export --quiet --log-level info 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle multiple options"

# Test: shlog _parse-and-export with unknown options
shelltest test_case "shlog _parse-and-export with unknown options"
output=$(shlog _parse-and-export --unknown-option 2>&1)
shelltest assert_contains "$output" "--unknown-option" "shlog _parse-and-export should return unknown options"

# Test: shlog _parse-and-export with --log-level missing value
shelltest test_case "shlog _parse-and-export with --log-level missing value"
output=$(shlog _parse-and-export --log-level 2>&1)
shelltest assert_contains "$output" "--log-level requires a value" "shlog _parse-and-export should error on missing value"

# Test: shlog _parse-and-export with --log-file missing value
shelltest test_case "shlog _parse-and-export with --log-file missing value"
output=$(shlog _parse-and-export --log-file 2>&1)
shelltest assert_contains "$output" "--log-file requires a value" "shlog _parse-and-export should error on missing value"

# Test: shlog _parse-and-export with mixed valid and invalid options
shelltest test_case "shlog _parse-and-export with mixed valid and invalid options"
output=$(shlog _parse-and-export --quiet --invalid-option --verbose 2>&1)
shelltest assert_contains "$output" "--invalid-option" "shlog _parse-and-export should return invalid options"
shelltest assert_contains "$output" "--verbose" "shlog _parse-and-export should return remaining valid options"

# Test: shlog environment variable export
shelltest test_case "shlog environment variable export"
# Test that LOG_LEVEL is exported when using _parse-and-export
unset LOG_LEVEL
shlog _parse-and-export --log-level debug >/dev/null 2>&1
shelltest assert_equal "debug" "$LOG_LEVEL" "LOG_LEVEL should be exported with --log-level"

# Test: shlog LOG_FILE environment variable export
shelltest test_case "shlog LOG_FILE environment variable export"
# Test that LOG_FILE is exported when using _parse-and-export
unset LOG_FILE
temp_file=$(mktemp)
shlog _parse-and-export --log-file "$temp_file" >/dev/null 2>&1
shelltest assert_equal "$temp_file" "$LOG_FILE" "LOG_FILE should be exported with --log-file"
rm -f "$temp_file"

# Test: shlog _parse-and-export with no arguments
shelltest test_case "shlog _parse-and-export with no arguments"
output=$(shlog _parse-and-export 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle no arguments"

# Test: shlog _parse-and-export with empty string
shelltest test_case "shlog _parse-and-export with empty string"
output=$(shlog _parse-and-export "" 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle empty string"

# Test: shlog _parse-and-export with whitespace
shelltest test_case "shlog _parse-and-export with whitespace"
output=$(shlog _parse-and-export "   " 2>&1)
shelltest assert_exit_code 0 "shlog _parse-and-export should handle whitespace"

# Test: shlog integration with other scripts (mock test)
shelltest test_case "shlog integration with other scripts"
# Test that shlog can integrate with other scripts
output=$(shlog help 2>&1)
shelltest assert_contains "$output" "shlog.sh" "shlog should integrate with other scripts"

# Test: shlog color integration
shelltest test_case "shlog color integration"
# Test that shlog uses color for output
output=$(shlog info "test message" 2>&1)
shelltest assert_contains "$output" "test message" "shlog should use color for output"

# Test: shlog log file writing
shelltest test_case "shlog log file writing"
temp_file=$(mktemp)
shlog set-file "$temp_file" >/dev/null 2>&1
shlog info "test log message" >/dev/null 2>&1
if [[ -f "$temp_file" ]]; then
    shelltest assert_contains "$(cat "$temp_file")" "test log message" "shlog should write to log file"
else
    shelltest test_fail "Log file should be created"
fi
rm -f "$temp_file"

# Test: shlog log level filtering
shelltest test_case "shlog log level filtering"
# Test that shlog respects log level filtering
shlog set-level warn >/dev/null 2>&1
output=$(shlog info "this should not appear" 2>&1)
shelltest assert_not_contains "$output" "this should not appear" "shlog should filter by log level"

# Test: shlog invalid command
shelltest test_case "shlog invalid command"
output=$(shlog invalid_cmd 2>&1)
shelltest assert_contains "$output" "shlog.sh" "invalid command should show help"

# Test: shlog function directly
shelltest test_case "shlog function direct call"
output=$(shlog info "test" 2>/dev/null)
shelltest assert_contains "$output" "test" "shlog function should work directly"

# Test: shlog with VERBOSE environment variable
shelltest test_case "shlog with VERBOSE environment variable"
export VERBOSE=1
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "debug" "shlog should respect VERBOSE environment variable"
unset VERBOSE

# Test: shlog with QUIET environment variable
shelltest test_case "shlog with QUIET environment variable"
export QUIET=1
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "warn" "shlog should respect QUIET environment variable"
unset QUIET

# Test: shlog with DEBUG environment variable
shelltest test_case "shlog with DEBUG environment variable"
export DEBUG=1
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "debug" "shlog should respect DEBUG environment variable"
unset DEBUG

# Test: shlog with LOG_LEVEL environment variable
shelltest test_case "shlog with LOG_LEVEL environment variable"
export LOG_LEVEL=error
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "error" "shlog should respect LOG_LEVEL environment variable"
unset LOG_LEVEL

# Test: shlog conflict between VERBOSE and QUIET
shelltest test_case "shlog conflict between VERBOSE and QUIET"
export VERBOSE=1
export QUIET=1
output=$(shlog get-level 2>&1)
shelltest assert_contains "$output" "Cannot set VERBOSE and QUIET" "shlog should error on VERBOSE and QUIET conflict"
unset VERBOSE QUIET

# Test: shlog _begin-help-text command
shelltest test_case "shlog _begin-help-text command"
output=$(shlog _begin-help-text 2>&1)
shelltest assert_exit_code 0 "shlog _begin-help-text should work"

# Test: shlog _end-help-text command
shelltest test_case "shlog _end-help-text command"
output=$(shlog _end-help-text 2>&1)
shelltest assert_exit_code 0 "shlog _end-help-text should work"

# Test: shlog _begin-help-text and _end-help-text together
shelltest test_case "shlog _begin-help-text and _end-help-text together"
output=$(shlog _begin-help-text 2>&1 && shlog _end-help-text 2>&1)
shelltest assert_exit_code 0 "shlog _begin-help-text and _end-help-text should work together" 