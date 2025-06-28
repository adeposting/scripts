#!/bin/bash

# Tests for py-datetime.py
# Comprehensive test coverage for the Datetime CLI wrapper

shelltest test_suite "py-datetime"

# Set up test environment
DATETIME_CMD="py-datetime"

# Test: py-datetime command exists and shows help
shelltest test_case "py-datetime command exists and shows help"
shelltest assert_command_exists "$DATETIME_CMD" "py-datetime command should be available"
output=$($DATETIME_CMD --help 2>&1)
shelltest assert_contains "$output" "Datetime CLI" "help should show Datetime CLI description"

# Test: now command
shelltest test_case "now command"
result=$($DATETIME_CMD now)
shelltest assert_contains "$result" "T" "now should return ISO format datetime"
shelltest assert_contains "$result" "-" "now should contain date separator"

# Test: now command with timezone
shelltest test_case "now command with timezone"
result=$($DATETIME_CMD now --timezone UTC)
shelltest assert_contains "$result" "T" "now with timezone should return ISO format datetime"
shelltest assert_contains "$result" "+00:00" "now with UTC should contain timezone info"

# Test: today command
shelltest test_case "today command"
result=$($DATETIME_CMD today)
shelltest assert_contains "$result" "-" "today should return ISO format date"
shelltest assert_not_contains "$result" "T" "today should not contain time"

# Test: utcnow command
shelltest test_case "utcnow command"
result=$($DATETIME_CMD utcnow)
shelltest assert_contains "$result" "T" "utcnow should return ISO format datetime"

# Test: fromisoformat command
shelltest test_case "fromisoformat command"
result=$($DATETIME_CMD fromisoformat "2023-12-25T10:30:00")
shelltest assert_contains "$result" "2023" "fromisoformat should parse year"
shelltest assert_contains "$result" "12" "fromisoformat should parse month"
shelltest assert_contains "$result" "25" "fromisoformat should parse day"
shelltest assert_contains "$result" "10" "fromisoformat should parse hour"
shelltest assert_contains "$result" "30" "fromisoformat should parse minute"

# Test: strptime command
shelltest test_case "strptime command"
result=$($DATETIME_CMD strptime "2023-12-25 10:30:00" "%Y-%m-%d %H:%M:%S")
shelltest assert_contains "$result" "2023" "strptime should parse year"
shelltest assert_contains "$result" "12" "strptime should parse month"
shelltest assert_contains "$result" "25" "strptime should parse day"

# Test: strftime command
shelltest test_case "strftime command"
result=$($DATETIME_CMD strftime "2023-12-25T10:30:00" "%Y-%m-%d")
shelltest assert_equal "2023-12-25" "$result" "strftime should format datetime"

# Test: add-days command
shelltest test_case "add-days command"
result=$($DATETIME_CMD add-days "2023-12-25T10:30:00" 7)
shelltest assert_contains "$result" "2024-01-01" "add-days should add days correctly"

# Test: add-hours command
shelltest test_case "add-hours command"
result=$($DATETIME_CMD add-hours "2023-12-25T10:30:00" 24)
shelltest assert_contains "$result" "2023-12-26" "add-hours should add hours correctly"

# Test: add-minutes command
shelltest test_case "add-minutes command"
result=$($DATETIME_CMD add-minutes "2023-12-25T10:30:00" 60)
shelltest assert_contains "$result" "11:30" "add-minutes should add minutes correctly"

# Test: add-seconds command
shelltest test_case "add-seconds command"
result=$($DATETIME_CMD add-seconds "2023-12-25T10:30:00" 3600)
shelltest assert_contains "$result" "11:30" "add-seconds should add seconds correctly"

# Test: diff-days command
shelltest test_case "diff-days command"
result=$($DATETIME_CMD diff-days "2023-12-25T10:30:00" "2024-01-01T10:30:00")
shelltest assert_equal "7" "$result" "diff-days should calculate difference correctly"

# Test: diff-seconds command
shelltest test_case "diff-seconds command"
result=$($DATETIME_CMD diff-seconds "2023-12-25T10:30:00" "2023-12-25T11:30:00")
shelltest assert_equal "3600" "$result" "diff-seconds should calculate difference correctly"

# Test: weekday command
shelltest test_case "weekday command"
result=$($DATETIME_CMD weekday "2023-12-25T10:30:00")
shelltest assert_greater_than_or_equal "0" "$result" "weekday should return valid weekday number"
shelltest assert_less_than "7" "$result" "weekday should return valid weekday number"

# Test: isoweekday command
shelltest test_case "isoweekday command"
result=$($DATETIME_CMD isoweekday "2023-12-25T10:30:00")
shelltest assert_greater_than_or_equal "1" "$result" "isoweekday should return valid ISO weekday number"
shelltest assert_less_than_or_equal "7" "$result" "isoweekday should return valid ISO weekday number"

