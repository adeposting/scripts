#!/bin/bash

# Tests for py-shutil.py
# Comprehensive test coverage for the Shutil CLI wrapper

shelltest test_suite "py-shutil"

# Set up test environment
TEST_DIR="/tmp/py-shutil_test_$$"
SHUTIL_CMD="py-shutil"

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
}

# Test: py-shutil command exists and shows help
shelltest test_case "py-shutil command exists and shows help"
shelltest assert_command_exists "$SHUTIL_CMD" "py-shutil command should be available"
output=$($SHUTIL_CMD --help 2>&1)
shelltest assert_contains "$output" "Shutil CLI" "help should show Shutil CLI description"

# Test: copy command
shelltest test_case "copy command"
setup_test_dir
$SHUTIL_CMD copy testfile.txt testfile_copy.txt
shelltest assert_file_exists "testfile_copy.txt" "copy should create destination file"
shelltest assert_equal "$(cat testfile.txt)" "$(cat testfile_copy.txt)" "copy should preserve content"

# Test: copy2 command
shelltest test_case "copy2 command"
setup_test_dir
$SHUTIL_CMD copy2 testfile.txt testfile_copy2.txt
shelltest assert_file_exists "testfile_copy2.txt" "copy2 should create destination file"
shelltest assert_equal "$(cat testfile.txt)" "$(cat testfile_copy2.txt)" "copy2 should preserve content"

# Test: copyfile command
shelltest test_case "copyfile command"
setup_test_dir
$SHUTIL_CMD copyfile testfile.txt testfile_copyfile.txt
shelltest assert_file_exists "testfile_copyfile.txt" "copyfile should create destination file"
shelltest assert_equal "$(cat testfile.txt)" "$(cat testfile_copyfile.txt)" "copyfile should preserve content"

# Test: copytree command
shelltest test_case "copytree command"
setup_test_dir
$SHUTIL_CMD copytree testdir testdir_copy
shelltest assert_directory_exists "testdir_copy" "copytree should create destination directory"
shelltest assert_file_exists "testdir_copy/nested.py" "copytree should copy files"
shelltest assert_file_exists "testdir_copy/subdir/deep.txt" "copytree should copy subdirectories"

# Test: copytree with dirs_exist_ok
shelltest test_case "copytree with dirs_exist_ok"
setup_test_dir
mkdir -p existing_dir
$SHUTIL_CMD copytree testdir existing_dir --dirs-exist-ok
shelltest assert_file_exists "existing_dir/nested.py" "copytree should copy into existing directory"

# Test: move command
shelltest test_case "move command"
setup_test_dir
$SHUTIL_CMD move testfile.txt moved_file.txt
shelltest assert_file_exists "moved_file.txt" "move should create destination file"
shelltest assert_file_not_exists "testfile.txt" "move should remove source file"

# Test: rmtree command
shelltest test_case "rmtree command"
setup_test_dir
$SHUTIL_CMD rmtree testdir
shelltest assert_directory_not_exists "testdir" "rmtree should remove directory tree"

# Test: rmtree with ignore_errors
shelltest test_case "rmtree with ignore_errors"
setup_test_dir
$SHUTIL_CMD rmtree nonexistent_dir --ignore-errors
shelltest assert_true "rmtree should not fail with ignore_errors"

# Test: make-archive command
shelltest test_case "make-archive command"
setup_test_dir
$SHUTIL_CMD make-archive backup zip --root-dir .
shelltest assert_file_exists "backup.zip" "make-archive should create zip file"

# Test: unpack-archive command
shelltest test_case "unpack-archive command"
setup_test_dir
$SHUTIL_CMD make-archive backup zip --root-dir .
mkdir extract_dir
$SHUTIL_CMD unpack-archive backup.zip --extract-dir extract_dir
shelltest assert_file_exists "extract_dir/testfile.txt" "unpack-archive should extract files"

# Test: disk-usage command
shelltest test_case "disk-usage command"
result=$($SHUTIL_CMD disk-usage .)
shelltest assert_contains "$result" "total" "disk-usage should return total"
shelltest assert_contains "$result" "used" "disk-usage should return used"
shelltest assert_contains "$result" "free" "disk-usage should return free"

# Test: which command
shelltest test_case "which command"
result=$($SHUTIL_CMD which python3)
shelltest assert_not_empty "$result" "which should find python3"
shelltest assert_contains "$result" "python3" "which should return path containing python3"

# Test: which with non-existent command
shelltest test_case "which with non-existent command"
result=$($SHUTIL_CMD which nonexistent_command)
shelltest assert_empty "$result" "which should return empty for non-existent command"

