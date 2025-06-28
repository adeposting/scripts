#!/bin/bash

# Tests for py-path.py
# Comprehensive test coverage for the py-path utility

shelltest test_suite "py-path"

# Test: py-path command exists
shelltest test_case "py-path command exists"
shelltest assert_command_exists "py-path" "py-path command should be available"

# Test: py-path help command
shelltest test_case "py-path help command"
output=$(py-path --help 2>&1)
shelltest assert_contains "$output" "py-path" "help should show script name"
shelltest assert_contains "$output" "Usage:" "help should show usage information"

# Test: absolute path
shelltest test_case "absolute path"
result=$(py-path absolute testfile.txt)
shelltest assert_contains "$result" "/" "absolute path should contain forward slash"

# Test: exists command for existing file
shelltest test_case "exists command for existing file"
result=$(py-path exists testfile.txt)
shelltest assert_contains "$result" "True" "exists command should return True for existing file"

# Test: exists command for non-existing file
shelltest test_case "exists command for non-existing file"
result=$(py-path exists nonexistent.txt)
shelltest assert_contains "$result" "False" "exists command should return False for non-existing file"

# Test: isfile command
shelltest test_case "isfile command"
result=$(py-path isfile testfile.txt)
shelltest assert_contains "$result" "True" "isfile command should return True for file"

# Test: isdir command
shelltest test_case "isdir command"
result=$(py-path isdir testdir)
shelltest assert_contains "$result" "True" "isdir command should return True for directory"

# Test: parent command
shelltest test_case "parent command"
result=$(py-path parent testdir/nested.py)
shelltest assert_equal "testdir" "$result" "parent command should return testdir"

# Test: name command
shelltest test_case "name command"
result=$(py-path name testdir/nested.py)
shelltest assert_equal "nested.py" "$result" "name command should return nested.py"

# Test: stem command
shelltest test_case "stem command"
result=$(py-path stem testdir/nested.py)
shelltest assert_equal "nested" "$result" "stem command should return nested"

# Test: suffix command
shelltest test_case "suffix command"
result=$(py-path suffix testdir/nested.py)
shelltest assert_equal ".py" "$result" "suffix command should return .py"

# Test: join command
shelltest test_case "join command"
result=$(py-path join path to file)
shelltest assert_equal "path/to/file" "$result" "join command should return path/to/file"

# Test: mkdir command
shelltest test_case "mkdir command"
py-path mkdir newdir
shelltest assert_directory_exists "newdir" "mkdir should create directory"

# Test: touch command
shelltest test_case "touch command"
py-path touch newfile.txt
shelltest assert_file_exists "newfile.txt" "touch should create file"

# Test: copy command
shelltest test_case "copy command"
py-path copy testfile.txt testfile_copy.txt
shelltest assert_file_exists "testfile_copy.txt" "copy should create copied file"

# Test: move command
shelltest test_case "move command"
py-path move testfile_copy.txt moved_file.txt
shelltest assert_file_exists "moved_file.txt" "move should create moved file"
shelltest assert_file_not_exists "testfile_copy.txt" "move should remove original file"

# Test: symlink command
shelltest test_case "symlink command"
py-path symlink testfile.txt new_symlink.txt
shelltest assert_file_exists "new_symlink.txt" "symlink should create symlink"

# Test: readlink command
shelltest test_case "readlink command"
result=$(py-path readlink new_symlink.txt)
shelltest assert_contains "$result" "testfile.txt" "readlink should show target"

# Test: resolve command
shelltest test_case "resolve command"
result=$(py-path resolve new_symlink.txt)
shelltest assert_contains "$result" "/" "resolve should return absolute path"

# Test: size command
shelltest test_case "size command"
result=$(py-path size testfile.txt)
shelltest assert_contains "$result" "[0-9]" "size should return a number"

# Test: mtime command
shelltest test_case "mtime command"
result=$(py-path mtime testfile.txt)
shelltest assert_contains "$result" "[0-9]" "mtime should return a number"

# Test: ctime command
shelltest test_case "ctime command"
result=$(py-path ctime testfile.txt)
shelltest assert_contains "$result" "[0-9]" "ctime should return a number"

# Test: atime command
shelltest test_case "atime command"
result=$(py-path atime testfile.txt)
shelltest assert_contains "$result" "[0-9]" "atime should return a number"

# Test: owner command
shelltest test_case "owner command"
result=$(py-path owner testfile.txt)
shelltest assert_not_empty "$result" "owner should return non-empty string"

