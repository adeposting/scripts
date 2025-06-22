#!/bin/bash

TEST_STDOUT_LOG_FILE="./tests.stdout.log"
TEST_STDERR_LOG_FILE="./tests.stderr.log"

timestamp="$(date)"
echo "$timestamp" > "$TEST_STDOUT_LOG_FILE"
echo "$timestamp" > "$TEST_STDERR_LOG_FILE"

_log() {
  local stdout_log="$TEST_STDOUT_LOG_FILE"
  local stderr_log="$TEST_STDERR_LOG_FILE"

  # Run the command with tee'd output
  "$@" > >(tee -a "$stdout_log") 2> >(tee -a "$stderr_log" >&2)
}

for script in $PWD/src/bin/*.sh
do
    _log bash -n $script || echo > /dev/null
    _log shellcheck -x $script || echo > /dev/null
done