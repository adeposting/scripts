#!/bin/bash

# Tests for py-tarfile.py
# Comprehensive test coverage for the Tarfile CLI wrapper

shelltest test_suite "py-tarfile"

# Set up test environment
TARFILE_CMD="py-tarfile"

# Create test files
TEST_FILE="test_file.txt"
TEST_DIR="test_dir"
echo "test content" > "$TEST_FILE"
mkdir -p "$TEST_DIR"
echo "nested content" > "$TEST_DIR/nested.txt"

# Test: py-tarfile command exists and shows help
shelltest test_case "py-tarfile command exists and shows help"
shelltest assert_command_exists "$TARFILE_CMD" "py-tarfile command should be available"
output=$($TARFILE_CMD --help 2>&1)
shelltest assert_contains "$output" "Tarfile CLI" "help should show Tarfile CLI description"

# Test: create tar archive
shelltest test_case "create tar archive"
archive="test_archive.tar"
result=$($TARFILE_CMD create "$archive" "$TEST_FILE" "$TEST_DIR")
shelltest assert_file_exists "$archive" "create should create tar archive"
shelltest assert_not_empty "$result" "create should return success message"

# Test: create gzipped tar archive
shelltest test_case "create gzipped tar archive"
gzip_archive="test_archive.tar.gz"
result=$($TARFILE_CMD create "$gzip_archive" "$TEST_FILE" --compress gzip)
shelltest assert_file_exists "$gzip_archive" "create should create gzipped tar archive"
shelltest assert_not_empty "$result" "create should return success message"

# Test: create bzipped tar archive
shelltest test_case "create bzipped tar archive"
bzip_archive="test_archive.tar.bz2"
result=$($TARFILE_CMD create "$bzip_archive" "$TEST_FILE" --compress bzip2)
shelltest assert_file_exists "$bzip_archive" "create should create bzipped tar archive"
shelltest assert_not_empty "$result" "create should return success message"

# Test: list archive contents
shelltest test_case "list archive contents"
result=$($TARFILE_CMD list "$archive" --json)
shelltest assert_contains "$result" '"name"' "list should return member names"
shelltest assert_contains "$result" '"size"' "list should return member sizes"
shelltest assert_contains "$result" '"mtime"' "list should return modification times"

# Test: extract archive
shelltest test_case "extract archive"
extract_dir="extracted"
mkdir -p "$extract_dir"
result=$($TARFILE_CMD extract "$archive" --path "$extract_dir")
shelltest assert_not_empty "$result" "extract should return success message"
shelltest assert_file_exists "$extract_dir/$TEST_FILE" "extract should extract files"
shelltest assert_file_exists "$extract_dir/$TEST_DIR/nested.txt" "extract should extract nested files"

# Test: extract specific member
shelltest test_case "extract specific member"
specific_extract_dir="specific_extracted"
mkdir -p "$specific_extract_dir"
result=$($TARFILE_CMD extract "$archive" --path "$specific_extract_dir" --member "$TEST_FILE")
shelltest assert_not_empty "$result" "extract should return success message"
shelltest assert_file_exists "$specific_extract_dir/$TEST_FILE" "extract should extract specific member"

# Test: get archive info
shelltest test_case "get archive info"
result=$($TARFILE_CMD info "$archive" --json)
shelltest assert_contains "$result" '"format"' "info should return format information"
shelltest assert_contains "$result" '"compression"' "info should return compression information"
shelltest assert_contains "$result" '"members"' "info should return member count"

# Test: check if archive is valid
shelltest test_case "check if archive is valid"
result=$($TARFILE_CMD is-valid "$archive")
shelltest assert_equal "$result" "True" "is-valid should return True for valid archive"

# Test: check if archive is not valid
shelltest test_case "check if archive is not valid"
result=$($TARFILE_CMD is-valid "$TEST_FILE")
shelltest assert_equal "$result" "False" "is-valid should return False for non-archive file"

# Test: get archive format
shelltest test_case "get archive format"
result=$($TARFILE_CMD get-format "$archive")
shelltest assert_not_empty "$result" "get-format should return format information"

# Test: get archive compression
shelltest test_case "get archive compression"
result=$($TARFILE_CMD get-compression "$archive")
shelltest assert_not_empty "$result" "get-compression should return compression information"

# Test: get archive member count
shelltest test_case "get archive member count"
result=$($TARFILE_CMD get-member-count "$archive")
shelltest assert_greater_than "0" "$result" "get-member-count should return positive count"

# Test: get archive total size
shelltest test_case "get archive total size"
result=$($TARFILE_CMD get-total-size "$archive")
shelltest assert_greater_than "0" "$result" "get-total-size should return positive size"

# Test: get archive uncompressed size
shelltest test_case "get archive uncompressed size"
result=$($TARFILE_CMD get-uncompressed-size "$archive")
shelltest assert_greater_than "0" "$result" "get-uncompressed-size should return positive size"