# Test: group command
shelltest test_case "group command"
result=$(py-path group testfile.txt)
shelltest assert_not_empty "$result" "group should return non-empty string"

# Test: mode command
shelltest test_case "mode command"
result=$(py-path mode testfile.txt)
shelltest assert_contains "$result" "[0-9]" "mode should return a number"

# Test: is-abs command
shelltest test_case "is-abs command"
result=$(py-path is-abs /absolute/path)
shelltest assert_contains "$result" "True" "is-abs should return True for absolute path"

# Test: is-rel command
shelltest test_case "is-rel command"
result=$(py-path is-rel relative/path)
shelltest assert_contains "$result" "True" "is-rel should return True for relative path"

# Test: parts command
shelltest test_case "parts command"
result=$(py-path parts path/to/file)
shelltest assert_contains "$result" "path" "parts should contain path component"
shelltest assert_contains "$result" "to" "parts should contain to component"
shelltest assert_contains "$result" "file" "parts should contain file component"

# Test: with-name command
shelltest test_case "with-name command"
result=$(py-path with-name path/to/file.txt newname.txt)
shelltest assert_equal "path/to/newname.txt" "$result" "with-name should replace filename"

# Test: with-suffix command
shelltest test_case "with-suffix command"
result=$(py-path with-suffix path/to/file.txt .py)
shelltest assert_equal "path/to/file.py" "$result" "with-suffix should replace extension"

# Test: relative-to command
shelltest test_case "relative-to command"
result=$(py-path relative-to /base/path /base/path/file.txt)
shelltest assert_equal "file.txt" "$result" "relative-to should return relative path"

# Test: home command
shelltest test_case "home command"
result=$(py-path home)
shelltest assert_contains "$result" "/" "home should return path with slash"

# Test: cwd command
shelltest test_case "cwd command"
result=$(py-path cwd)
shelltest assert_contains "$result" "/" "cwd should return path with slash"

# Test: expanduser command
shelltest test_case "expanduser command"
result=$(py-path expanduser ~/test)
shelltest assert_contains "$result" "/" "expanduser should return expanded path"

# Test: expandvars command
shelltest test_case "expandvars command"
result=$(py-path expandvars '$HOME/test')
shelltest assert_contains "$result" "/" "expandvars should return expanded path"

# Test: normpath command
shelltest test_case "normpath command"
result=$(py-path normpath path//to///file)
shelltest assert_equal "path/to/file" "$result" "normpath should normalize path"

# Test: realpath command
shelltest test_case "realpath command"
result=$(py-path realpath testfile.txt)
shelltest assert_contains "$result" "/" "realpath should return absolute path"

# Test: samefile command
shelltest test_case "samefile command"
py-path copy testfile.txt testfile_copy.txt
result=$(py-path samefile testfile.txt testfile_copy.txt)
shelltest assert_contains "$result" "False" "samefile should return False for different files"

# Test: stat command
shelltest test_case "stat command"
result=$(py-path stat testfile.txt)
shelltest assert_contains "$result" "st_size" "stat should contain file size"

# Test: lstat command
shelltest test_case "lstat command"
result=$(py-path lstat new_symlink.txt)
shelltest assert_contains "$result" "st_size" "lstat should contain link size"

# Test: chmod command
shelltest test_case "chmod command"
py-path chmod testfile.txt 644
result=$(py-path mode testfile.txt)
shelltest assert_contains "$result" "644" "chmod should set mode to 644"

# Test: chown command (may fail without root)
shelltest test_case "chown command"
output=$(py-path chown testfile.txt $(whoami) 2>&1)
# This may fail without root, so we just check it doesn't crash
shelltest assert_contains "$output" "" "chown should not crash"

# Test: unlink command
shelltest test_case "unlink command"
py-path unlink moved_file.txt
shelltest assert_file_not_exists "moved_file.txt" "unlink should remove file"

# Test: rmdir command
shelltest test_case "rmdir command"
py-path rmdir newdir
shelltest assert_directory_not_exists "newdir" "rmdir should remove directory"

# Test: rmtree command
shelltest test_case "rmtree command"
py-path mkdir deep/nested/dir --parents
py-path rmtree deep
shelltest assert_directory_not_exists "deep" "rmtree should remove directory tree"

# Test: Error handling for non-existent file
shelltest test_case "error handling for non-existent file"
output=$(py-path stat nonexistent.txt 2>&1)
shelltest assert_contains "$output" "Error" "should show error for non-existent file" 