#!/bin/bash

# Shell Script Test Framework
# Usage: shelltest run <test_script> [args...]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test state variables
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
CURRENT_TEST=""
TEST_SUITE=""
TEST_START_TIME=0
TEST_END_TIME=0

# State file for persistence between subprocesses
SHELLTEST_STATE_FILE=""

# Initialize test framework
test_init() {
    TEST_COUNT=0
    PASS_COUNT=0
    FAIL_COUNT=0
    SKIP_COUNT=0
    TEST_START_TIME=$(date +%s)
    echo "[INFO] Test framework initialized"
}

# Start a test suite
test_suite() {
    TEST_SUITE="${1:-Unknown suite}"
    echo -e "\n${BLUE}=== Test Suite: $TEST_SUITE ===${NC}"
}

# Start a test case
test_case() {
    CURRENT_TEST="${1:-Unknown test}"
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -e "\nTest $TEST_COUNT: $CURRENT_TEST"
}

# Pass a test
test_pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    echo -e "  ${GREEN}✓ PASS${NC}"
    if command -v shlog >/dev/null 2>&1; then
        shlog info "Test passed: $CURRENT_TEST"
    fi
}

# Fail a test
test_fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    local message="${1:-}"
    echo -e "  ${RED}✗ FAIL${NC}"
    if [[ -n "$message" ]]; then
        echo -e "    $message"
    fi
    if command -v shlog >/dev/null 2>&1; then
        shlog error "Test failed: $CURRENT_TEST - $message"
    fi
    
    # Exit immediately on test failure
    echo -e "\n${RED}Test suite failed! Stopping execution.${NC}"
    exit 1
}

# Skip a test
test_skip() {
    SKIP_COUNT=$((SKIP_COUNT + 1))
    local reason="${1:-}"
    echo -e "  ${YELLOW}⚠ SKIP${NC}"
    if [[ -n "$reason" ]]; then
        echo -e "    ${YELLOW}Reason: $reason${NC}"
    fi
    if command -v shlog >/dev/null 2>&1; then
        shlog warn "Test skipped: $CURRENT_TEST - $reason"
    fi
}

# Assertions
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if [[ "$expected" == "$actual" ]]; then
        test_pass
    else
        test_fail "Values should be equal (expected: '$expected', actual: '$actual')${message:+ - $message}"
    fi
}

assert_not_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if [[ "$expected" != "$actual" ]]; then
        test_pass
    else
        test_fail "Values should not be equal (expected: '$expected', actual: '$actual')${message:+ - $message}"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass
    else
        test_fail "String should contain substring (haystack: '$haystack', needle: '$needle')${message:+ - $message}"
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        test_pass
    else
        test_fail "String should not contain substring (haystack: '$haystack', needle: '$needle')${message:+ - $message}"
    fi
}

assert_command_exists() {
    local command="$1"
    local message="${2:-}"
    
    if command -v "$command" >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Command should exist: $command${message:+ - $message}"
    fi
}

assert_command_not_exists() {
    local command="$1"
    local message="${2:-}"
    
    if ! command -v "$command" >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Command should not exist: $command${message:+ - $message}"
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-}"
    
    if [[ -f "$file" ]]; then
        test_pass
    else
        test_fail "File should exist: $file${message:+ - $message}"
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-}"
    
    if [[ ! -f "$file" ]]; then
        test_pass
    else
        test_fail "File should not exist: $file${message:+ - $message}"
    fi
}

# Additional assertion functions that are used in tests
assert_empty() {
    local value="$1"
    local message="${2:-}"
    
    if [[ -z "$value" ]]; then
        test_pass
    else
        test_fail "Value should be empty (got: '$value')${message:+ - $message}"
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-}"
    
    if [[ -n "$value" ]]; then
        test_pass
    else
        test_fail "Value should not be empty${message:+ - $message}"
    fi
}

assert_directory_exists() {
    local directory="$1"
    local message="${2:-}"
    
    if [[ -d "$directory" ]]; then
        test_pass
    else
        test_fail "Directory should exist: '$directory'${message:+ - $message}"
    fi
}

assert_directory_not_exists() {
    local directory="$1"
    local message="${2:-}"
    
    if [[ ! -d "$directory" ]]; then
        test_pass
    else
        test_fail "Directory should not exist: '$directory'${message:+ - $message}"
    fi
}

assert_true() {
    local value="$1"
    local message="${2:-}"
    
    if [[ "$value" == "true" || "$value" == "True" || "$value" == "1" ]]; then
        test_pass
    else
        test_fail "Value should be true: '$value'${message:+ - $message}"
    fi
}

assert_false() {
    local value="$1"
    local message="${2:-}"
    
    if [[ "$value" == "false" || "$value" == "False" || "$value" == "0" ]]; then
        test_pass
    else
        test_fail "Value should be false: '$value'${message:+ - $message}"
    fi
}

assert_less_than() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if (( actual < expected )); then
        test_pass
    else
        test_fail "Value should be less than '$expected' (got: '$actual')${message:+ - $message}"
    fi
}

assert_less_than_or_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if (( actual <= expected )); then
        test_pass
    else
        test_fail "Value should be less than or equal to '$expected' (got: '$actual')${message:+ - $message}"
    fi
}

assert_greater_than() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if (( actual > expected )); then
        test_pass
    else
        test_fail "Value should be greater than '$expected' (got: '$actual')${message:+ - $message}"
    fi
}

assert_greater_than_or_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if (( actual >= expected )); then
        test_pass
    else
        test_fail "Value should be greater than or equal to '$expected' (got: '$actual')${message:+ - $message}"
    fi
}

