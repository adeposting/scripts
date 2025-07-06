#!/bin/bash

# Tests for py-re.py
# Comprehensive test coverage for the Re CLI wrapper

shelltest test_suite "py-re"

# Set up test environment
RE_CMD="py-re"

# Test: py-re command exists and shows help
shelltest test_case "py-re command exists and shows help"
shelltest assert_command_exists "$RE_CMD" "py-re command should be available"
output=$($RE_CMD --help 2>&1)
shelltest assert_contains "$output" "Re CLI" "help should show Re CLI description"

# Test: match command - successful match
shelltest test_case "match command - successful match"
result=$($RE_CMD match "hello" "hello world")
shelltest assert_contains "$result" "hello" "match should find pattern at beginning"
shelltest assert_contains "$result" "start" "match should return start position"

# Test: match command - no match
shelltest test_case "match command - no match"
result=$($RE_CMD match "world" "hello world")
shelltest assert_equal "No match" "$result" "match should return 'No match' when no match"

# Test: search command - successful search
shelltest test_case "search command - successful search"
result=$($RE_CMD search "world" "hello world")
shelltest assert_contains "$result" "world" "search should find pattern anywhere"
shelltest assert_contains "$result" "start" "search should return start position"

# Test: search command - no match
shelltest test_case "search command - no match"
result=$($RE_CMD search "xyz" "hello world")
shelltest assert_equal "No match" "$result" "search should return 'No match' when no match"

# Test: fullmatch command - successful full match
shelltest test_case "fullmatch command - successful full match"
result=$($RE_CMD fullmatch "hello world" "hello world")
shelltest assert_contains "$result" "hello world" "fullmatch should match entire string"
shelltest assert_contains "$result" "start" "fullmatch should return start position"

# Test: fullmatch command - partial match
shelltest test_case "fullmatch command - partial match"
result=$($RE_CMD fullmatch "hello" "hello world")
shelltest assert_equal "No match" "$result" "fullmatch should not match partial string"

# Test: findall command - multiple matches
shelltest test_case "findall command - multiple matches"
result=$($RE_CMD findall "\\d+" "abc123def456")
shelltest assert_contains "$result" "123" "findall should find first number"
shelltest assert_contains "$result" "456" "findall should find second number"

# Test: findall command - no matches
shelltest test_case "findall command - no matches"
result=$($RE_CMD findall "\\d+" "abcdef")
shelltest assert_empty "$result" "findall should return empty for no matches"

# Test: finditer command - multiple matches
shelltest test_case "finditer command - multiple matches"
result=$($RE_CMD finditer "\\d+" "abc123def456")
shelltest assert_contains "$result" "123" "finditer should find first number"
shelltest assert_contains "$result" "456" "finditer should find second number"
shelltest assert_contains "$result" "start" "finditer should return position info"

# Test: sub command - simple substitution
shelltest test_case "sub command - simple substitution"
result=$($RE_CMD sub "\\d+" "X" "abc123def456")
shelltest assert_equal "abcXdefX" "$result" "sub should replace all digits with X"

# Test: sub command - with count
shelltest test_case "sub command - with count"
result=$($RE_CMD sub "\\d+" "X" "abc123def456" --count 1)
shelltest assert_equal "abcXdef456" "$result" "sub should replace only first digit with count=1"

# Test: subn command - substitution with count
shelltest test_case "subn command - substitution with count"
result=$($RE_CMD subn "\\d+" "X" "abc123def456")
shelltest assert_contains "$result" "abcXdefX" "subn should return substituted string"
shelltest assert_contains "$result" "count" "subn should return count"

# Test: split command - simple split
shelltest test_case "split command - simple split"
result=$($RE_CMD split "\\s+" "hello   world")
shelltest assert_contains "$result" "hello" "split should return first part"
shelltest assert_contains "$result" "world" "split should return second part"

# Test: split command - with maxsplit
shelltest test_case "split command - with maxsplit"
result=$($RE_CMD split "\\s+" "hello world test" --maxsplit 1)
shelltest assert_contains "$result" "hello" "split should return first part"
shelltest assert_contains "$result" "world test" "split should return remaining as one part"

# Test: escape command - special characters
shelltest test_case "escape command - special characters"
result=$($RE_CMD escape "file[1].txt")
shelltest assert_contains "$result" "file\\[1\\]\\.txt" "escape should escape special characters"

# Test: escape command - multiple special characters
shelltest test_case "escape command - multiple special characters"
result=$($RE_CMD escape "file*?.txt")
shelltest assert_contains "$result" "file\\*\\?\\.txt" "escape should escape multiple special characters"

# Test: compile command - valid pattern
shelltest test_case "compile command - valid pattern"
result=$($RE_CMD compile "\\d+")
shelltest assert_equal "\\d+" "$result" "compile should return pattern string"

# Test: match command - with flags
shelltest test_case "match command - with flags"
result=$($RE_CMD match "hello" "HELLO world" --flags 1)
shelltest assert_contains "$result" "HELLO" "match should work with IGNORECASE flag"

