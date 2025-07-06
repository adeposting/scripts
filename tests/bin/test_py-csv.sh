#!/bin/bash

# Tests for py-csv.py
# Comprehensive test coverage for the CSV CLI wrapper

shelltest test_suite "py-csv"

# Set up test environment
CSV_CMD="py-csv"

# Create test CSV file
TEST_CSV="test_data.csv"
echo "name,age,city" > "$TEST_CSV"
echo "Alice,30,New York" >> "$TEST_CSV"
echo "Bob,25,Los Angeles" >> "$TEST_CSV"
echo "Charlie,35,Chicago" >> "$TEST_CSV"

# Test: py-csv command exists and shows help
shelltest test_case "py-csv command exists and shows help"
shelltest assert_command_exists "$CSV_CMD" "py-csv command should be available"
output=$($CSV_CMD --help 2>&1)
shelltest assert_contains "$output" "CSV CLI" "help should show CSV CLI description"

# Test: read command
shelltest test_case "read command"
result=$($CSV_CMD --json read "$TEST_CSV")
shelltest assert_contains "$result" '"name"' "read should return column names"
shelltest assert_contains "$result" '"Alice"' "read should return data"
shelltest assert_contains "$result" '"Bob"' "read should return all rows"

# Test: read with specific columns
shelltest test_case "read with specific columns"
result=$($CSV_CMD --json read "$TEST_CSV" --columns name,age)
shelltest assert_contains "$result" '"name"' "read should include specified columns"
shelltest assert_contains "$result" '"age"' "read should include specified columns"
shelltest assert_not_contains "$result" '"city"' "read should exclude unspecified columns"

# Test: read with row limit
shelltest test_case "read with row limit"
result=$($CSV_CMD --json read "$TEST_CSV" --limit 2)
# Count the number of data rows (excluding header info)
row_count=$(echo "$result" | grep -o '"name"' | wc -l)
shelltest assert_equal "$row_count" "2" "read should limit to specified number of rows"

# Test: write command
shelltest test_case "write command"
output_file="test_output.csv"
$CSV_CMD write "$output_file" --data '[{"name": "Test", "age": "40", "city": "Test City"}]'
shelltest assert_file_exists "$output_file" "write should create output file"
result=$(cat "$output_file")
shelltest assert_contains "$result" "Test" "write should include data"
rm -f "$output_file"

# Test: filter command
shelltest test_case "filter command"
result=$($CSV_CMD --json filter "$TEST_CSV" --condition "age > 25")
shelltest assert_contains "$result" '"Alice"' "filter should include matching rows"
shelltest assert_contains "$result" '"Charlie"' "filter should include matching rows"
shelltest assert_not_contains "$result" '"Bob"' "filter should exclude non-matching rows"

# Test: sort command
shelltest test_case "sort command"
result=$($CSV_CMD --json sort "$TEST_CSV" --column age)
# Extract ages and check they're sorted
ages=$(echo "$result" | grep -o '"age": "[0-9]*"' | cut -d'"' -f4)
first_age=$(echo "$ages" | head -n1)
second_age=$(echo "$ages" | head -n2 | tail -n1)
shelltest assert_less_than_or_equal "$first_age" "$second_age" "sort should sort numerically"

# Test: head command
shelltest test_case "head command"
result=$($CSV_CMD --json head "$TEST_CSV" --lines 2)
row_count=$(echo "$result" | grep -o '"name"' | wc -l)
shelltest assert_equal "$row_count" "2" "head should return specified number of lines"

# Test: tail command
shelltest test_case "tail command"
result=$($CSV_CMD --json tail "$TEST_CSV" --lines 2)
row_count=$(echo "$result" | grep -o '"name"' | wc -l)
shelltest assert_equal "$row_count" "2" "tail should return specified number of lines"

# Test: count command
shelltest test_case "count command"
result=$($CSV_CMD count "$TEST_CSV")
shelltest assert_equal "$result" "3" "count should return correct number of rows"

# Test: columns command
shelltest test_case "columns command"
result=$($CSV_CMD --json columns "$TEST_CSV")
shelltest assert_contains "$result" '"name"' "columns should return column names"
shelltest assert_contains "$result" '"age"' "columns should return column names"
shelltest assert_contains "$result" '"city"' "columns should return column names"

# Test: unique command
shelltest test_case "unique command"
result=$($CSV_CMD --json unique "$TEST_CSV" --column city)
# Should have 3 unique cities
city_count=$(echo "$result" | grep -o '"city"' | wc -l)
shelltest assert_equal "$city_count" "3" "unique should return unique values"

# Test: group command
shelltest test_case "group command"
result=$($CSV_CMD --json group "$TEST_CSV" --column city)
shelltest assert_contains "$result" '"New York"' "group should group by specified column"
shelltest assert_contains "$result" '"Los Angeles"' "group should group by specified column"

# Test: merge command
shelltest test_case "merge command"
# Create second CSV file
TEST_CSV2="test_data2.csv"
echo "name,salary" > "$TEST_CSV2"
echo "Alice,50000" >> "$TEST_CSV2"
echo "Bob,45000" >> "$TEST_CSV2"

result=$($CSV_CMD --json merge "$TEST_CSV" "$TEST_CSV2" --on name)
shelltest assert_contains "$result" '"salary"' "merge should include columns from both files"
shelltest assert_contains "$result" '"50000"' "merge should include data from both files"

rm -f "$TEST_CSV2"

# Test: validate command
shelltest test_case "validate command"
result=$($CSV_CMD --json validate "$TEST_CSV")
shelltest assert_contains "$result" '"valid"' "validate should return validation status"

# Test: stats command
shelltest test_case "stats command"
result=$($CSV_CMD --json stats "$TEST_CSV")
shelltest assert_contains "$result" '"rows"' "stats should return row count"
shelltest assert_contains "$result" '"columns"' "stats should return column count"

# Test: sample command
shelltest test_case "sample command"
result=$($CSV_CMD --json sample "$TEST_CSV" --size 2)
row_count=$(echo "$result" | grep -o '"name"' | wc -l)
shelltest assert_equal "$row_count" "2" "sample should return specified number of rows"

# Clean up test file
rm -f "$TEST_CSV" 