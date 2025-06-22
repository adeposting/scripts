#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log

_help() {
    echo
    echo "ostype.sh"
    echo
    echo "  Usage: ostype [os-name]"
    echo
    echo "Behavior:"
    echo "  Prints the detected OS name (e.g., darwin, arch, debian, ubuntu, void, etc.)"
    echo "  If an argument is given, returns success if it matches the detected OS, otherwise returns error"
    echo
    echo "Integration:"
    echo "  You can source this script to reuse the ostype function:"
    echo "    source /path/to/ostype.sh"
    echo
    echo "  This will make the following function available:"
    echo "    ostype  → detect or compare OS type"
    echo
}

ostype() {
  local actual=""
  if [[ "$(uname)" == "Darwin" ]]; then
    actual="darwin"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    actual="${ID,,}"
  elif command -v lsb_release >/dev/null; then
    actual="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
  else
    log_error "Unable to determine OS type"
    return 1
  fi

  if [[ $# -gt 0 ]]; then
    [[ "$1" == "$actual" ]] && return 0 || return 1
  else
    echo "$actual"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ostype "$@"
else
  export -f ostype
fi