# Test: isocalendar command
shelltest test_case "isocalendar command"
result=$($DATETIME_CMD isocalendar "2023-12-25T10:30:00")
shelltest assert_contains "$result" "year" "isocalendar should return year"
shelltest assert_contains "$result" "week" "isocalendar should return week"
shelltest assert_contains "$result" "weekday" "isocalendar should return weekday"

# Test: timestamp command
shelltest test_case "timestamp command"
result=$($DATETIME_CMD timestamp "2023-12-25T10:30:00")
shelltest assert_greater_than "0" "$result" "timestamp should return positive timestamp"

# Test: fromtimestamp command
shelltest test_case "fromtimestamp command"
timestamp=$(date +%s)
result=$($DATETIME_CMD fromtimestamp "$timestamp")
shelltest assert_contains "$result" "T" "fromtimestamp should return ISO format datetime"

# Test: utcfromtimestamp command
shelltest test_case "utcfromtimestamp command"
timestamp=$(date +%s)
result=$($DATETIME_CMD utcfromtimestamp "$timestamp")
shelltest assert_contains "$result" "T" "utcfromtimestamp should return ISO format datetime"

# Test: replace command - year
shelltest test_case "replace command - year"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --year 2024)
shelltest assert_contains "$result" "2024" "replace should change year"

# Test: replace command - month
shelltest test_case "replace command - month"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --month 6)
shelltest assert_contains "$result" "2023-06-25" "replace should change month"

# Test: replace command - day
shelltest test_case "replace command - day"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --day 15)
shelltest assert_contains "$result" "2023-12-15" "replace should change day"

# Test: replace command - hour
shelltest test_case "replace command - hour"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --hour 15)
shelltest assert_contains "$result" "15:30" "replace should change hour"

# Test: replace command - minute
shelltest test_case "replace command - minute"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --minute 45)
shelltest assert_contains "$result" "10:45" "replace should change minute"

# Test: replace command - second
shelltest test_case "replace command - second"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --second 30)
shelltest assert_contains "$result" "10:30:30" "replace should change second"

# Test: replace command - multiple fields
shelltest test_case "replace command - multiple fields"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --year 2024 --month 6 --day 15)
shelltest assert_contains "$result" "2024-06-15" "replace should change multiple fields"

# Test: add-days command - negative days
shelltest test_case "add-days command - negative days"
result=$($DATETIME_CMD add-days "2023-12-25T10:30:00" -7)
shelltest assert_contains "$result" "2023-12-18" "add-days should handle negative days"

# Test: add-hours command - negative hours
shelltest test_case "add-hours command - negative hours"
result=$($DATETIME_CMD add-hours "2023-12-25T10:30:00" -24)
shelltest assert_contains "$result" "2023-12-24" "add-hours should handle negative hours"

# Test: diff-days command - negative difference
shelltest test_case "diff-days command - negative difference"
result=$($DATETIME_CMD diff-days "2024-01-01T10:30:00" "2023-12-25T10:30:00")
shelltest assert_equal "-7" "$result" "diff-days should handle negative difference"

# Test: diff-seconds command - negative difference
shelltest test_case "diff-seconds command - negative difference"
result=$($DATETIME_CMD diff-seconds "2023-12-25T11:30:00" "2023-12-25T10:30:00")
shelltest assert_equal "-3600" "$result" "diff-seconds should handle negative difference"

# Test: strftime command - complex format
shelltest test_case "strftime command - complex format"
result=$($DATETIME_CMD strftime "2023-12-25T10:30:00" "%Y-%m-%d %H:%M:%S")
shelltest assert_equal "2023-12-25 10:30:00" "$result" "strftime should handle complex format"

# Test: strftime command - day name
shelltest test_case "strftime command - day name"
result=$($DATETIME_CMD strftime "2023-12-25T10:30:00" "%A")
shelltest assert_not_empty "$result" "strftime should return day name"

# Test: strftime command - month name
shelltest test_case "strftime command - month name"
result=$($DATETIME_CMD strftime "2023-12-25T10:30:00" "%B")
shelltest assert_not_empty "$result" "strftime should return month name"

# Test: fromisoformat command - with timezone
shelltest test_case "fromisoformat command - with timezone"
result=$($DATETIME_CMD fromisoformat "2023-12-25T10:30:00+00:00")
shelltest assert_contains "$result" "2023" "fromisoformat should parse datetime with timezone"

# Test: strptime command - date only
shelltest test_case "strptime command - date only"
result=$($DATETIME_CMD strptime "2023-12-25" "%Y-%m-%d")
shelltest assert_contains "$result" "2023" "strptime should parse date only"
shelltest assert_contains "$result" "00:00" "strptime should set time to 00:00 for date only"

