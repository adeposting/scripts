#!/bin/bash

# Tests for py-platform.py
# Comprehensive test coverage for the Platform CLI wrapper

shelltest test_suite "py-platform"

# Set up test environment
PLATFORM_CMD="py-platform"

# Test: py-platform command exists and shows help
shelltest test_case "py-platform command exists and shows help"
shelltest assert_command_exists "$PLATFORM_CMD" "py-platform command should be available"
output=$($PLATFORM_CMD --help 2>&1)
shelltest assert_contains "$output" "Platform CLI" "help should show Platform CLI description"

# Test: system command
shelltest test_case "system command"
result=$($PLATFORM_CMD --json system)
shelltest assert_matches "$result" '^"[A-Za-z]+"$' "system should return system information"

# Test: release command
shelltest test_case "release command"
result=$($PLATFORM_CMD --json release)
shelltest assert_matches "$result" '^"[^"]*"$' "release should return release information"

# Test: version command
shelltest test_case "version command"
result=$($PLATFORM_CMD --json version)
shelltest assert_matches "$result" '^"[^"]*"$' "version should return version information"

# Test: machine command
shelltest test_case "machine command"
result=$($PLATFORM_CMD --json machine)
shelltest assert_matches "$result" '^"[^"]*"$' "machine should return machine information"

# Test: processor command
shelltest test_case "processor command"
result=$($PLATFORM_CMD --json processor)
shelltest assert_matches "$result" '^"[^"]*"$' "processor should return processor information"

# Test: architecture command
shelltest test_case "architecture command"
result=$($PLATFORM_CMD --json architecture)
shelltest assert_matches "$result" '^\[.*\]$' "architecture should return architecture information"

# Test: node command
shelltest test_case "node command"
result=$($PLATFORM_CMD --json node)
shelltest assert_matches "$result" '^"[^"]*"$' "node should return node information"

# Test: platform command
shelltest test_case "platform command"
result=$($PLATFORM_CMD --json platform-info)
shelltest assert_matches "$result" '^"[^"]*"$' "platform should return platform information"

# Test: python-version command
shelltest test_case "python-version command"
result=$($PLATFORM_CMD --json python-version)
shelltest assert_matches "$result" '^"[^"]*"$' "python-version should return Python version"

# Test: python-implementation command
shelltest test_case "python-implementation command"
result=$($PLATFORM_CMD --json python-implementation)
shelltest assert_matches "$result" '^"[^"]*"$' "python-implementation should return Python implementation"

# Test: python-compiler command
shelltest test_case "python-compiler command"
result=$($PLATFORM_CMD --json python-compiler)
shelltest assert_matches "$result" '^"[^"]*"$' "python-compiler should return Python compiler"

# Test: python-build command
shelltest test_case "python-build command"
result=$($PLATFORM_CMD --json python-build)
shelltest assert_matches "$result" '^\[.*\]$' "python-build should return Python build information"

# Test: uname command
shelltest test_case "uname command"
result=$($PLATFORM_CMD --json uname)
shelltest assert_contains "$result" '"system"' "uname should return system information"
shelltest assert_contains "$result" '"node"' "uname should return node information"
shelltest assert_contains "$result" '"release"' "uname should return release information"
shelltest assert_contains "$result" '"version"' "uname should return version information"
shelltest assert_contains "$result" '"machine"' "uname should return machine information"

# Test: uname with specific field
shelltest test_case "uname with specific field"
result=$($PLATFORM_CMD --json uname)
shelltest assert_contains "$result" '"system"' "uname should return system field"

# Test: libc-ver command
shelltest test_case "libc-ver command"
result=$($PLATFORM_CMD --json libc-ver)
# This may return empty on some systems
shelltest assert_not_contains "$result" "Error" "libc-ver should not error"

# Test: win32-ver command
shelltest test_case "win32-ver command"
result=$($PLATFORM_CMD --json win32-ver)
# This may return empty on non-Windows systems
shelltest assert_not_contains "$result" "Error" "win32-ver should not error on non-Windows"

# Test: mac-ver command
shelltest test_case "mac-ver command"
result=$($PLATFORM_CMD --json mac-ver)
# This may return empty on non-macOS systems
shelltest assert_not_contains "$result" "Error" "mac-ver should not error on non-macOS"

# Test: system-alias command
shelltest test_case "system-alias command"
result=$($PLATFORM_CMD --json system-alias)
shelltest assert_matches "$result" '^\[.*\]$' "system-alias should return tuple"

# Test: machine-alias command
shelltest test_case "machine-alias command"
result=$($PLATFORM_CMD --json machine-alias)
shelltest assert_matches "$result" '^\[.*\]$' "machine-alias should return tuple"

# Test: processor-alias command
shelltest test_case "processor-alias command"
result=$($PLATFORM_CMD --json processor-alias)
shelltest assert_matches "$result" '^\[.*\]$' "processor-alias should return tuple"

