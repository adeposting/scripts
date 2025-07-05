#!/bin/bash

# Tests for py-subprocess.py
# Comprehensive test coverage for the Subprocess CLI wrapper

shelltest test_suite "py-subprocess"

# Set up test environment
SUBPROCESS_CMD="py-subprocess"

# Test: py-subprocess command exists and shows help
shelltest test_case "py-subprocess command exists and shows help"
shelltest assert_command_exists "$SUBPROCESS_CMD" "py-subprocess command should be available"
output=$($SUBPROCESS_CMD --help 2>&1)
shelltest assert_contains "$output" "Subprocess CLI" "help should show Subprocess CLI description"

# Test: run command - successful execution
shelltest test_case "run command - successful execution"
result=$($SUBPROCESS_CMD run echo hello)
shelltest assert_contains "$result" "hello" "run should execute command and return output"
shelltest assert_contains "$result" "returncode" "run should return return code"

# Test: run command - with timeout
shelltest test_case "run command - with timeout"
result=$($SUBPROCESS_CMD --timeout 2 run sleep 1)
shelltest assert_contains "$result" "returncode" "run should handle timeout"

# Test: run command - with shell
shelltest test_case "run command - with shell"
result=$($SUBPROCESS_CMD --shell run "echo hello world")
shelltest assert_contains "$result" "hello world" "run should work with shell"

# Test: call command - successful execution
shelltest test_case "call command - successful execution"
result=$($SUBPROCESS_CMD call echo hello)
# Extract just the exit code (last line if there's mixed output)
exit_code=$(echo "$result" | tail -n1)
shelltest assert_equal "0" "$exit_code" "call should return exit code 0 for successful command"

# Test: call command - with shell
shelltest test_case "call command - with shell"
result=$($SUBPROCESS_CMD --shell call "echo hello world")
# Extract just the exit code (last line if there's mixed output)
exit_code=$(echo "$result" | tail -n1)
shelltest assert_equal "0" "$exit_code" "call should work with shell"

# Test: check-call command - successful execution
shelltest test_case "check-call command - successful execution"
result=$($SUBPROCESS_CMD check-call echo hello)
# Extract just the exit code (last line if there's mixed output)
exit_code=$(echo "$result" | tail -n1)
shelltest assert_equal "0" "$exit_code" "check-call should return exit code 0 for successful command"

# Test: check-output command - successful execution
shelltest test_case "check-output command - successful execution"
result=$($SUBPROCESS_CMD check-output echo hello)
shelltest assert_equal "hello" "$result" "check-output should return command output"

# Test: check-output command - with shell
shelltest test_case "check-output command - with shell"
result=$($SUBPROCESS_CMD --shell check-output "echo hello world")
shelltest assert_equal "hello world" "$result" "check-output should work with shell"

# Test: popen command - basic usage
shelltest test_case "popen command - basic usage"
result=$($SUBPROCESS_CMD popen echo hello)
shelltest assert_contains "$result" "pid" "popen should return process info"
shelltest assert_contains "$result" "args" "popen should return command args"

# Test: popen command - with mode
shelltest test_case "popen command - with mode"
result=$($SUBPROCESS_CMD --mode r popen echo hello)
shelltest assert_contains "$result" "pid" "popen should work with mode"

# Test: popen command - with bufsize
shelltest test_case "popen command - with bufsize"
result=$($SUBPROCESS_CMD --bufsize 1024 popen echo hello)
shelltest assert_contains "$result" "pid" "popen should work with bufsize"

# Test: get-output command - successful execution
shelltest test_case "get-output command - successful execution"
result=$($SUBPROCESS_CMD get-output "echo hello")
shelltest assert_equal "hello" "$result" "get-output should return command output"

# Test: get-output command - with stderr
shelltest test_case "get-output command - with stderr"
result=$($SUBPROCESS_CMD get-output "echo hello 1>&2")
shelltest assert_equal "hello" "$result" "get-output should capture stderr"

# Test: get-status-output command - successful execution
shelltest test_case "get-status-output command - successful execution"
result=$($SUBPROCESS_CMD get-status-output "echo hello")
shelltest assert_contains "$result" "status" "get-status-output should return status"
shelltest assert_contains "$result" "output" "get-status-output should return output"