# Test: timestamp command - with timezone
shelltest test_case "timestamp command - with timezone"
result=$($DATETIME_CMD timestamp "2023-12-25T10:30:00+00:00")
shelltest assert_greater_than "0" "$result" "timestamp should work with timezone"

# Test: JSON output
shelltest test_case "JSON output"
result=$($DATETIME_CMD fromisoformat "2023-12-25T10:30:00" --json)
shelltest assert_contains "$result" "{" "JSON output should be object"
shelltest assert_contains "$result" "}" "JSON output should be object"

# Test: dry-run mode
shelltest test_case "dry-run mode"
result=$($DATETIME_CMD add-days "2023-12-25T10:30:00" 7 --dry-run)
shelltest assert_contains "$result" "Would add" "dry-run should show what would be done"

# Test: verbose mode
shelltest test_case "verbose mode"
result=$($DATETIME_CMD now --verbose 2>&1)
shelltest assert_contains "$result" "now" "verbose should show command being executed"

# Test: now command - edge case (leap year)
shelltest test_case "now command - edge case (leap year)"
result=$($DATETIME_CMD add-days "2024-02-28T10:30:00" 1)
shelltest assert_contains "$result" "2024-02-29" "add-days should handle leap year"

# Test: add-days command - month boundary
shelltest test_case "add-days command - month boundary"
result=$($DATETIME_CMD add-days "2023-01-31T10:30:00" 1)
shelltest assert_contains "$result" "2023-02-01" "add-days should handle month boundary"

# Test: add-days command - year boundary
shelltest test_case "add-days command - year boundary"
result=$($DATETIME_CMD add-days "2023-12-31T10:30:00" 1)
shelltest assert_contains "$result" "2024-01-01" "add-days should handle year boundary"

# Test: weekday command - known date
shelltest test_case "weekday command - known date"
result=$($DATETIME_CMD weekday "2023-12-25T10:30:00")
# December 25, 2023 was a Monday (0)
shelltest assert_equal "0" "$result" "weekday should return correct weekday for known date"

# Test: isoweekday command - known date
shelltest test_case "isoweekday command - known date"
result=$($DATETIME_CMD isoweekday "2023-12-25T10:30:00")
# December 25, 2023 was a Monday (1 in ISO)
shelltest assert_equal "1" "$result" "isoweekday should return correct ISO weekday for known date"

# Test: isocalendar command - known date
shelltest test_case "isocalendar command - known date"
result=$($DATETIME_CMD isocalendar "2023-12-25T10:30:00" --json)
shelltest assert_contains "$result" "2023" "isocalendar should return correct year"
shelltest assert_contains "$result" "52" "isocalendar should return correct week"

# Test: replace command - microsecond
shelltest test_case "replace command - microsecond"
result=$($DATETIME_CMD replace "2023-12-25T10:30:00" --microsecond 123456)
shelltest assert_contains "$result" "10:30:00.123456" "replace should change microsecond"

# Test: fromisoformat command - with microseconds
shelltest test_case "fromisoformat command - with microseconds"
result=$($DATETIME_CMD fromisoformat "2023-12-25T10:30:00.123456")
shelltest assert_contains "$result" "123456" "fromisoformat should parse microseconds"

# Test: strptime command - with microseconds
shelltest test_case "strptime command - with microseconds"
result=$($DATETIME_CMD strptime "2023-12-25 10:30:00.123456" "%Y-%m-%d %H:%M:%S.%f")
shelltest assert_contains "$result" "123456" "strptime should parse microseconds"

# Test: add-days command - zero days
shelltest test_case "add-days command - zero days"
original="2023-12-25T10:30:00"
result=$($DATETIME_CMD add-days "$original" 0)
shelltest assert_equal "$original" "$result" "add-days with zero should return original datetime"

# Test: add-hours command - zero hours
shelltest test_case "add-hours command - zero hours"
original="2023-12-25T10:30:00"
result=$($DATETIME_CMD add-hours "$original" 0)
shelltest assert_equal "$original" "$result" "add-hours with zero should return original datetime"

# Test: diff-days command - same date
shelltest test_case "diff-days command - same date"
result=$($DATETIME_CMD diff-days "2023-12-25T10:30:00" "2023-12-25T23:59:59")
shelltest assert_equal "0" "$result" "diff-days should return 0 for same date"

# Test: diff-seconds command - same time
shelltest test_case "diff-seconds command - same time"
result=$($DATETIME_CMD diff-seconds "2023-12-25T10:30:00" "2023-12-25T10:30:00")
shelltest assert_equal "0" "$result" "diff-seconds should return 0 for same time" 