# Test: all-info command
shelltest test_case "all-info command"
result=$($PLATFORM_CMD --json all-info)
shelltest assert_contains "$result" '"system"' "all-info should include system"
shelltest assert_contains "$result" '"release"' "all-info should include release"
shelltest assert_contains "$result" '"version"' "all-info should include version"
shelltest assert_contains "$result" '"machine"' "all-info should include machine"
shelltest assert_contains "$result" '"processor"' "all-info should include processor"
shelltest assert_contains "$result" '"architecture"' "all-info should include architecture"
shelltest assert_contains "$result" '"node"' "all-info should include node"
shelltest assert_contains "$result" '"platform"' "all-info should include platform"

# Test: is-windows command
shelltest test_case "is-windows command"
result=$($PLATFORM_CMD is-windows)
shelltest assert_matches "$result" "^(True|False)$" "is-windows should return True or False"

# Test: is-linux command
shelltest test_case "is-linux command"
result=$($PLATFORM_CMD is-linux)
shelltest assert_matches "$result" "^(True|False)$" "is-linux should return True or False"

# Test: is-macos command
shelltest test_case "is-macos command"
result=$($PLATFORM_CMD is-macos)
shelltest assert_matches "$result" "^(True|False)$" "is-macos should return True or False"

# Test: is-unix command
shelltest test_case "is-unix command"
result=$($PLATFORM_CMD is-unix)
shelltest assert_matches "$result" "^(True|False)$" "is-unix should return True or False"

# Test: is-posix command
shelltest test_case "is-posix command"
result=$($PLATFORM_CMD is-posix)
shelltest assert_matches "$result" "^(True|False)$" "is-posix should return True or False"

# Test: is-64bit command
shelltest test_case "is-64bit command"
result=$($PLATFORM_CMD is-64bit)
shelltest assert_matches "$result" "^(True|False)$" "is-64bit should return True or False"

# Test: is-32bit command
shelltest test_case "is-32bit command"
result=$($PLATFORM_CMD is-32bit)
shelltest assert_matches "$result" "^(True|False)$" "is-32bit should return True or False"

# Test: is-little-endian command
shelltest test_case "is-little-endian command"
result=$($PLATFORM_CMD is-little-endian)
shelltest assert_matches "$result" "^(True|False)$" "is-little-endian should return True or False"

# Test: is-big-endian command
shelltest test_case "is-big-endian command"
result=$($PLATFORM_CMD is-big-endian)
shelltest assert_matches "$result" "^(True|False)$" "is-big-endian should return True or False"

# Test: get-architecture-bits command
shelltest test_case "get-architecture-bits command"
result=$($PLATFORM_CMD get-architecture-bits)
shelltest assert_matches "$result" "^(32|64)$" "get-architecture-bits should return 32 or 64"

# Test: get-byte-order command
shelltest test_case "get-byte-order command"
result=$($PLATFORM_CMD get-byte-order)
shelltest assert_matches "$result" "^(little|big)$" "get-byte-order should return little or big"

# Test: get-python-architecture command
shelltest test_case "get-python-architecture command"
result=$($PLATFORM_CMD get-python-architecture)
shelltest assert_not_empty "$result" "get-python-architecture should return architecture"

# Test: get-python-platform command
shelltest test_case "get-python-platform command"
result=$($PLATFORM_CMD get-python-platform)
shelltest assert_not_empty "$result" "get-python-platform should return platform"

# Test: get-python-implementation command
shelltest test_case "get-python-implementation command"
result=$($PLATFORM_CMD get-python-implementation)
shelltest assert_not_empty "$result" "get-python-implementation should return implementation"

# Test: get-python-compiler command
shelltest test_case "get-python-compiler command"
result=$($PLATFORM_CMD get-python-compiler)
shelltest assert_not_empty "$result" "get-python-compiler should return compiler"

# Test: get-python-build command
shelltest test_case "get-python-build command"
result=$($PLATFORM_CMD get-python-build)
shelltest assert_not_empty "$result" "get-python-build should return build information"

# Test: get-system-info command
shelltest test_case "get-system-info command"
result=$($PLATFORM_CMD --json get-system-info)
shelltest assert_contains "$result" '"system"' "get-system-info should return system info"
shelltest assert_contains "$result" '"release"' "get-system-info should return release info"
shelltest assert_contains "$result" '"version"' "get-system-info should return version info"

# Test: get-machine-info command
shelltest test_case "get-machine-info command"
result=$($PLATFORM_CMD --json get-machine-info)
shelltest assert_contains "$result" '"machine"' "get-machine-info should return machine info"
shelltest assert_contains "$result" '"processor"' "get-machine-info should return processor info"
shelltest assert_contains "$result" '"architecture"' "get-machine-info should return architecture info"

# Test: get-python-info command
shelltest test_case "get-python-info command"
result=$($PLATFORM_CMD --json get-python-info)
shelltest assert_contains "$result" '"python_version"' "get-python-info should return Python version"
shelltest assert_contains "$result" '"python_implementation"' "get-python-info should return Python implementation"
shelltest assert_contains "$result" '"python_compiler"' "get-python-info should return Python compiler" 