# Test: run command - failed execution
shelltest test_case "run command - failed execution"
result=$($SUBPROCESS_CMD run false)
shelltest assert_contains "$result" "returncode" "run should return return code for failed command"
shelltest assert_not_equal "0" "$(echo "$result" | grep -o '"returncode": [0-9]*' | cut -d' ' -f2)" "run should return non-zero for failed command"

# Test: call command - failed execution
shelltest test_case "call command - failed execution"
result=$($SUBPROCESS_CMD call false)
shelltest assert_not_equal "0" "$result" "call should return non-zero for failed command"

# Test: check-output command - failed execution (should fail)
shelltest test_case "check-output command - failed execution"
result=$($SUBPROCESS_CMD check-output false 2>&1)
shelltest assert_contains "$result" "Error" "check-output should fail for failed command"

# Test: run command - with working directory
shelltest test_case "run command - with working directory"
result=$($SUBPROCESS_CMD --cwd /tmp run pwd)
shelltest assert_contains "$result" "/tmp" "run should work with custom working directory"

# Test: run command - with environment variables
shelltest test_case "run command - with environment variables"
result=$($SUBPROCESS_CMD --env '{"TEST_VAR": "test_value"}' run "echo \$TEST_VAR")
shelltest assert_contains "$result" "test_value" "run should work with custom environment"

# Test: call command - with timeout
shelltest test_case "call command - with timeout"
result=$($SUBPROCESS_CMD --timeout 2 call sleep 1)
shelltest assert_equal "0" "$result" "call should handle timeout"

# Test: check-call command - with timeout
shelltest test_case "check-call command - with timeout"
result=$($SUBPROCESS_CMD --timeout 2 check-call sleep 1)
shelltest assert_equal "0" "$result" "check-call should handle timeout"

# Test: check-output command - with timeout
shelltest test_case "check-output command - with timeout"
result=$($SUBPROCESS_CMD --timeout 2 check-output sleep 1 2>&1)
shelltest assert_contains "$result" "Error" "check-output should fail with timeout"

# Test: popen command - with shell
shelltest test_case "popen command - with shell"
result=$($SUBPROCESS_CMD --shell popen "echo hello world")
shelltest assert_contains "$result" "pid" "popen should work with shell"

# Test: popen command - with working directory
shelltest test_case "popen command - with working directory"
result=$($SUBPROCESS_CMD --cwd /tmp popen pwd)
shelltest assert_contains "$result" "pid" "popen should work with custom working directory"

# Test: JSON output
shelltest test_case "JSON output"
result=$($SUBPROCESS_CMD --json run echo hello)
shelltest assert_contains "$result" "{" "JSON output should be object"
shelltest assert_contains "$result" "}" "JSON output should be object"

# Test: dry-run mode
shelltest test_case "dry-run mode"
result=$($SUBPROCESS_CMD --dry-run run echo hello)
shelltest assert_contains "$result" "Would run" "dry-run should show what would be done"

# Test: verbose mode
shelltest test_case "verbose mode"
result=$($SUBPROCESS_CMD --verbose run echo hello 2>&1)
shelltest assert_contains "$result" "run" "verbose should show command being executed"

# Test: run command - with text mode
shelltest test_case "run command - with text mode"
result=$($SUBPROCESS_CMD --text run echo hello)
shelltest assert_contains "$result" "hello" "run should work with text mode"

# Test: check-output command - with text mode
shelltest test_case "check-output command - with text mode"
result=$($SUBPROCESS_CMD --text check-output echo hello)
shelltest assert_equal "hello" "$result" "check-output should work with text mode"

# Test: run command - with check flag
shelltest test_case "run command - with check flag"
result=$($SUBPROCESS_CMD run echo hello --check)
shelltest assert_contains "$result" "hello" "run should work with check flag"

# Test: run command - with check flag and failed command
shelltest test_case "run command - with check flag and failed command"
result=$($SUBPROCESS_CMD run false --check 2>&1)
shelltest assert_contains "$result" "Error" "run should fail with check flag for failed command"

# Test: call command - with working directory
shelltest test_case "call command - with working directory"
result=$($SUBPROCESS_CMD call pwd --cwd /tmp)
shelltest assert_equal "0" "$result" "call should work with custom working directory"