# Test: find member in archive
shelltest test_case "find member in archive"
result=$($TARFILE_CMD find-member "$archive" "$TEST_FILE" --json)
shelltest assert_contains "$result" '"found"' "find-member should return search result"
shelltest assert_contains "$result" '"member"' "find-member should return member information"

# Test: find non-existent member
shelltest test_case "find non-existent member"
result=$($TARFILE_CMD find-member "$archive" "nonexistent.txt" --json)
shelltest assert_contains "$result" '"found": false' "find-member should return false for non-existent member"

# Test: get member info
shelltest test_case "get member info"
result=$($TARFILE_CMD get-member-info "$archive" "$TEST_FILE" --json)
shelltest assert_contains "$result" '"name"' "get-member-info should return member name"
shelltest assert_contains "$result" '"size"' "get-member-info should return member size"
shelltest assert_contains "$result" '"mtime"' "get-member-info should return modification time"

# Test: extract member to string
shelltest test_case "extract member to string"
result=$($TARFILE_CMD extract-to-string "$archive" "$TEST_FILE")
shelltest assert_contains "$result" "test content" "extract-to-string should return file content"

# Test: add member to archive
shelltest test_case "add member to archive"
new_file="new_file.txt"
echo "new content" > "$new_file"
result=$($TARFILE_CMD add-member "$archive" "$new_file" --arcname "added_file.txt")
shelltest assert_not_empty "$result" "add-member should return success message"

# Test: remove member from archive
shelltest test_case "remove member from archive"
result=$($TARFILE_CMD remove-member "$archive" "added_file.txt")
shelltest assert_not_empty "$result" "remove-member should return success message"

# Test: update member in archive
shelltest test_case "update member in archive"
echo "updated content" > "$new_file"
result=$($TARFILE_CMD update-member "$archive" "$new_file" --arcname "$TEST_FILE")
shelltest assert_not_empty "$result" "update-member should return success message"

# Test: create archive with exclude pattern
shelltest test_case "create archive with exclude pattern"
exclude_archive="exclude_archive.tar"
result=$($TARFILE_CMD create "$exclude_archive" "$TEST_DIR" --exclude "*.txt")
shelltest assert_file_exists "$exclude_archive" "create should create archive with exclusions"

# Test: create archive with include pattern
shelltest test_case "create archive with include pattern"
include_archive="include_archive.tar"
result=$($TARFILE_CMD create "$include_archive" "$TEST_DIR" --include "*.txt")
shelltest assert_file_exists "$include_archive" "create should create archive with inclusions"

# Test: create archive with owner mapping
shelltest test_case "create archive with owner mapping"
owner_archive="owner_archive.tar"
result=$($TARFILE_CMD create "$owner_archive" "$TEST_FILE" --owner "testuser")
shelltest assert_file_exists "$owner_archive" "create should create archive with owner mapping"

# Test: create archive with group mapping
shelltest test_case "create archive with group mapping"
group_archive="group_archive.tar"
result=$($TARFILE_CMD create "$group_archive" "$TEST_FILE" --group "testgroup")
shelltest assert_file_exists "$group_archive" "create should create archive with group mapping"

# Test: create archive with numeric owner
shelltest test_case "create archive with numeric owner"
numeric_owner_archive="numeric_owner_archive.tar"
result=$($TARFILE_CMD create "$numeric_owner_archive" "$TEST_FILE" --numeric-owner)
shelltest assert_file_exists "$numeric_owner_archive" "create should create archive with numeric owner"

# Test: extract with preserve permissions
shelltest test_case "extract with preserve permissions"
preserve_dir="preserve_extracted"
mkdir -p "$preserve_dir"
result=$($TARFILE_CMD extract "$archive" --path "$preserve_dir" --preserve-permissions)
shelltest assert_not_empty "$result" "extract should preserve permissions"

# Test: extract with preserve ownership
shelltest test_case "extract with preserve ownership"
ownership_dir="ownership_extracted"
mkdir -p "$ownership_dir"
result=$($TARFILE_CMD extract "$archive" --path "$ownership_dir" --preserve-ownership)
shelltest assert_not_empty "$result" "extract should preserve ownership"

# Test: extract with numeric owner
shelltest test_case "extract with numeric owner"
numeric_dir="numeric_extracted"
mkdir -p "$numeric_dir"
result=$($TARFILE_CMD extract "$archive" --path "$numeric_dir" --numeric-owner)
shelltest assert_not_empty "$result" "extract should use numeric owner"

# Clean up test files
rm -f "$TEST_FILE" "$new_file"
rm -rf "$TEST_DIR" "$extract_dir" "$specific_extract_dir" "$preserve_dir" "$ownership_dir" "$numeric_dir"
rm -f "$archive" "$gzip_archive" "$bzip_archive" "$exclude_archive" "$include_archive" "$owner_archive" "$group_archive" "$numeric_owner_archive" 