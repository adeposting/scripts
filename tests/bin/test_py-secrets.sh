#!/bin/bash

# Tests for py-secrets.py
# Comprehensive test coverage for the Secrets CLI wrapper

shelltest test_suite "py-secrets"

# Set up test environment
SECRETS_CMD="py-secrets"

# Test: py-secrets command exists and shows help
shelltest test_case "py-secrets command exists and shows help"
shelltest assert_command_exists "$SECRETS_CMD" "py-secrets command should be available"
output=$($SECRETS_CMD --help 2>&1)
shelltest assert_contains "$output" "Secrets CLI" "help should show Secrets CLI description"

# Test: token-bytes command
shelltest test_case "token-bytes command"
result=$($SECRETS_CMD token-bytes 16)
shelltest assert_not_empty "$result" "token-bytes should return hex string"
shelltest assert_equal "${#result}" "32" "token-bytes should return correct length (16 bytes = 32 hex chars)"

# Test: token-hex command
shelltest test_case "token-hex command"
result=$($SECRETS_CMD token-hex 16)
shelltest assert_not_empty "$result" "token-hex should return hex string"
shelltest assert_equal "${#result}" "32" "token-hex should return correct length (16 bytes = 32 hex chars)"

# Test: token-urlsafe command
shelltest test_case "token-urlsafe command"
result=$($SECRETS_CMD token-urlsafe 16)
shelltest assert_not_empty "$result" "token-urlsafe should return URL-safe string"
# Check that it contains only URL-safe characters (A-Z, a-z, 0-9, _, -)
shelltest assert_matches "$result" "^[A-Za-z0-9_-]+$" "token-urlsafe should contain only URL-safe characters"

# Test: choice command
shelltest test_case "choice command"
result=$($SECRETS_CMD choice "apple" "banana" "cherry")
shelltest assert_not_empty "$result" "choice should return one of the options"
# Check that it matches one of the provided options
shelltest assert_matches "$result" "^(apple|banana|cherry)$" "choice should return one of the provided options"

# Test: randbelow command
shelltest test_case "randbelow command"
result=$($SECRETS_CMD randbelow 100)
shelltest assert_not_empty "$result" "randbelow should return a number"
# Check that it contains only digits
shelltest assert_matches "$result" "^[0-9]+$" "randbelow should return a numeric value"
# Check if result is less than 100
shelltest assert_less_than "100" "$result" "randbelow should return value less than 100"

# Test: randbits command
shelltest test_case "randbits command"
result=$($SECRETS_CMD randbits 8)
shelltest assert_not_empty "$result" "randbits should return a number"
# Check that it contains only digits
shelltest assert_matches "$result" "^[0-9]+$" "randbits should return a numeric value"
# Check if result is less than 2^8 = 256
shelltest assert_less_than "256" "$result" "randbits should return value less than 2^8"

# Test: generate-password command
shelltest test_case "generate-password command"
result=$($SECRETS_CMD generate-password --length 12)
shelltest assert_not_empty "$result" "generate-password should return password"
shelltest assert_equal "${#result}" "12" "generate-password should return correct length"

# Test: generate-password without symbols
shelltest test_case "generate-password without symbols"
result=$($SECRETS_CMD generate-password --length 12 --no-symbols)
shelltest assert_not_empty "$result" "generate-password should return password without symbols"
shelltest assert_equal "${#result}" "12" "generate-password should return correct length"
# Check that it doesn't contain punctuation
shelltest assert_not_contains "$result" "[[:punct:]]" "generate-password with --no-symbols should not contain punctuation"

# Test: generate-hex-password command
shelltest test_case "generate-hex-password command"
result=$($SECRETS_CMD generate-hex-password --length 16)
shelltest assert_not_empty "$result" "generate-hex-password should return hex password"
shelltest assert_equal "${#result}" "16" "generate-hex-password should return correct length"
# Check that it contains only hex characters
shelltest assert_matches "$result" "^[0-9a-f]+$" "generate-hex-password should contain only hex characters"

# Test: generate-urlsafe-password command
shelltest test_case "generate-urlsafe-password command"
result=$($SECRETS_CMD generate-urlsafe-password --length 16)
shelltest assert_not_empty "$result" "generate-urlsafe-password should return URL-safe password"
shelltest assert_equal "${#result}" "22" "generate-urlsafe-password should return correct length (16 bytes = ~22 chars)"
# Check that it contains only URL-safe characters (A-Z, a-z, 0-9, _, -)
shelltest assert_matches "$result" "^[A-Za-z0-9_-]+$" "generate-urlsafe-password should contain only URL-safe characters"

