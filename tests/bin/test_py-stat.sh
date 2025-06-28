#!/bin/bash

# Tests for py-stat.py
# Comprehensive test coverage for the Stat CLI wrapper

shelltest test_suite "py-stat"

# Set up test environment
STAT_CMD="py-stat"

# Create test files and directories
TEST_FILE="test_file.txt"
TEST_DIR="test_dir"
echo "test content" > "$TEST_FILE"
mkdir -p "$TEST_DIR"
chmod 644 "$TEST_FILE"
chmod 755 "$TEST_DIR"

# Test: py-stat command exists and shows help
shelltest test_case "py-stat command exists and shows help"
shelltest assert_command_exists "$STAT_CMD" "py-stat command should be available"
output=$($STAT_CMD --help 2>&1)
shelltest assert_contains "$output" "Stat CLI" "help should show Stat CLI description"

# Test: s-isdir command
shelltest test_case "s-isdir command"
mode=16877  # Directory mode
result=$($STAT_CMD s-isdir "$mode")
shelltest assert_equal "$result" "True" "s-isdir should return True for directory mode"

# Test: s-isreg command
shelltest test_case "s-isreg command"
mode=33188  # Regular file mode
result=$($STAT_CMD s-isreg "$mode")
shelltest assert_equal "$result" "True" "s-isreg should return True for regular file mode"

# Test: s-islnk command
shelltest test_case "s-islnk command"
mode=41471  # Symbolic link mode
result=$($STAT_CMD s-islnk "$mode")
shelltest assert_equal "$result" "True" "s-islnk should return True for symbolic link mode"

# Test: s-imode command
shelltest test_case "s-imode command"
mode=16877
result=$($STAT_CMD s-imode "$mode")
shelltest assert_equal "$result" "493" "s-imode should return permission bits"

# Test: s-ifmt command
shelltest test_case "s-ifmt command"
mode=16877
result=$($STAT_CMD s-ifmt "$mode")
shelltest assert_equal "$result" "16384" "s-ifmt should return file type bits"

# Test: filemode command
shelltest test_case "filemode command"
mode=16877
result=$($STAT_CMD filemode "$mode")
shelltest assert_contains "$result" "drwx" "filemode should return readable mode string"

# Test: s-ischr command
shelltest test_case "s-ischr command"
mode=8630  # Character device mode
result=$($STAT_CMD s-ischr "$mode")
shelltest assert_equal "$result" "True" "s-ischr should return True for character device mode"

# Test: s-isblk command
shelltest test_case "s-isblk command"
mode=24908  # Block device mode
result=$($STAT_CMD s-isblk "$mode")
shelltest assert_equal "$result" "True" "s-isblk should return True for block device mode"

# Test: s-isfifo command
shelltest test_case "s-isfifo command"
mode=4510  # FIFO mode
result=$($STAT_CMD s-isfifo "$mode")
shelltest assert_equal "$result" "True" "s-isfifo should return True for FIFO mode"

# Test: s-issock command
shelltest test_case "s-issock command"
mode=4514  # Socket mode
result=$($STAT_CMD s-issock "$mode")
shelltest assert_equal "$result" "True" "s-issock should return True for socket mode"

# Test: stat file command
shelltest test_case "stat file command"
result=$($STAT_CMD stat "$TEST_FILE" --json)
shelltest assert_contains "$result" '"st_mode"' "stat should return mode"
shelltest assert_contains "$result" '"st_size"' "stat should return size"
shelltest assert_contains "$result" '"st_mtime"' "stat should return modification time"

# Test: stat directory command
shelltest test_case "stat directory command"
result=$($STAT_CMD stat "$TEST_DIR" --json)
shelltest assert_contains "$result" '"st_mode"' "stat should return mode for directory"
shelltest assert_contains "$result" '"st_size"' "stat should return size for directory"

# Test: lstat command
shelltest test_case "lstat command"
result=$($STAT_CMD lstat "$TEST_FILE" --json)
shelltest assert_contains "$result" '"st_mode"' "lstat should return mode"
shelltest assert_contains "$result" '"st_size"' "lstat should return size"