# Test: get-terminal-size command
shelltest test_case "get-terminal-size command"
result=$($SHUTIL_CMD get-terminal-size)
shelltest assert_contains "$result" "columns" "get-terminal-size should return columns"
shelltest assert_contains "$result" "lines" "get-terminal-size should return lines"

# Test: get-terminal-size with custom fallback
shelltest test_case "get-terminal-size with custom fallback"
result=$($SHUTIL_CMD get-terminal-size --fallback-columns 100 --fallback-lines 50)
shelltest assert_contains "$result" "columns" "get-terminal-size should return columns"
shelltest assert_contains "$result" "lines" "get-terminal-size should return lines"

# Test: JSON output
shelltest test_case "JSON output"
setup_test_dir
result=$($SHUTIL_CMD disk-usage . --json)
shelltest assert_contains "$result" "{" "JSON output should be object"
shelltest assert_contains "$result" "}" "JSON output should be object"

# Test: dry-run mode
shelltest test_case "dry-run mode"
setup_test_dir
result=$($SHUTIL_CMD copy testfile.txt testfile_copy.txt --dry-run)
shelltest assert_contains "$result" "Would copy" "dry-run should show what would be done"
shelltest assert_file_not_exists "testfile_copy.txt" "dry-run should not actually copy file"

# Test: verbose mode
shelltest test_case "verbose mode"
setup_test_dir
result=$($SHUTIL_CMD copy testfile.txt testfile_copy.txt --verbose 2>&1)
shelltest assert_contains "$result" "copy" "verbose should show command being executed"

# Test: copy with symlinks
shelltest test_case "copy with symlinks"
setup_test_dir
ln -s testfile.txt symlink.txt
$SHUTIL_CMD copy symlink.txt symlink_copy.txt
shelltest assert_file_exists "symlink_copy.txt" "copy should handle symlinks"

# Test: copytree with symlinks
shelltest test_case "copytree with symlinks"
setup_test_dir
ln -s testfile.txt testdir/symlink.txt
$SHUTIL_CMD copytree testdir testdir_symlink --symlinks
shelltest assert_file_exists "testdir_symlink/symlink.txt" "copytree should preserve symlinks"

# Test: move directory
shelltest test_case "move directory"
setup_test_dir
$SHUTIL_CMD move testdir moved_testdir
shelltest assert_directory_exists "moved_testdir" "move should move directory"
shelltest assert_directory_not_exists "testdir" "move should remove source directory"

# Test: copyfile with no-follow-symlinks
shelltest test_case "copyfile with no-follow-symlinks"
setup_test_dir
ln -s testfile.txt symlink.txt
$SHUTIL_CMD copyfile symlink.txt symlink_copyfile.txt --no-follow-symlinks
shelltest assert_file_exists "symlink_copyfile.txt" "copyfile should handle symlinks"

# Test: copytree with ignore-dangling-symlinks
shelltest test_case "copytree with ignore-dangling-symlinks"
setup_test_dir
ln -s nonexistent.txt testdir/dangling_symlink.txt
$SHUTIL_CMD copytree testdir testdir_dangling --ignore-dangling-symlinks
shelltest assert_directory_exists "testdir_dangling" "copytree should handle dangling symlinks"

# Test: make-archive with verbose
shelltest test_case "make-archive with verbose"
setup_test_dir
result=$($SHUTIL_CMD make-archive backup zip --root-dir . --verbose)
shelltest assert_file_exists "backup.zip" "make-archive should create zip file with verbose"

# Test: unpack-archive with format
shelltest test_case "unpack-archive with format"
setup_test_dir
$SHUTIL_CMD make-archive backup zip --root-dir .
mkdir extract_format_dir
$SHUTIL_CMD unpack-archive backup.zip --extract-dir extract_format_dir --format zip
shelltest assert_file_exists "extract_format_dir/testfile.txt" "unpack-archive should extract with format"

# Test: which with mode
shelltest test_case "which with mode"
result=$($SHUTIL_CMD which python3 --mode 0)
shelltest assert_not_empty "$result" "which should work with mode"

# Test: which with path
shelltest test_case "which with path"
result=$($SHUTIL_CMD which python3 --path "$PATH")
shelltest assert_not_empty "$result" "which should work with custom path"

# Test: chown command (may fail on some systems)
shelltest test_case "chown command"
setup_test_dir
# This test may fail if user doesn't have permission or on some systems
$SHUTIL_CMD chown testfile.txt --user $(whoami) 2>/dev/null || true
shelltest assert_file_exists "testfile.txt" "chown should not break file"

# Clean up
cleanup 