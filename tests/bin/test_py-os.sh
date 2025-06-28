#!/bin/bash

# Tests for py-os.py
# Comprehensive test coverage for the OS CLI wrapper

shelltest test_suite "py-os"

# Set up test environment
TEST_DIR="/tmp/py-os_test_$$"
OS_CMD="py-os"

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
    echo "another file" > testdir/nested.py
    echo "deep file" > testdir/subdir/deep.txt
    ln -s testfile.txt symlink.txt
    ln -s testdir symlink_dir
}

# Test: py-os command exists and shows help
shelltest test_case "py-os command exists and shows help"
shelltest assert_command_exists "$OS_CMD" "py-os command should be available"
output=$($OS_CMD --help 2>&1)
shelltest assert_contains "$output" "OS CLI" "help should show OS CLI description"

# Test: getcwd command
shelltest test_case "getcwd command"
setup_test_dir
result=$($OS_CMD getcwd)
shelltest assert_equal "$TEST_DIR" "$result" "getcwd should return current directory"

# Test: listdir command
shelltest test_case "listdir command"
setup_test_dir
result=$($OS_CMD listdir)
shelltest assert_contains "$result" "testfile.txt" "listdir should find testfile.txt"
shelltest assert_contains "$result" "testdir" "listdir should find testdir"

# Test: listdir with specific path
shelltest test_case "listdir with specific path"
result=$($OS_CMD listdir testdir)
shelltest assert_contains "$result" "nested.py" "listdir should find nested.py in testdir"
shelltest assert_contains "$result" "subdir" "listdir should find subdir in testdir"

# Test: makedirs command
shelltest test_case "makedirs command"
setup_test_dir
$OS_CMD makedirs newdir
shelltest assert_directory_exists "newdir" "makedirs should create directory"

# Test: makedirs with exist_ok
shelltest test_case "makedirs with exist_ok"
setup_test_dir
mkdir -p existing_dir
$OS_CMD makedirs existing_dir --exist-ok
shelltest assert_directory_exists "existing_dir" "makedirs should not fail with exist_ok"

# Test: remove command
shelltest test_case "remove command"
setup_test_dir
$OS_CMD remove testfile.txt
shelltest assert_file_not_exists "testfile.txt" "remove should delete file"

# Test: rmdir command
shelltest test_case "rmdir command"
setup_test_dir
$OS_CMD rmdir testdir/subdir
shelltest assert_directory_not_exists "testdir/subdir" "rmdir should remove empty directory"

# Test: rename command
shelltest test_case "rename command"
setup_test_dir
$OS_CMD rename testfile.txt renamed_file.txt
shelltest assert_file_exists "renamed_file.txt" "rename should create new file"
shelltest assert_file_not_exists "testfile.txt" "rename should remove old file"

# Test: stat command
shelltest test_case "stat command"
setup_test_dir
result=$($OS_CMD stat testfile.txt)
shelltest assert_contains "$result" "st_size" "stat should return file size"
shelltest assert_contains "$result" "st_mode" "stat should return file mode"

# Test: environ-get command
shelltest test_case "environ-get command"
result=$($OS_CMD environ-get PATH)
shelltest assert_not_empty "$result" "environ-get should return PATH value"

# Test: environ-get with default
shelltest test_case "environ-get with default"
result=$($OS_CMD environ-get NONEXISTENT_VAR --default "default_value")
shelltest assert_equal "default_value" "$result" "environ-get should return default value"

# Test: environ-set command
shelltest test_case "environ-set command"
setup_test_dir
$OS_CMD environ-set TEST_VAR "test_value"
result=$(echo $TEST_VAR)
shelltest assert_equal "test_value" "$result" "environ-set should set environment variable"

# Test: environ-unset command
shelltest test_case "environ-unset command"
setup_test_dir
export TEST_VAR="test_value"
$OS_CMD environ-unset TEST_VAR
result=$(echo $TEST_VAR)
shelltest assert_empty "$result" "environ-unset should unset environment variable"

# Test: path-join command
shelltest test_case "path-join command"
result=$($OS_CMD path-join path to file)
shelltest assert_equal "path/to/file" "$result" "path-join should join path components"

# Test: path-split command
shelltest test_case "path-split command"
result=$($OS_CMD path-split path/to/file)
shelltest assert_contains "$result" "path/to" "path-split should return head"
shelltest assert_contains "$result" "file" "path-split should return tail"

# Test: path-splitext command
shelltest test_case "path-splitext command"
result=$($OS_CMD path-splitext file.txt)
shelltest assert_contains "$result" "file" "path-splitext should return root"
shelltest assert_contains "$result" ".txt" "path-splitext should return extension"

