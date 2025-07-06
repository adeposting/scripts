#!/bin/bash

# Tests for py-base64.py
# Comprehensive test coverage for the py-base64 utility

shelltest test_suite "py-base64"

# Test: py-base64 command exists
shelltest test_case "py-base64 command exists"
shelltest assert_command_exists "py-base64" "py-base64 command should be available"

# Test: py-base64 help command
shelltest test_case "py-base64 help command"
output=$(py-base64 --help 2>&1)
shelltest assert_contains "$output" "py-base64" "help should show script name"
shelltest assert_contains "$output" "usage:" "help should show usage information"

# Test: b64encode command
shelltest test_case "b64encode command"
result=$(py-base64 b64encode "Hello, World!")
shelltest assert_equal "SGVsbG8sIFdvcmxkIQ==" "$result" "b64encode command should return correct base64"

# Test: b64decode command
shelltest test_case "b64decode command"
result=$(py-base64 b64decode "SGVsbG8sIFdvcmxkIQ==")
shelltest assert_equal "Hello, World!" "$result" "b64decode command should return correct string"

# Test: b32encode command
shelltest test_case "b32encode command"
result=$(py-base64 b32encode "Hello, World!")
shelltest assert_equal "JBSWY3DPFQQFO33SNRSCC===" "$result" "b32encode command should return correct base32"

# Test: b32decode command
shelltest test_case "b32decode command"
result=$(py-base64 b32decode "JBSWY3DPFQQFO33SNRSCC===")
shelltest assert_equal "Hello, World!" "$result" "b32decode command should return correct string"

# Test: b16encode command
shelltest test_case "b16encode command"
result=$(py-base64 b16encode "Hello, World!")
shelltest assert_equal "48656C6C6F2C20576F726C6421" "$result" "b16encode command should return correct base16"

# Test: b16decode command
shelltest test_case "b16decode command"
result=$(py-base64 b16decode "48656C6C6F2C20576F726C6421")
shelltest assert_equal "Hello, World!" "$result" "b16decode command should return correct string"

# Test: urlsafe-b64encode command
shelltest test_case "urlsafe-b64encode command"
result=$(py-base64 urlsafe-b64encode "Hello, World!")
shelltest assert_equal "SGVsbG8sIFdvcmxkIQ==" "$result" "urlsafe-b64encode command should return correct base64"

# Test: urlsafe-b64decode command
shelltest test_case "urlsafe-b64decode command"
result=$(py-base64 urlsafe-b64decode "SGVsbG8sIFdvcmxkIQ==")
shelltest assert_equal "Hello, World!" "$result" "urlsafe-b64decode command should return correct string"

# Test: encode-file command
shelltest test_case "encode-file command"
echo -n "Hello, World!" > test.txt
result=$(py-base64 encode-file test.txt --encoding b64)
shelltest assert_equal "SGVsbG8sIFdvcmxkIQ==" "$result" "encode-file command should return correct base64"

# Test: decode-file command
shelltest test_case "decode-file command"
echo "SGVsbG8sIFdvcmxkIQ==" > encoded.txt
result=$(py-base64 decode-file encoded.txt --encoding b64)
shelltest assert_equal "Hello, World!" "$result" "decode-file command should return correct string"

# Test: encode-file with b32 encoding
shelltest test_case "encode-file command with b32 encoding"
echo -n "Hello, World!" > test.txt
result=$(py-base64 encode-file test.txt --encoding b32)
shelltest assert_equal "JBSWY3DPFQQFO33SNRSCC===" "$result" "encode-file command with b32 should return correct base32"

# Test: decode-file with b32 encoding
shelltest test_case "decode-file command with b32 encoding"
echo "JBSWY3DPFQQFO33SNRSCC===" > encoded.txt
result=$(py-base64 decode-file encoded.txt --encoding b32)
shelltest assert_equal "Hello, World!" "$result" "decode-file command with b32 should return correct string"

# Test: encode-file with b16 encoding
shelltest test_case "encode-file command with b16 encoding"
echo -n "Hello, World!" > test.txt
result=$(py-base64 encode-file test.txt --encoding b16)
shelltest assert_equal "48656C6C6F2C20576F726C6421" "$result" "encode-file command with b16 should return correct base16"

# Test: decode-file with b16 encoding
shelltest test_case "decode-file command with b16 encoding"
echo "48656C6C6F2C20576F726C6421" > encoded.txt
result=$(py-base64 decode-file encoded.txt --encoding b16)
shelltest assert_equal "Hello, World!" "$result" "decode-file command with b16 should return correct string"

