#!/bin/bash

set -oue pipefail

ostype_help() {
    shlog _begin-help-text
    echo
    echo "ostype.sh"
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  get                     → print the detected OS name"
    echo "  is <os-name>            → return success if OS matches, error otherwise"
    echo "  help, --help, -h        → show this help text"
    echo
    shlog _end-help-text
}

get_ostype() {
  local actual=""
  local id=""

  if [[ "$(uname)" == "Darwin" ]]; then
    actual="Darwin"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    actual="${ID}"
  elif command -v lsb_release >/dev/null; then
    actual="$(lsb_release -si)"
  else
    shlog error "Unable to determine OS type"
    return 1
  fi

  echo "$actual"
}

is_ostype() {
  local want="${1:-}"
  if [[ -z "$want" ]]; then
    echo "OS name required for comparison" >&2
    return 1
  fi
  local actual
  actual="$(get_ostype)" || return 1
  local want_lower="$(echo "$want" | tr '[:upper:]' '[:lower:]')"
  local have_lower="$(echo "$actual" | tr '[:upper:]' '[:lower:]')"
  [[ "$have_lower" == "$want_lower" ]] && return 0 || return 1
}

ostype() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        get)         get_ostype ;;
        is)          is_ostype "$@" ;;
        help|--help|-h) ostype_help ;;
        *)           ostype_help; return 1 ;;
    esac
}

ostype "$@"