# Test: path-basename command
shelltest test_case "path-basename command"
result=$($OS_CMD path-basename path/to/file.txt)
shelltest assert_equal "file.txt" "$result" "path-basename should return filename"

# Test: path-dirname command
shelltest test_case "path-dirname command"
result=$($OS_CMD path-dirname path/to/file.txt)
shelltest assert_equal "path/to" "$result" "path-dirname should return directory"

# Test: path-abspath command
shelltest test_case "path-abspath command"
setup_test_dir
result=$($OS_CMD path-abspath testfile.txt)
shelltest assert_contains "$result" "$TEST_DIR" "path-abspath should return absolute path"

# Test: path-exists command
shelltest test_case "path-exists command"
setup_test_dir
result=$($OS_CMD path-exists testfile.txt)
shelltest assert_equal "True" "$result" "path-exists should return True for existing file"

result=$($OS_CMD path-exists nonexistent.txt)
shelltest assert_equal "False" "$result" "path-exists should return False for non-existing file"

# Test: path-isfile command
shelltest test_case "path-isfile command"
setup_test_dir
result=$($OS_CMD path-isfile testfile.txt)
shelltest assert_equal "True" "$result" "path-isfile should return True for file"

result=$($OS_CMD path-isfile testdir)
shelltest assert_equal "False" "$result" "path-isfile should return False for directory"

# Test: path-isdir command
shelltest test_case "path-isdir command"
setup_test_dir
result=$($OS_CMD path-isdir testdir)
shelltest assert_equal "True" "$result" "path-isdir should return True for directory"

result=$($OS_CMD path-isdir testfile.txt)
shelltest assert_equal "False" "$result" "path-isdir should return False for file"

# Test: path-islink command
shelltest test_case "path-islink command"
setup_test_dir
result=$($OS_CMD path-islink symlink.txt)
shelltest assert_equal "True" "$result" "path-islink should return True for symlink"

result=$($OS_CMD path-islink testfile.txt)
shelltest assert_equal "False" "$result" "path-islink should return False for regular file"

# Test: path-getsize command
shelltest test_case "path-getsize command"
setup_test_dir
result=$($OS_CMD path-getsize testfile.txt)
shelltest assert_greater_than "0" "$result" "path-getsize should return positive size"

# Test: path-expanduser command
shelltest test_case "path-expanduser command"
result=$($OS_CMD path-expanduser ~/test)
shelltest assert_contains "$result" "/test" "path-expanduser should expand tilde"

# Test: path-expandvars command
shelltest test_case "path-expandvars command"
export TEST_VAR="test_value"
result=$($OS_CMD path-expandvars '$TEST_VAR/file')
shelltest assert_equal "test_value/file" "$result" "path-expandvars should expand variables"

# Test: path-relpath command
shelltest test_case "path-relpath command"
setup_test_dir
result=$($OS_CMD path-relpath testdir/nested.py testdir)
shelltest assert_equal "nested.py" "$result" "path-relpath should return relative path"

# Test: chdir command
shelltest test_case "chdir command"
setup_test_dir
mkdir -p subdir
$OS_CMD chdir subdir
result=$(pwd)
shelltest assert_contains "$result" "subdir" "chdir should change directory"

# Test: getlogin command
shelltest test_case "getlogin command"
result=$($OS_CMD getlogin)
shelltest assert_not_empty "$result" "getlogin should return username"

# Test: cpu-count command
shelltest test_case "cpu-count command"
result=$($OS_CMD cpu-count)
shelltest assert_greater_than "0" "$result" "cpu-count should return positive number"

# Test: getpid command
shelltest test_case "getpid command"
result=$($OS_CMD getpid)
shelltest assert_greater_than "0" "$result" "getpid should return positive process ID"

# Test: walk command
shelltest test_case "walk command"
setup_test_dir
result=$($OS_CMD walk .)
shelltest assert_contains "$result" "testfile.txt" "walk should find testfile.txt"
shelltest assert_contains "$result" "nested.py" "walk should find nested.py"

# Test: JSON output
shelltest test_case "JSON output"
setup_test_dir
result=$($OS_CMD listdir --json)
shelltest assert_contains "$result" "[" "JSON output should be array"
shelltest assert_contains "$result" "]" "JSON output should be array"

# Test: dry-run mode
shelltest test_case "dry-run mode"
setup_test_dir
result=$($OS_CMD remove testfile.txt --dry-run)
shelltest assert_contains "$result" "Would remove file" "dry-run should show what would be done"
shelltest assert_file_exists "testfile.txt" "dry-run should not actually remove file"

# Test: verbose mode
shelltest test_case "verbose mode"
setup_test_dir
result=$($OS_CMD listdir --verbose 2>&1)
shelltest assert_contains "$result" "listdir" "verbose should show command being executed"

# Clean up
cleanup 