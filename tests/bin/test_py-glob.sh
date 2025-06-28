#!/bin/bash

# Tests for py-glob.py
# Comprehensive test coverage for the Glob CLI wrapper

shelltest test_suite "py-glob"

# Set up test environment
TEST_DIR="/tmp/py-glob_test_$$"
GLOB_CMD="py-glob"

# Clean up function
cleanup() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Set up test directory
setup_test_dir() {
    cleanup
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Create test files and directories
    mkdir -p testdir/subdir
    echo "test content" > testfile.txt
    echo "another file" > testfile.py
    echo "another file" > testdir/nested.py
    echo "deep file" > testdir/subdir/deep.txt
    echo "deep python" > testdir/subdir/deep.py
}

# Test: py-glob command exists and shows help
shelltest test_case "py-glob command exists and shows help"
shelltest assert_command_exists "$GLOB_CMD" "py-glob command should be available"
output=$($GLOB_CMD --help 2>&1)
shelltest assert_contains "$output" "Glob CLI" "help should show Glob CLI description"

# Test: glob command - basic pattern
shelltest test_case "glob command - basic pattern"
setup_test_dir
result=$($GLOB_CMD glob "*.txt")
shelltest assert_contains "$result" "testfile.txt" "glob should find .txt files"

# Test: glob command - multiple patterns
shelltest test_case "glob command - multiple patterns"
setup_test_dir
result=$($GLOB_CMD glob "*.py")
shelltest assert_contains "$result" "testfile.py" "glob should find .py files"

# Test: glob command - no matches
shelltest test_case "glob command - no matches"
setup_test_dir
result=$($GLOB_CMD glob "*.nonexistent")
shelltest assert_empty "$result" "glob should return empty for no matches"

# Test: glob command - recursive
shelltest test_case "glob command - recursive"
setup_test_dir
result=$($GLOB_CMD glob "**/*.txt" --recursive)
shelltest assert_contains "$result" "testfile.txt" "recursive glob should find root .txt files"
shelltest assert_contains "$result" "testdir/subdir/deep.txt" "recursive glob should find nested .txt files"

# Test: glob command - recursive with specific pattern
shelltest test_case "glob command - recursive with specific pattern"
setup_test_dir
result=$($GLOB_CMD glob "**/*.py" --recursive)
shelltest assert_contains "$result" "testfile.py" "recursive glob should find root .py files"
shelltest assert_contains "$result" "testdir/nested.py" "recursive glob should find nested .py files"
shelltest assert_contains "$result" "testdir/subdir/deep.py" "recursive glob should find deeply nested .py files"

# Test: iglob command - basic pattern
shelltest test_case "iglob command - basic pattern"
setup_test_dir
result=$($GLOB_CMD iglob "*.txt")
shelltest assert_contains "$result" "testfile.txt" "iglob should find .txt files"

# Test: iglob command - recursive
shelltest test_case "iglob command - recursive"
setup_test_dir
result=$($GLOB_CMD iglob "**/*.txt" --recursive)
shelltest assert_contains "$result" "testfile.txt" "recursive iglob should find root .txt files"
shelltest assert_contains "$result" "testdir/subdir/deep.txt" "recursive iglob should find nested .txt files"

# Test: escape command - basic characters
shelltest test_case "escape command - basic characters"
result=$($GLOB_CMD escape "file[1].txt")
shelltest assert_contains "$result" "file\\[1\\].txt" "escape should escape special characters"

# Test: escape command - multiple special characters
shelltest test_case "escape command - multiple special characters"
result=$($GLOB_CMD escape "file*?.txt")
shelltest assert_contains "$result" "file\\*\\?.txt" "escape should escape multiple special characters"

# Test: escape command - no special characters
shelltest test_case "escape command - no special characters"
result=$($GLOB_CMD escape "normal_file.txt")
shelltest assert_equal "normal_file.txt" "$result" "escape should not change normal characters"

# Test: glob command - character classes
shelltest test_case "glob command - character classes"
setup_test_dir
result=$($GLOB_CMD glob "testfile.[tp][xy][t]")
shelltest assert_contains "$result" "testfile.txt" "glob should handle character classes"
shelltest assert_contains "$result" "testfile.py" "glob should handle character classes"

# Test: glob command - question mark
shelltest test_case "glob command - question mark"
setup_test_dir
result=$($GLOB_CMD glob "testfile.??")
shelltest assert_contains "$result" "testfile.py" "glob should handle question mark"
shelltest assert_contains "$result" "testfile.txt" "glob should handle question mark"

