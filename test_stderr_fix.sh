#!/bin/bash

# Test script to verify stderr capture fix
source "./src/shelltest.sh"

test_stderr_capture() {
    test_case "stderr capture test"
    
    # Test that stderr is captured correctly
    local stderr_output
    stderr_output=$(capture_stderr "echo 'stderr message' >&2")
    assert_equal "stderr message" "$stderr_output" "stderr should be captured correctly"
}

test_stderr_assertion() {
    test_case "stderr assertion test"
    
    # Test the new assertion function
    assert_stderr_contains "echo 'error message' >&2" "error" "stderr should contain 'error'"
}

test_stderr_equals() {
    test_case "stderr equals test"
    
    # Test exact stderr matching
    assert_stderr_equals "echo 'exact message' >&2" "exact message" "stderr should equal 'exact message'"
}

# Run tests
test_init
test_suite "stderr capture fix"
test_stderr_capture
test_stderr_assertion
test_stderr_equals
test_summary 