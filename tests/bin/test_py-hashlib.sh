#!/bin/bash

# Tests for py-hashlib.py
# Comprehensive test coverage for the Hashlib CLI wrapper

shelltest test_suite "py-hashlib"

# Set up test environment
HASHLIB_CMD="py-hashlib"

# Create test data
TEST_FILE="test_file.txt"
TEST_DATA="hello world"

# Create test file
echo "$TEST_DATA" > "$TEST_FILE"

# Test: py-hashlib command exists and shows help
shelltest test_case "py-hashlib command exists and shows help"
shelltest assert_command_exists "$HASHLIB_CMD" "py-hashlib command should be available"
output=$($HASHLIB_CMD --help 2>&1)
shelltest assert_contains "$output" "Hashlib CLI" "help should show Hashlib CLI description"

# Test: md5 command
shelltest test_case "md5 command"
result=$($HASHLIB_CMD md5 "$TEST_DATA")
shelltest assert_not_empty "$result" "md5 should return hash"
shelltest assert_equal "$result" "5eb63bbbe01eeed093cb22bb8f5acdc3" "md5 should return correct hash for 'hello world'"

# Test: sha1 command
shelltest test_case "sha1 command"
result=$($HASHLIB_CMD sha1 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha1 should return hash"
shelltest assert_equal "$result" "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed" "sha1 should return correct hash for 'hello world'"

# Test: sha256 command
shelltest test_case "sha256 command"
result=$($HASHLIB_CMD sha256 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha256 should return hash"
shelltest assert_equal "$result" "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9" "sha256 should return correct hash for 'hello world'"

# Test: sha512 command
shelltest test_case "sha512 command"
result=$($HASHLIB_CMD sha512 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha512 should return hash"
shelltest assert_contains "$result" "309ecc489c12d6eb4cc40f50c902f2b4d0ed77ee511a7c7a9bcd3ca86d4cd86f989dd35bc5ff499670da34255b45b0cfd830e81f605dcf7dc5542e93ae9cd76f" "sha512 should return correct hash for 'hello world'"

# Test: sha224 command
shelltest test_case "sha224 command"
result=$($HASHLIB_CMD sha224 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha224 should return hash"
shelltest assert_equal "$result" "2f05477fc24bb4faefd86517156dafdecec45b8ad3cf2522a563582b" "sha224 should return correct hash for 'hello world'"

# Test: sha384 command
shelltest test_case "sha384 command"
result=$($HASHLIB_CMD sha384 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha384 should return hash"
shelltest assert_contains "$result" "fdbd8e75a67f29f701a4e040385e2e23986303ea10239211af907fcbb83578b3e417cb71ce646efd0819dd8c088de1bd" "sha384 should return correct hash for 'hello world'"

# Test: sha3-224 command
shelltest test_case "sha3-224 command"
result=$($HASHLIB_CMD sha3-224 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha3-224 should return hash"

# Test: sha3-256 command
shelltest test_case "sha3-256 command"
result=$($HASHLIB_CMD sha3-256 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha3-256 should return hash"

# Test: sha3-384 command
shelltest test_case "sha3-384 command"
result=$($HASHLIB_CMD sha3-384 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha3-384 should return hash"

# Test: sha3-512 command
shelltest test_case "sha3-512 command"
result=$($HASHLIB_CMD sha3-512 "$TEST_DATA")
shelltest assert_not_empty "$result" "sha3-512 should return hash"

# Test: blake2b command
shelltest test_case "blake2b command"
result=$($HASHLIB_CMD blake2b "$TEST_DATA")
shelltest assert_not_empty "$result" "blake2b should return hash"

# Test: blake2b with custom digest size
shelltest test_case "blake2b with custom digest size"
result=$($HASHLIB_CMD blake2b "$TEST_DATA" --digest-size 32)
shelltest assert_not_empty "$result" "blake2b should work with custom digest size"

# Test: blake2s command
shelltest test_case "blake2s command"
result=$($HASHLIB_CMD blake2s "$TEST_DATA")
shelltest assert_not_empty "$result" "blake2s should return hash"

# Test: blake2s with custom digest size
shelltest test_case "blake2s with custom digest size"
result=$($HASHLIB_CMD blake2s "$TEST_DATA" --digest-size 16)
shelltest assert_not_empty "$result" "blake2s should work with custom digest size"

# Test: shake-128 command
shelltest test_case "shake-128 command"
result=$($HASHLIB_CMD shake-128 "$TEST_DATA")
shelltest assert_not_empty "$result" "shake-128 should return hash"

# Test: shake-128 with custom length
shelltest test_case "shake-128 with custom length"
result=$($HASHLIB_CMD shake-128 "$TEST_DATA" --length 32)
shelltest assert_not_empty "$result" "shake-128 should work with custom length"

# Test: shake-256 command
shelltest test_case "shake-256 command"
result=$($HASHLIB_CMD shake-256 "$TEST_DATA")
shelltest assert_not_empty "$result" "shake-256 should return hash"

# Test: shake-256 with custom length
shelltest test_case "shake-256 with custom length"
result=$($HASHLIB_CMD shake-256 "$TEST_DATA" --length 64)
shelltest assert_not_empty "$result" "shake-256 should work with custom length"

# Test: file-hash command
shelltest test_case "file-hash command"
result=$($HASHLIB_CMD file-hash "$TEST_FILE" --algorithm sha256 --json)
shelltest assert_contains "$result" '"filename"' "file-hash should return file info"
shelltest assert_contains "$result" '"algorithm": "sha256"' "file-hash should show algorithm"
shelltest assert_contains "$result" '"hash"' "file-hash should include hash"
shelltest assert_contains "$result" '"size"' "file-hash should include size"

# Test: hash-file-md5 command
shelltest test_case "hash-file-md5 command"
result=$($HASHLIB_CMD hash-file-md5 "$TEST_FILE")
shelltest assert_not_empty "$result" "hash-file-md5 should return hash"

# Test: hash-file-sha1 command
shelltest test_case "hash-file-sha1 command"
result=$($HASHLIB_CMD hash-file-sha1 "$TEST_FILE")
shelltest assert_not_empty "$result" "hash-file-sha1 should return hash"

# Test: hash-file-sha256 command
shelltest test_case "hash-file-sha256 command"
result=$($HASHLIB_CMD hash-file-sha256 "$TEST_FILE")
shelltest assert_not_empty "$result" "hash-file-sha256 should return hash"

# Test: hash-file-sha512 command
shelltest test_case "hash-file-sha512 command"
result=$($HASHLIB_CMD hash-file-sha512 "$TEST_FILE")
shelltest assert_not_empty "$result" "hash-file-sha512 should return hash"

# Test: hash-all command
shelltest test_case "hash-all command"
result=$($HASHLIB_CMD hash-all "$TEST_DATA" --json)
shelltest assert_contains "$result" '"md5"' "hash-all should include md5"
shelltest assert_contains "$result" '"sha1"' "hash-all should include sha1"
shelltest assert_contains "$result" '"sha256"' "hash-all should include sha256"
shelltest assert_contains "$result" '"sha512"' "hash-all should include sha512"

# Test: get-available-algorithms command
shelltest test_case "get-available-algorithms command"
result=$($HASHLIB_CMD get-available-algorithms --json)
shelltest assert_contains "$result" "md5" "get-available-algorithms should include md5"
shelltest assert_contains "$result" "sha1" "get-available-algorithms should include sha1"
shelltest assert_contains "$result" "sha256" "get-available-algorithms should include sha256"

# Test: pbkdf2-hmac command
shelltest test_case "pbkdf2-hmac command"
result=$($HASHLIB_CMD pbkdf2-hmac "password" "salt" --iterations 1000 --algorithm sha256)
shelltest assert_not_empty "$result" "pbkdf2-hmac should return hash"

# Test: pbkdf2-hmac with custom dklen
shelltest test_case "pbkdf2-hmac with custom dklen"
result=$($HASHLIB_CMD pbkdf2-hmac "password" "salt" --iterations 1000 --algorithm sha256 --dklen 64)
shelltest assert_not_empty "$result" "pbkdf2-hmac should work with custom dklen"

# Clean up test file
rm -f "$TEST_FILE" 