# Test: encode-file with urlsafe encoding
shelltest test_case "encode-file command with urlsafe encoding"
echo -n "Hello, World!" > test.txt
result=$(py-base64 encode-file test.txt --encoding urlsafe)
shelltest assert_equal "SGVsbG8sIFdvcmxkIQ==" "$result" "encode-file command with urlsafe should return correct base64"

# Test: decode-file with urlsafe encoding
shelltest test_case "decode-file command with urlsafe encoding"
echo "SGVsbG8sIFdvcmxkIQ==" > encoded.txt
result=$(py-base64 decode-file encoded.txt --encoding urlsafe)
shelltest assert_equal "Hello, World!" "$result" "decode-file command with urlsafe should return correct string"

# Test: encode-file with dry run
shelltest test_case "encode-file command with dry run"
echo -n "Hello, World!" > test.txt
result=$(py-base64 --dry-run encode-file test.txt --encoding b64)
shelltest assert_contains "$result" "Would encode file: test.txt using b64" "dry run should show what would be done"

# Test: decode-file with dry run
shelltest test_case "decode-file command with dry run"
echo "SGVsbG8sIFdvcmxkIQ==" > encoded.txt
result=$(py-base64 --dry-run decode-file encoded.txt --encoding b64)
shelltest assert_contains "$result" "Would decode file: encoded.txt using b64" "dry run should show what would be done"

# Test: Error handling for non-existent file
shelltest test_case "error handling for non-existent file in encode-file"
output=$(py-base64 encode-file nonexistent.txt --encoding b64 2>&1)
shelltest assert_contains "$output" "Error" "should show error for non-existent file"

# Test: Error handling for non-existent file in decode-file
shelltest test_case "error handling for non-existent file in decode-file"
output=$(py-base64 decode-file nonexistent.txt --encoding b64 2>&1)
shelltest assert_contains "$output" "Error" "should show error for non-existent file"

# Test: Error handling for invalid base64
shelltest test_case "error handling for invalid base64 in b64decode"
output=$(py-base64 b64decode "invalid_base64!!!" 2>&1)
shelltest assert_contains "$output" "Error" "should show error for invalid base64"

# Test: Error handling for invalid base32
shelltest test_case "error handling for invalid base32 in b32decode"
output=$(py-base64 b32decode "invalid_base32!!!" 2>&1)
shelltest assert_contains "$output" "Error" "should show error for invalid base32"

# Test: Error handling for invalid base16
shelltest test_case "error handling for invalid base16 in b16decode"
output=$(py-base64 b16decode "invalid_base16!!!" 2>&1)
shelltest assert_contains "$output" "Error" "should show error for invalid base16"

# Test: Binary data encoding
shelltest test_case "b64encode command with binary data"
printf '\x00\x01\x02\x03\x04\x05' > binary.bin
result=$(py-base64 encode-file binary.bin --encoding b64)
shelltest assert_equal "AAECAwQF" "$result" "b64encode command with binary data should return correct base64"

# Test: Binary data decoding
shelltest test_case "b64decode command with binary data"
echo "AAECAwQF" > encoded.bin
result=$(py-base64 decode-file encoded.bin --encoding b64)
# Check that the result contains the expected binary data
shelltest assert_contains "$result" $'\x00\x01\x02\x03\x04\x05' "b64decode command with binary data should return correct binary"

# Test: Empty string encoding
shelltest test_case "b64encode command with empty string"
result=$(py-base64 b64encode "")
shelltest assert_equal "" "$result" "b64encode command with empty string should return empty string"

# Test: Empty string decoding
shelltest test_case "b64decode command with empty string"
result=$(py-base64 b64decode "")
shelltest assert_equal "" "$result" "b64decode command with empty string should return empty string"

# Test: Special characters encoding
shelltest test_case "b64encode command with special characters"
result=$(py-base64 b64encode "Hello\nWorld\tTest")
shelltest assert_equal "SGVsbG8KV29ybGQJVGVzdA==" "$result" "b64encode command with special characters should return correct base64"

# Test: Special characters decoding
shelltest test_case "b64decode command with special characters"
result=$(py-base64 b64decode "SGVsbG8KV29ybGQJVGVzdA==")
shelltest assert_equal "Hello"$'\n'"World"$'\t'"Test" "$result" "b64decode command with special characters should return correct string"

# Clean up test files
rm -f test.txt encoded.txt binary.bin encoded.bin 