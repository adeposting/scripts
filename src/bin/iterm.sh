#!/bin/bash

set -oue pipefail

iterm_help() {
  shlog _begin-help-text
  echo
  echo "iterm.sh"
  echo
  echo "  Usage: $0 <command>"
  echo
  echo "Arguments:"
  echo "  <command>                command to run in iTerm2"
  echo
  echo "Commands:"
  echo "  profile <name>           → set iTerm2 profile"
  echo "  help, --help, -h         → show this help text"
  echo
  shlog _end-help-text
}

iterm() {
  local cmd="${1:-}"
  case "$cmd" in
    help|--help|-h) 
      iterm_help 
      return 0
      ;;
    *) 
      # Main logic moved here
      if command -v ostype &>/dev/null; then
        if ! ostype is darwin &>/dev/null; then
          shlog error "This script only works on macOS (darwin)."
          return 1
        fi
      else
        # Fallback check
        if [[ "$(uname)" != "Darwin" ]]; then
          shlog error "This script only works on macOS (darwin)."
          return 1
        fi
      fi

      local cmd=""
      if [[ "$#" -gt 0 ]]; then
        cmd="$*"
        shlog debug "Command argument detected: $cmd"
      fi

      local escaped_cwd
      escaped_cwd="$(printf '%q' "$PWD")"

      shlog info "Opening iTerm in directory: $PWD"
      [[ -n "$cmd" ]] && shlog info "Running command: $cmd"

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
      ;;
  esac
}

iterm "$@"
