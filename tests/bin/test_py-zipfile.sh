#!/bin/bash

# Tests for py-zipfile.py
# Comprehensive test coverage for the Zipfile CLI wrapper

shelltest test_suite "py-zipfile"

# Set up test environment
ZIPFILE_CMD="py-zipfile"

# Create test files
TEST_FILE="test_file.txt"
TEST_DIR="test_dir"
echo "test content" > "$TEST_FILE"
mkdir -p "$TEST_DIR"
echo "nested content" > "$TEST_DIR/nested.txt"

# Test: py-zipfile command exists and shows help
shelltest test_case "py-zipfile command exists and shows help"
shelltest assert_command_exists "$ZIPFILE_CMD" "py-zipfile command should be available"
output=$($ZIPFILE_CMD --help 2>&1)
shelltest assert_contains "$output" "Zipfile CLI" "help should show Zipfile CLI description"

# Test: create zip archive
shelltest test_case "create zip archive"
archive="test_archive.zip"
result=$($ZIPFILE_CMD create "$archive" "$TEST_FILE" "$TEST_DIR")
shelltest assert_file_exists "$archive" "create should create zip archive"
shelltest assert_not_empty "$result" "create should return success message"

# Test: create zip archive with compression
shelltest test_case "create zip archive with compression"
compressed_archive="test_compressed.zip"
result=$($ZIPFILE_CMD create "$compressed_archive" "$TEST_FILE" --compress-level 9)
shelltest assert_file_exists "$compressed_archive" "create should create compressed zip archive"
shelltest assert_not_empty "$result" "create should return success message"

# Test: list archive contents
shelltest test_case "list archive contents"
result=$($ZIPFILE_CMD list "$archive" --json)
shelltest assert_contains "$result" '"name"' "list should return member names"
shelltest assert_contains "$result" '"size"' "list should return member sizes"
shelltest assert_contains "$result" '"compressed_size"' "list should return compressed sizes"

# Test: extract archive
shelltest test_case "extract archive"
extract_dir="extracted"
mkdir -p "$extract_dir"
result=$($ZIPFILE_CMD extract "$archive" --path "$extract_dir")
shelltest assert_not_empty "$result" "extract should return success message"
shelltest assert_file_exists "$extract_dir/$TEST_FILE" "extract should extract files"
shelltest assert_file_exists "$extract_dir/$TEST_DIR/nested.txt" "extract should extract nested files"

# Test: extract specific member
shelltest test_case "extract specific member"
specific_extract_dir="specific_extracted"
mkdir -p "$specific_extract_dir"
result=$($ZIPFILE_CMD extract "$archive" --path "$specific_extract_dir" --member "$TEST_FILE")
shelltest assert_not_empty "$result" "extract should return success message"
shelltest assert_file_exists "$specific_extract_dir/$TEST_FILE" "extract should extract specific member"

# Test: get archive info
shelltest test_case "get archive info"
result=$($ZIPFILE_CMD info "$archive" --json)
shelltest assert_contains "$result" '"format"' "info should return format information"
shelltest assert_contains "$result" '"compression"' "info should return compression information"
shelltest assert_contains "$result" '"members"' "info should return member count"

# Test: check if archive is valid
shelltest test_case "check if archive is valid"
result=$($ZIPFILE_CMD is-valid "$archive")
shelltest assert_equal "$result" "True" "is-valid should return True for valid archive"

# Test: check if archive is not valid
shelltest test_case "check if archive is not valid"
result=$($ZIPFILE_CMD is-valid "$TEST_FILE")
shelltest assert_equal "$result" "False" "is-valid should return False for non-archive file"

# Test: get archive format
shelltest test_case "get archive format"
result=$($ZIPFILE_CMD get-format "$archive")
shelltest assert_not_empty "$result" "get-format should return format information"

# Test: get archive compression
shelltest test_case "get archive compression"
result=$($ZIPFILE_CMD get-compression "$archive")
shelltest assert_not_empty "$result" "get-compression should return compression information"

# Test: get archive member count
shelltest test_case "get archive member count"
result=$($ZIPFILE_CMD get-member-count "$archive")
shelltest assert_greater_than "0" "$result" "get-member-count should return positive count"