# Test: search command - with flags
shelltest test_case "search command - with flags"
result=$($RE_CMD search "world" "hello\nworld" --flags 2)
shelltest assert_contains "$result" "world" "search should work with MULTILINE flag"

# Test: findall command - with flags
shelltest test_case "findall command - with flags"
result=$($RE_CMD findall "hello" "HELLO world" --flags 1)
shelltest assert_contains "$result" "HELLO" "findall should work with IGNORECASE flag"

# Test: sub command - with flags
shelltest test_case "sub command - with flags"
result=$($RE_CMD sub "hello" "WORLD" "HELLO world" --flags 1)
shelltest assert_equal "WORLD world" "$result" "sub should work with IGNORECASE flag"

# Test: split command - with flags
shelltest test_case "split command - with flags"
result=$($RE_CMD split "\\s+" "hello   WORLD" --flags 1)
shelltest assert_contains "$result" "hello" "split should work with IGNORECASE flag"
shelltest assert_contains "$result" "WORLD" "split should work with IGNORECASE flag"

# Test: JSON output
shelltest test_case "JSON output"
result=$($RE_CMD --json match "hello" "hello world")
shelltest assert_contains "$result" "{" "JSON output should be object"
shelltest assert_contains "$result" "}" "JSON output should be object"

# Test: dry-run mode
shelltest test_case "dry-run mode"
result=$($RE_CMD --dry-run sub "\\d+" "X" "abc123def456")
shelltest assert_contains "$result" "Would substitute" "dry-run should show what would be done"

# Test: verbose mode
shelltest test_case "verbose mode"
result=$($RE_CMD --verbose search "world" "hello world" 2>&1)
shelltest assert_contains "$result" "search" "verbose should show command being executed"

# Test: match command - groups
shelltest test_case "match command - groups"
result=$($RE_CMD match "(\\w+) (\\w+)" "hello world")
shelltest assert_contains "$result" "hello world" "match should return full match"
shelltest assert_contains "$result" "hello" "match should return first group"
shelltest assert_contains "$result" "world" "match should return second group"

# Test: search command - groups
shelltest test_case "search command - groups"
result=$($RE_CMD search "(\\d+)" "abc123def")
shelltest assert_contains "$result" "123" "search should return matched group"

# Test: findall command - groups
shelltest test_case "findall command - groups"
result=$($RE_CMD findall "(\\d+)" "abc123def456")
shelltest assert_contains "$result" "123" "findall should return first group"
shelltest assert_contains "$result" "456" "findall should return second group"

# Test: finditer command - groups
shelltest test_case "finditer command - groups"
result=$($RE_CMD finditer "(\\d+)" "abc123def456")
shelltest assert_contains "$result" "123" "finditer should return first group"
shelltest assert_contains "$result" "456" "finditer should return second group"

# Test: sub command - backreferences
shelltest test_case "sub command - backreferences"
result=$($RE_CMD sub "(\\w+) (\\w+)" "\\2 \\1" "hello world")
shelltest assert_equal "world hello" "$result" "sub should support backreferences"

# Test: subn command - backreferences
shelltest test_case "subn command - backreferences"
result=$($RE_CMD subn "(\\w+) (\\w+)" "\\2 \\1" "hello world")
shelltest assert_contains "$result" "world hello" "subn should support backreferences"

# Test: escape command - empty string
shelltest test_case "escape command - empty string"
result=$($RE_CMD escape "")
shelltest assert_empty "$result" "escape should handle empty string"

# Test: escape command - no special characters
shelltest test_case "escape command - no special characters"
result=$($RE_CMD escape "normal_text")
shelltest assert_equal "normal_text" "$result" "escape should not change normal text"

# Test: match command - complex pattern
shelltest test_case "match command - complex pattern"
result=$($RE_CMD match "^[A-Za-z]+\\s+\\d+$" "Hello 123")
shelltest assert_contains "$result" "Hello 123" "match should handle complex patterns"

# Test: search command - word boundaries
shelltest test_case "search command - word boundaries"
result=$($RE_CMD search "\\bworld\\b" "hello world test")
shelltest assert_contains "$result" "world" "search should respect word boundaries"

# Test: findall command - non-capturing groups
shelltest test_case "findall command - non-capturing groups"
result=$($RE_CMD findall "(?:\\d{3})-(\\d{2})" "123-45 678-90")
shelltest assert_contains "$result" "45" "findall should handle non-capturing groups"
shelltest assert_contains "$result" "90" "findall should handle non-capturing groups"

# Test: split command - empty string
shelltest test_case "split command - empty string"
result=$($RE_CMD split "\\s+" "")
shelltest assert_contains "$result" "" "split should handle empty string"

# Test: split command - no matches
shelltest test_case "split command - no matches"
result=$($RE_CMD split "\\d+" "hello world")
shelltest assert_contains "$result" "hello world" "split should return original string when no matches"

# Test: compile command - invalid pattern (should fail gracefully)
shelltest test_case "compile command - invalid pattern"
result=$($RE_CMD compile "[" 2>&1)
shelltest assert_contains "$result" "Error" "compile should handle invalid patterns gracefully" 