# Test: check-call command - with working directory
shelltest test_case "check-call command - with working directory"
result=$($SUBPROCESS_CMD check-call pwd --cwd /tmp)
shelltest assert_equal "0" "$result" "check-call should work with custom working directory"

# Test: check-output command - with working directory
shelltest test_case "check-output command - with working directory"
result=$($SUBPROCESS_CMD check-output pwd --cwd /tmp)
shelltest assert_contains "$result" "/tmp" "check-output should work with custom working directory"

# Test: popen command - with environment variables
shelltest test_case "popen command - with environment variables"
result=$($SUBPROCESS_CMD popen "echo \$TEST_VAR" --env '{"TEST_VAR": "test_value"}')
shelltest assert_contains "$result" "pid" "popen should work with custom environment"

# Test: run command - complex command
shelltest test_case "run command - complex command"
result=$($SUBPROCESS_CMD run "echo 'hello world' | wc -w")
shelltest assert_contains "$result" "2" "run should handle complex commands"

# Test: call command - complex command
shelltest test_case "call command - complex command"
result=$($SUBPROCESS_CMD call "echo 'hello world' | wc -w" --shell)
shelltest assert_equal "0" "$result" "call should handle complex commands with shell"

# Test: check-output command - complex command
shelltest test_case "check-output command - complex command"
result=$($SUBPROCESS_CMD check-output "echo 'hello world' | wc -w" --shell)
shelltest assert_contains "$result" "2" "check-output should handle complex commands with shell"

# Test: get-output command - complex command
shelltest test_case "get-output command - complex command"
result=$($SUBPROCESS_CMD get-output "echo 'hello world' | wc -w")
shelltest assert_contains "$result" "2" "get-output should handle complex commands"

# Test: get-status-output command - complex command
shelltest test_case "get-status-output command - complex command"
result=$($SUBPROCESS_CMD get-status-output "echo 'hello world' | wc -w")
shelltest assert_contains "$result" "status" "get-status-output should handle complex commands"
shelltest assert_contains "$result" "output" "get-status-output should handle complex commands"

# Test: run command - command with arguments
shelltest test_case "run command - command with arguments"
result=$($SUBPROCESS_CMD run echo hello world)
shelltest assert_contains "$result" "hello world" "run should handle command with arguments"

# Test: call command - command with arguments
shelltest test_case "call command - command with arguments"
result=$($SUBPROCESS_CMD call echo hello world)
shelltest assert_equal "0" "$result" "call should handle command with arguments"

# Test: check-output command - command with arguments
shelltest test_case "check-output command - command with arguments"
result=$($SUBPROCESS_CMD check-output echo hello world)
shelltest assert_equal "hello world" "$result" "check-output should handle command with arguments"

# Test: popen command - command with arguments
shelltest test_case "popen command - command with arguments"
result=$($SUBPROCESS_CMD popen echo hello world)
shelltest assert_contains "$result" "pid" "popen should handle command with arguments"

# Test: run command - non-existent command
shelltest test_case "run command - non-existent command"
result=$($SUBPROCESS_CMD run nonexistent_command 2>&1)
shelltest assert_contains "$result" "Error" "run should handle non-existent command"

# Test: call command - non-existent command
shelltest test_case "call command - non-existent command"
result=$($SUBPROCESS_CMD call nonexistent_command 2>&1)
shelltest assert_contains "$result" "Error" "call should handle non-existent command"

# Test: check-output command - non-existent command
shelltest test_case "check-output command - non-existent command"
result=$($SUBPROCESS_CMD check-output nonexistent_command 2>&1)
shelltest assert_contains "$result" "Error" "check-output should handle non-existent command"

# Test: get-output command - non-existent command
shelltest test_case "get-output command - non-existent command"
result=$($SUBPROCESS_CMD get-output "nonexistent_command 2>&1")
shelltest assert_contains "$result" "command not found" "get-output should handle non-existent command"

# Test: get-status-output command - non-existent command
shelltest test_case "get-status-output command - non-existent command"
result=$($SUBPROCESS_CMD get-status-output "nonexistent_command 2>&1")
shelltest assert_contains "$result" "status" "get-status-output should handle non-existent command"
shelltest assert_contains "$result" "output" "get-status-output should handle non-existent command" 