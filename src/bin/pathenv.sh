#!/bin/bash

set -euo pipefail

pathenv_help() {
  shlog _begin-help-text
  echo
  echo "pathenv.sh"
  echo
  echo "  Usage: $0 <command> [args...]"
  echo
  echo "Commands:"
  echo "  get                     → print the current PATH"
  echo "  list                    → list PATH entries"
  echo "  contains <dir>          → check if directory is on PATH"
  echo "  help, --help, -h        → show this help text"
  echo
  shlog _end-help-text
}

get_path_env() {
  echo "$PATH"
}

is_on_path_env() {
  local dir="$1"
  if [[ -z "$dir" ]]; then
    shlog error "No directory provided to is_on_path_env"
    return 1
  fi

  IFS=':' read -ra parts <<< "$PATH"
  for p in "${parts[@]}"; do
    [[ "$p" == "$dir" ]] && return 0
  done

  return 1
}

list_path_env() {
  IFS=':' read -ra parts <<< "$PATH"
  for p in "${parts[@]}"; do
    echo "$p"
  done
}

pathenv() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    get)         get_path_env ;;
    list)        list_path_env ;;
    contains)    is_on_path_env "$@" ;;
    help|--help|-h) pathenv_help ;;
    "")         pathenv_help; return 1 ;;
    *)           pathenv_help; return 1 ;;
  esac
}

pathenv "$@"