# Test: generate-pin command
shelltest test_case "generate-pin command"
result=$($SECRETS_CMD generate-pin --length 6)
shelltest assert_not_empty "$result" "generate-pin should return PIN"
shelltest assert_equal "${#result}" "6" "generate-pin should return correct length"
# Check that it contains only digits
shelltest assert_matches "$result" "^[0-9]+$" "generate-pin should contain only digits"

# Test: compare-digest command - identical strings
shelltest test_case "compare-digest identical strings"
result=$($SECRETS_CMD compare-digest "hello" "hello")
shelltest assert_equal "$result" "True" "compare-digest should return True for identical strings"

# Test: compare-digest command - different strings
shelltest test_case "compare-digest different strings"
result=$($SECRETS_CMD compare-digest "hello" "world")
shelltest assert_equal "$result" "False" "compare-digest should return False for different strings"

# Test: generate-secure-token command
shelltest test_case "generate-secure-token command"
result=$($SECRETS_CMD --json generate-secure-token --type hex --length 16)
shelltest assert_contains "$result" '"token"' "generate-secure-token should return token"
shelltest assert_contains "$result" '"type": "hex"' "generate-secure-token should show type"
shelltest assert_contains "$result" '"length"' "generate-secure-token should include length"
shelltest assert_contains "$result" '"entropy_bits"' "generate-secure-token should include entropy info"

# Test: generate-multiple-tokens command
shelltest test_case "generate-multiple-tokens command"
result=$($SECRETS_CMD --json generate-multiple-tokens --count 3 --type hex --length 8)
shelltest assert_contains "$result" "[" "generate-multiple-tokens should return array"
shelltest assert_contains "$result" "]" "generate-multiple-tokens should return array"

# Count tokens (should be 3)
token_count=$(echo "$result" | grep -o '"[0-9a-f]*"' | wc -l)
shelltest assert_equal "$token_count" "3" "generate-multiple-tokens should return correct count"

# Test: generate-crypto-key command
shelltest test_case "generate-crypto-key command"
result=$($SECRETS_CMD generate-crypto-key --length 32)
shelltest assert_not_empty "$result" "generate-crypto-key should return key"
shelltest assert_equal "${#result}" "64" "generate-crypto-key should return correct length (32 bytes = 64 hex chars)"

# Test: generate-salt command
shelltest test_case "generate-salt command"
result=$($SECRETS_CMD generate-salt --length 16)
shelltest assert_not_empty "$result" "generate-salt should return salt"
shelltest assert_equal "${#result}" "32" "generate-salt should return correct length (16 bytes = 32 hex chars)"

# Test: generate-uuid command
shelltest test_case "generate-uuid command"
result=$($SECRETS_CMD generate-uuid)
shelltest assert_not_empty "$result" "generate-uuid should return UUID"
# Check that it matches UUID format
shelltest assert_matches "$result" "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" "generate-uuid should return valid UUID format"

# Test: generate-api-key command
shelltest test_case "generate-api-key command"
result=$($SECRETS_CMD generate-api-key --prefix "test" --length 16)
shelltest assert_not_empty "$result" "generate-api-key should return API key"
# Check that it starts with the prefix
shelltest assert_matches "$result" "^test_" "generate-api-key should start with prefix"

# Test: generate-api-key with custom prefix
shelltest test_case "generate-api-key with custom prefix"
result=$($SECRETS_CMD generate-api-key --prefix "api" --length 24)
shelltest assert_not_empty "$result" "generate-api-key should return API key with custom prefix"
# Check that it starts with the custom prefix
shelltest assert_matches "$result" "^api_" "generate-api-key should start with custom prefix"

# Test: JSON output
shelltest test_case "JSON output"
result=$($SECRETS_CMD --json token-hex 8)
shelltest assert_contains "$result" '"' "JSON output should be valid JSON"

# Test: dry-run mode
shelltest test_case "dry-run mode"
result=$($SECRETS_CMD --dry-run token-hex 8)
shelltest assert_contains "$result" "Would generate" "dry-run should show what would be done"

# Test: verbose output
shelltest test_case "verbose output"
result=$($SECRETS_CMD --verbose token-hex 8 2>&1)
# Verbose mode should not cause errors
shelltest assert_not_contains "$result" "Error" "verbose mode should not cause errors" 