# Test: get file size
shelltest test_case "get file size"
result=$($STAT_CMD get-size "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-size should return positive size"

# Test: get file mode
shelltest test_case "get file mode"
result=$($STAT_CMD get-mode "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-mode should return positive mode"

# Test: get file modification time
shelltest test_case "get file modification time"
result=$($STAT_CMD get-mtime "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-mtime should return positive time"

# Test: get file access time
shelltest test_case "get file access time"
result=$($STAT_CMD get-atime "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-atime should return positive time"

# Test: get file creation time
shelltest test_case "get file creation time"
result=$($STAT_CMD get-ctime "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-ctime should return positive time"

# Test: check if file exists
shelltest test_case "check if file exists"
result=$($STAT_CMD exists "$TEST_FILE")
shelltest assert_equal "$result" "True" "exists should return True for existing file"

# Test: check if file doesn't exist
shelltest test_case "check if file doesn't exist"
result=$($STAT_CMD exists "nonexistent_file.txt")
shelltest assert_equal "$result" "False" "exists should return False for non-existing file"

# Test: check if is file
shelltest test_case "check if is file"
result=$($STAT_CMD isfile "$TEST_FILE")
shelltest assert_equal "$result" "True" "isfile should return True for regular file"

# Test: check if is directory
shelltest test_case "check if is directory"
result=$($STAT_CMD isdir "$TEST_DIR")
shelltest assert_equal "$result" "True" "isdir should return True for directory"

# Test: check if is link
shelltest test_case "check if is link"
result=$($STAT_CMD islink "$TEST_FILE")
shelltest assert_equal "$result" "False" "islink should return False for regular file"

# Test: get file permissions
shelltest test_case "get file permissions"
result=$($STAT_CMD get-permissions "$TEST_FILE")
shelltest assert_not_empty "$result" "get-permissions should return permission string"

# Test: get file owner
shelltest test_case "get file owner"
result=$($STAT_CMD get-owner "$TEST_FILE")
shelltest assert_not_empty "$result" "get-owner should return owner information"

# Test: get file group
shelltest test_case "get file group"
result=$($STAT_CMD get-group "$TEST_FILE")
shelltest assert_not_empty "$result" "get-group should return group information"

# Test: get file inode
shelltest test_case "get file inode"
result=$($STAT_CMD get-inode "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-inode should return positive inode number"

# Test: get file device
shelltest test_case "get file device"
result=$($STAT_CMD get-device "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-device should return positive device number"

# Test: get file hard links
shelltest test_case "get file hard links"
result=$($STAT_CMD get-nlink "$TEST_FILE")
shelltest assert_greater_than "0" "$result" "get-nlink should return positive link count"

# Test: get file uid
shelltest test_case "get file uid"
result=$($STAT_CMD get-uid "$TEST_FILE")
shelltest assert_greater_than_or_equal "0" "$result" "get-uid should return non-negative uid"

# Test: get file gid
shelltest test_case "get file gid"
result=$($STAT_CMD get-gid "$TEST_FILE")
shelltest assert_greater_than_or_equal "0" "$result" "get-gid should return non-negative gid"

# Test: format file time
shelltest test_case "format file time"
timestamp=$(date +%s)
result=$($STAT_CMD format-time "$timestamp" "%Y-%m-%d")
shelltest assert_not_empty "$result" "format-time should return formatted time string"

# Test: get file age
shelltest test_case "get file age"
result=$($STAT_CMD get-age "$TEST_FILE")
shelltest assert_greater_than_or_equal "0" "$result" "get-age should return non-negative age"

# Test: compare file times
shelltest test_case "compare file times"
result=$($STAT_CMD compare-times "$TEST_FILE" "$TEST_DIR")
shelltest assert_not_empty "$result" "compare-times should return comparison result"

# Clean up test files
rm -f "$TEST_FILE"
rm -rf "$TEST_DIR" 