assert_function_exists() {
    local function_name="$1"
    local message="${2:-}"
    
    if declare -F "$function_name" >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Function should exist: '$function_name'${message:+ - $message}"
    fi
}

# Print test summary
test_summary() {
    TEST_END_TIME=$(date +%s)
    local duration=$((TEST_END_TIME - TEST_START_TIME))
    echo -e "\n=== Test Summary ==="
    echo "Suite: $TEST_SUITE"
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    echo "Skipped: $SKIP_COUNT"
    echo "Duration: ${duration}s"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "\nAll tests passed!"
        exit 0
    else
        echo -e "\nSome tests failed!"
        exit 1
    fi
}

# Run a test script
run_test_script() {
    local test_script="$1"
    
    if [[ ! -f "$test_script" ]]; then
        echo "Error: Test script not found: $test_script" >&2
        exit 1
    fi
    
    # Initialize test framework
    test_init
    
    # Set up environment for the test script
    export SHELLTEST_SCRIPT_DIR="$(dirname "$test_script")"
    export SHELLTEST_SCRIPT_NAME="$(basename "$test_script")"
    export SHELLTEST_REPO_ROOT="$(cd "$(dirname "$test_script")/../.." && pwd)"
    
    # Make shelltest command available in the test script
    # The test script can call: shelltest test_case "test name"
    shelltest() {
        case "${1:-}" in
            test_suite)
                test_suite "${2:-}"
                ;;
            test_case)
                test_case "${2:-}"
                ;;
            test_pass)
                test_pass
                ;;
            test_fail)
                test_fail "${2:-}"
                ;;
            test_skip)
                test_skip "${2:-}"
                ;;
            assert_equal)
                assert_equal "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_not_equal)
                assert_not_equal "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_contains)
                assert_contains "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_not_contains)
                assert_not_contains "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_command_exists)
                assert_command_exists "${2:-}" "${3:-}"
                ;;
            assert_command_not_exists)
                assert_command_not_exists "${2:-}" "${3:-}"
                ;;
            assert_file_exists)
                assert_file_exists "${2:-}" "${3:-}"
                ;;
            assert_file_not_exists)
                assert_file_not_exists "${2:-}" "${3:-}"
                ;;
            assert_empty)
                assert_empty "${2:-}" "${3:-}"
                ;;
            assert_not_empty)
                assert_not_empty "${2:-}" "${3:-}"
                ;;
            assert_directory_exists)
                assert_directory_exists "${2:-}" "${3:-}"
                ;;
            assert_directory_not_exists)
                assert_directory_not_exists "${2:-}" "${3:-}"
                ;;
            assert_true)
                assert_true "${2:-}" "${3:-}"
                ;;
            assert_false)
                assert_false "${2:-}" "${3:-}"
                ;;
            assert_less_than)
                assert_less_than "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_less_than_or_equal)
                assert_less_than_or_equal "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_greater_than)
                assert_greater_than "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_greater_than_or_equal)
                assert_greater_than_or_equal "${2:-}" "${3:-}" "${4:-}"
                ;;
            assert_function_exists)
                assert_function_exists "${2:-}" "${3:-}"
                ;;
            test_summary)
                test_summary
                ;;
            *)
                test_fail "Unknown shelltest command: ${1:-}"
                ;;
        esac
    }
    
    # Export the shelltest function so it's available in the test script
    export -f shelltest
    
    # Source the test script
    source "$test_script"
    
    # Print summary
    test_summary
}

# Main function
main() {
    local cmd="${1:-}"
    
    case "$cmd" in
        run)
            shift
            local test_script="${1:-}"
            if [[ -z "$test_script" ]]; then
                echo "Error: Test script required" >&2
                exit 1
            fi
            run_test_script "$test_script"
            ;;
        *)
            echo "shelltest.sh - Shell Script Test Framework"
            echo "Usage: $0 run <test_script> [args...]"
            echo ""
            echo "Commands:"
            echo "  run <test_script>  Run a test script"
            echo ""
            echo "Available commands in test scripts:"
            echo "  shelltest test_suite <name>     Start a test suite"
            echo "  shelltest test_case <name>      Start a test case"
            echo "  shelltest test_pass             Pass the current test"
            echo "  shelltest test_fail <message>   Fail the current test"
            echo "  shelltest test_skip <reason>    Skip the current test"
            echo "  shelltest assert_equal <exp> <act> <msg>     Assert values are equal"
            echo "  shelltest assert_not_equal <exp> <act> <msg> Assert values are not equal"
            echo "  shelltest assert_contains <haystack> <needle> <msg> Assert string contains"
            echo "  shelltest assert_not_contains <haystack> <needle> <msg> Assert string does not contain"
            echo "  shelltest assert_command_exists <cmd> <msg>   Assert command exists"
            echo "  shelltest assert_command_not_exists <cmd> <msg> Assert command does not exist"
            echo "  shelltest assert_file_exists <file> <msg>     Assert file exists"
            echo "  shelltest assert_file_not_exists <file> <msg> Assert file does not exist"
            echo "  shelltest assert_empty <value> <msg>          Assert value is empty"
            echo "  shelltest assert_not_empty <value> <msg>      Assert value is not empty"
            echo "  shelltest assert_directory_exists <dir> <msg> Assert directory exists"
            echo "  shelltest assert_directory_not_exists <dir> <msg> Assert directory does not exist"
            echo "  shelltest assert_true <value> <msg>             Assert value is true"
            echo "  shelltest assert_false <value> <msg>            Assert value is false"
            echo "  shelltest test_summary           Print test summary and exit"
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 