# Test: glob command - star pattern
shelltest test_case "glob command - star pattern"
setup_test_dir
result=$($GLOB_CMD glob "test*")
shelltest assert_contains "$result" "testfile.txt" "glob should handle star pattern"
shelltest assert_contains "$result" "testfile.py" "glob should handle star pattern"

# Test: glob command - directory pattern
shelltest test_case "glob command - directory pattern"
setup_test_dir
result=$($GLOB_CMD glob "testdir/*")
shelltest assert_contains "$result" "testdir/nested.py" "glob should find files in directory"
shelltest assert_contains "$result" "testdir/subdir" "glob should find subdirectories"

# Test: glob command - absolute path
shelltest test_case "glob command - absolute path"
setup_test_dir
result=$($GLOB_CMD glob "$TEST_DIR/*.txt")
shelltest assert_contains "$result" "testfile.txt" "glob should work with absolute paths"

# Test: glob command - relative path with dots
shelltest test_case "glob command - relative path with dots"
setup_test_dir
result=$($GLOB_CMD glob "./*.txt")
shelltest assert_contains "$result" "testfile.txt" "glob should work with ./ prefix"

# Test: glob command - parent directory
shelltest test_case "glob command - parent directory"
setup_test_dir
cd testdir
result=$($GLOB_CMD glob "../*.txt")
shelltest assert_contains "$result" "../testfile.txt" "glob should work with ../ prefix"

# Test: JSON output
shelltest test_case "JSON output"
setup_test_dir
result=$($GLOB_CMD glob "*.txt" --json)
shelltest assert_contains "$result" "[" "JSON output should be array"
shelltest assert_contains "$result" "]" "JSON output should be array"

# Test: dry-run mode
shelltest test_case "dry-run mode"
setup_test_dir
result=$($GLOB_CMD glob "*.txt" --dry-run)
shelltest assert_contains "$result" "Would search for files matching" "dry-run should show what would be done"

# Test: verbose mode
shelltest test_case "verbose mode"
setup_test_dir
result=$($GLOB_CMD glob "*.txt" --verbose 2>&1)
shelltest assert_contains "$result" "glob" "verbose should show command being executed"

# Test: escape command - complex pattern
shelltest test_case "escape command - complex pattern"
result=$($GLOB_CMD escape "file[1-9]*?.{txt,py}")
shelltest assert_contains "$result" "file\\[1-9\\]\\*\\?\\.\\{txt,py\\}" "escape should handle complex patterns"

# Test: escape command - path separators
shelltest test_case "escape command - path separators"
result=$($GLOB_CMD escape "path/to/file[1].txt")
shelltest assert_contains "$result" "path/to/file\\[1\\].txt" "escape should preserve path separators"

# Test: glob command - case sensitivity
shelltest test_case "glob command - case sensitivity"
setup_test_dir
echo "UPPER.TXT" > UPPER.TXT
result=$($GLOB_CMD glob "*.txt")
shelltest assert_contains "$result" "testfile.txt" "glob should find lowercase .txt files"
shelltest assert_contains "$result" "UPPER.TXT" "glob should find uppercase .TXT files"

# Test: glob command - hidden files
shelltest test_case "glob command - hidden files"
setup_test_dir
echo "hidden content" > .hidden.txt
result=$($GLOB_CMD glob ".*")
shelltest assert_contains "$result" ".hidden.txt" "glob should find hidden files"

# Test: glob command - multiple extensions
shelltest test_case "glob command - multiple extensions"
setup_test_dir
result=$($GLOB_CMD glob "*.{txt,py}")
shelltest assert_contains "$result" "testfile.txt" "glob should find .txt files"
shelltest assert_contains "$result" "testfile.py" "glob should find .py files"

# Test: iglob command - no matches
shelltest test_case "iglob command - no matches"
setup_test_dir
result=$($GLOB_CMD iglob "*.nonexistent")
shelltest assert_empty "$result" "iglob should return empty for no matches"

# Test: escape command - empty string
shelltest test_case "escape command - empty string"
result=$($GLOB_CMD escape "")
shelltest assert_empty "$result" "escape should handle empty string"

# Test: glob command - current directory
shelltest test_case "glob command - current directory"
setup_test_dir
result=$($GLOB_CMD glob "*")
shelltest assert_contains "$result" "testfile.txt" "glob should find files in current directory"
shelltest assert_contains "$result" "testdir" "glob should find directories in current directory"

# Clean up
cleanup 