# Test: get archive total size
shelltest test_case "get archive total size"
result=$($ZIPFILE_CMD get-total-size "$archive")
shelltest assert_greater_than "0" "$result" "get-total-size should return positive size"

# Test: get archive uncompressed size
shelltest test_case "get archive uncompressed size"
result=$($ZIPFILE_CMD get-uncompressed-size "$archive")
shelltest assert_greater_than "0" "$result" "get-uncompressed-size should return positive size"

# Test: find member in archive
shelltest test_case "find member in archive"
result=$($ZIPFILE_CMD find-member "$archive" "$TEST_FILE" --json)
shelltest assert_contains "$result" '"found"' "find-member should return search result"
shelltest assert_contains "$result" '"member"' "find-member should return member information"

# Test: find non-existent member
shelltest test_case "find non-existent member"
result=$($ZIPFILE_CMD find-member "$archive" "nonexistent.txt" --json)
shelltest assert_contains "$result" '"found": false' "find-member should return false for non-existent member"

# Test: get member info
shelltest test_case "get member info"
result=$($ZIPFILE_CMD get-member-info "$archive" "$TEST_FILE" --json)
shelltest assert_contains "$result" '"name"' "get-member-info should return member name"
shelltest assert_contains "$result" '"size"' "get-member-info should return member size"
shelltest assert_contains "$result" '"compressed_size"' "get-member-info should return compressed size"

# Test: extract member to string
shelltest test_case "extract member to string"
result=$($ZIPFILE_CMD extract-to-string "$archive" "$TEST_FILE")
shelltest assert_contains "$result" "test content" "extract-to-string should return file content"

# Test: add member to archive
shelltest test_case "add member to archive"
new_file="new_file.txt"
echo "new content" > "$new_file"
result=$($ZIPFILE_CMD add-member "$archive" "$new_file" --arcname "added_file.txt")
shelltest assert_not_empty "$result" "add-member should return success message"

# Test: remove member from archive
shelltest test_case "remove member from archive"
result=$($ZIPFILE_CMD remove-member "$archive" "added_file.txt")
shelltest assert_not_empty "$result" "remove-member should return success message"

# Test: update member in archive
shelltest test_case "update member in archive"
echo "updated content" > "$new_file"
result=$($ZIPFILE_CMD update-member "$archive" "$new_file" --arcname "$TEST_FILE")
shelltest assert_not_empty "$result" "update-member should return success message"

# Test: create archive with exclude pattern
shelltest test_case "create archive with exclude pattern"
exclude_archive="exclude_archive.zip"
result=$($ZIPFILE_CMD create "$exclude_archive" "$TEST_DIR" --exclude "*.txt")
shelltest assert_file_exists "$exclude_archive" "create should create archive with exclusions"

# Test: create archive with include pattern
shelltest test_case "create archive with include pattern"
include_archive="include_archive.zip"
result=$($ZIPFILE_CMD create "$include_archive" "$TEST_DIR" --include "*.txt")
shelltest assert_file_exists "$include_archive" "create should create archive with inclusions"

# Test: create archive with password
shelltest test_case "create archive with password"
password_archive="password_archive.zip"
result=$($ZIPFILE_CMD create "$password_archive" "$TEST_FILE" --password "testpass")
shelltest assert_file_exists "$password_archive" "create should create password-protected archive"

# Test: extract password-protected archive
shelltest test_case "extract password-protected archive"
password_extract_dir="password_extracted"
mkdir -p "$password_extract_dir"
result=$($ZIPFILE_CMD extract "$password_archive" --path "$password_extract_dir" --password "testpass")
shelltest assert_not_empty "$result" "extract should handle password-protected archive"

# Test: create archive with comment
shelltest test_case "create archive with comment"
comment_archive="comment_archive.zip"
result=$($ZIPFILE_CMD create "$comment_archive" "$TEST_FILE" --comment "Test archive")
shelltest assert_file_exists "$comment_archive" "create should create archive with comment"

# Test: get archive comment
shelltest test_case "get archive comment"
result=$($ZIPFILE_CMD get-comment "$comment_archive")
shelltest assert_contains "$result" "Test archive" "get-comment should return archive comment"

# Test: set archive comment
shelltest test_case "set archive comment"
result=$($ZIPFILE_CMD set-comment "$archive" "New comment")
shelltest assert_not_empty "$result" "set-comment should return success message"

