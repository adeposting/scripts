#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log
include ostype

_help() {
  echo
  echo "iterm.sh"
  echo
  echo "  Usage: iterm [command...]"
  echo
  echo "Arguments:"
  echo "  [command...]   → optional command(s) to run in the current directory"
  echo
  echo "Integration:"
  echo "  You can source this script to reuse the iterm function:"
  echo "    source /path/to/iterm.sh"
  echo
  echo "  This will make the following function available:"
  echo "    iterm → opens iTerm2 in the current directory and runs optional commands"
  echo
}

iterm() {
  if ! ostype darwin &>/dev/null; then
    log_error "This script only works on macOS (darwin)."
    return 1
  fi

  local cmd=""
  if [[ "$#" -gt 0 ]]; then
    cmd="$*"
    log_debug "Command argument detected: $cmd"
  fi

  local escaped_cwd
  escaped_cwd="$(printf '%q' "$PWD")"

  log_info "Opening iTerm in directory: $PWD"
  [[ -n "$cmd" ]] && log_info "Running command: $cmd"

  osascript <<EOF
tell application "iTerm"
    if not running then launch
    delay 0.5
    set newWindow to (create window with default profile)
    tell newWindow
        delay 0.5
        tell current session
            write text "cd ${escaped_cwd}; ${cmd}"
        end tell
    end tell
end tell
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  iterm "$@"
else
  export -f iterm
fi
