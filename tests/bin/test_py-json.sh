#!/bin/bash

# Test script for py-json using shelltest framework
# This script should be run with: shelltest run ./tests/bin/test_py-json.sh

# Set up test environment
TEST_DIR="/tmp/py-json_test_$$"
JSON_CMD="py-json"

# Clean up function
cleanup() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Set up test directory
setup_test_dir() {
    cleanup
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
}

# Start test suite
shelltest test_suite "py-json"

# Test 1: Command exists and shows help
shelltest test_case "py-json command exists and shows help"
shelltest assert_command_exists "$JSON_CMD" "py-json command should be available"
output=$($JSON_CMD --help 2>&1)
shelltest assert_contains "$output" "JSON CLI" "help should show JSON CLI description"

# Test 2: dumps command
shelltest test_case "dumps command"
setup_test_dir
result=$($JSON_CMD dumps '{"key": "value"}')
shelltest assert_equal '{"key": "value"}' "$result" "dumps should return compact JSON"

# Test 3: dumps with indent
shelltest test_case "dumps command with indent"
result=$($JSON_CMD dumps '{"key": "value"}' --indent 2)
expected='{
  "key": "value"
}'
shelltest assert_equal "$expected" "$result" "dumps with indent should format JSON"

# Test 4: dumps with sort keys
shelltest test_case "dumps command with sort keys"
result=$($JSON_CMD dumps '{"b": 2, "a": 1}' --sort-keys)
shelltest assert_equal '{"a": 1, "b": 2}' "$result" "dumps with sort-keys should sort keys"

# Test 5: loads command
shelltest test_case "loads command"
result=$($JSON_CMD loads '{"key": "value"}')
shelltest assert_contains "$result" '"key"' "loads should contain key"
shelltest assert_contains "$result" '"value"' "loads should contain value"

# Test 6: dump command
shelltest test_case "dump command"
setup_test_dir
$JSON_CMD dump test.json '{"key": "value"}' --indent 2
shelltest assert_file_exists "test.json" "dump should create file"
content=$(cat test.json)
expected='{
  "key": "value"
}'
shelltest assert_equal "$expected" "$content" "dump should write correct content"

# Test 7: load command
shelltest test_case "load command"
setup_test_dir
echo '{"key": "value"}' > test.json
result=$($JSON_CMD load test.json)
shelltest assert_equal '{"key": "value"}' "$result" "load should read JSON from file"

# Test 8: validate command - valid JSON
shelltest test_case "validate command with valid JSON"
if $JSON_CMD validate '{"key": "value"}' | grep -q "True"; then
    shelltest test_pass
else
    shelltest test_fail "validate should return True for valid JSON"
fi

# Test 9: validate command - invalid JSON
shelltest test_case "validate command with invalid JSON"
if $JSON_CMD validate '{"key": "value"' | grep -q "False"; then
    shelltest test_pass
else
    shelltest test_fail "validate should return False for invalid JSON"
fi

# Test 10: format command
shelltest test_case "format command"
result=$($JSON_CMD format '{"key":"value"}' --indent 2)
expected='{
  "key": "value"
}'
shelltest assert_equal "$expected" "$result" "format should format JSON"

# Test 11: format command with sort keys
shelltest test_case "format command with sort keys"
result=$($JSON_CMD format '{"b":2,"a":1}' --indent 2 --sort-keys)
expected='{
  "a": 1,
  "b": 2
}'
shelltest assert_equal "$expected" "$result" "format with sort-keys should sort keys"

# Test 12: minify command
shelltest test_case "minify command"
result=$($JSON_CMD minify '{
  "key": "value"
}')
shelltest assert_equal '{"key":"value"}' "$result" "minify should remove whitespace"

# Test 13: dumps with separators
shelltest test_case "dumps command with separators"
result=$($JSON_CMD dumps '{"key": "value"}' --separators "|,=")
shelltest assert_equal '{"key"="value"}' "$result" "dumps with separators should use custom separators"

# Test 14: dumps with no ensure ascii
shelltest test_case "dumps command with no ensure ascii"
result=$($JSON_CMD dumps '{"key": "café"}' --no-ensure-ascii)
shelltest assert_equal '{"key": "café"}' "$result" "dumps with no-ensure-ascii should preserve unicode"

# Test 15: dump command with dry run
shelltest test_case "dump command with dry run"
result=$($JSON_CMD --dry-run dump test.json '{"key": "value"}')
shelltest assert_contains "$result" "Would write" "dry-run should show what would be done"

# Test 16: Complex data structures
shelltest test_case "dumps command with complex data"
result=$($JSON_CMD dumps '{"list": [1, 2, 3], "nested": {"key": "value"}}' --indent 2)
shelltest assert_contains "$result" '"list"' "complex data should contain list"
shelltest assert_contains "$result" '"nested"' "complex data should contain nested"

# Clean up
cleanup 