# Test: test archive integrity
shelltest test_case "test archive integrity"
result=$($ZIPFILE_CMD test "$archive")
shelltest assert_contains "$result" "OK\|True" "test should return OK or True for valid archive"

# Test: get archive compression ratio
shelltest test_case "get archive compression ratio"
result=$($ZIPFILE_CMD get-compression-ratio "$archive")
shelltest assert_not_empty "$result" "get-compression-ratio should return compression ratio"

# Test: get archive space savings
shelltest test_case "get archive space savings"
result=$($ZIPFILE_CMD get-space-savings "$archive")
shelltest assert_not_empty "$result" "get-space-savings should return space savings"

# Test: create archive with different compression methods
shelltest test_case "create archive with store method"
store_archive="store_archive.zip"
result=$($ZIPFILE_CMD create "$store_archive" "$TEST_FILE" --method store)
shelltest assert_file_exists "$store_archive" "create should create archive with store method"

# Test: create archive with deflate method
shelltest test_case "create archive with deflate method"
deflate_archive="deflate_archive.zip"
result=$($ZIPFILE_CMD create "$deflate_archive" "$TEST_FILE" --method deflate)
shelltest assert_file_exists "$deflate_archive" "create should create archive with deflate method"

# Test: create archive with bzip2 method
shelltest test_case "create archive with bzip2 method"
bzip2_archive="bzip2_archive.zip"
result=$($ZIPFILE_CMD create "$bzip2_archive" "$TEST_FILE" --method bzip2)
shelltest assert_file_exists "$bzip2_archive" "create should create archive with bzip2 method"

# Test: create archive with lzma method
shelltest test_case "create archive with lzma method"
lzma_archive="lzma_archive.zip"
result=$($ZIPFILE_CMD create "$lzma_archive" "$TEST_FILE" --method lzma)
shelltest assert_file_exists "$lzma_archive" "create should create archive with lzma method"

# Test: get member compression method
shelltest test_case "get member compression method"
result=$($ZIPFILE_CMD get-member-method "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-method should return compression method"

# Test: get member CRC
shelltest test_case "get member CRC"
result=$($ZIPFILE_CMD get-member-crc "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-crc should return CRC value"

# Test: get member comment
shelltest test_case "get member comment"
result=$($ZIPFILE_CMD get-member-comment "$archive" "$TEST_FILE")
# May be empty, but should not error
shelltest assert_not_contains "$result" "Error" "get-member-comment should not error"

# Test: set member comment
shelltest test_case "set member comment"
result=$($ZIPFILE_CMD set-member-comment "$archive" "$TEST_FILE" "Test member comment")
shelltest assert_not_empty "$result" "set-member-comment should return success message"

# Test: get member external attributes
shelltest test_case "get member external attributes"
result=$($ZIPFILE_CMD get-member-external-attr "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-external-attr should return external attributes"

# Test: get member internal attributes
shelltest test_case "get member internal attributes"
result=$($ZIPFILE_CMD get-member-internal-attr "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-internal-attr should return internal attributes"

# Test: get member flags
shelltest test_case "get member flags"
result=$($ZIPFILE_CMD get-member-flags "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-flags should return member flags"

# Test: get member version
shelltest test_case "get member version"
result=$($ZIPFILE_CMD get-member-version "$archive" "$TEST_FILE")
shelltest assert_not_empty "$result" "get-member-version should return member version"

# Test: get member date time
shelltest test_case "get member date time"
result=$($ZIPFILE_CMD get-member-datetime "$archive" "$TEST_FILE" --json)
shelltest assert_contains "$result" '"year"' "get-member-datetime should return year"
shelltest assert_contains "$result" '"month"' "get-member-datetime should return month"
shelltest assert_contains "$result" '"day"' "get-member-datetime should return day"

# Clean up test files
rm -f "$TEST_FILE" "$new_file"
rm -rf "$TEST_DIR" "$extract_dir" "$specific_extract_dir" "$password_extract_dir"
rm -f "$archive" "$compressed_archive" "$exclude_archive" "$include_archive" "$password_archive" "$comment_archive"
rm -f "$store_archive" "$deflate_archive" "$bzip2_archive" "$lzma_archive" 