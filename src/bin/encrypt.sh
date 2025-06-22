#!/bin/bash
set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CWD/debug.sh"
source "$CWD/log.sh"
source "$CWD/safe-delete.sh"

_help() {
    echo
    echo "encrypt.sh"
    echo
    echo "  Usage: encrypt --input <path>... [--output <archive>] [--delete]"
    echo
    echo "Options:"
    echo "  --input <path>...    → one or more files or directories to encrypt"
    echo "  --output <file>      → output archive name (defaults to individual archives if omitted)"
    echo "  --delete             → securely delete inputs after encryption"
    echo
    echo "Behavior:"
    echo "  - If --output is not given, each input is encrypted into its own .tar.gz.gpg archive"
    echo "  - If --output is given, all inputs are combined into one archive"
    echo "  - If --delete is not given, the user will be prompted"
    echo
    echo "Integration:"
    echo "  You can source this script to reuse the encrypt function:"
    echo "    source /path/to/encrypt.sh"
    echo
    echo "  This will make the following function available:"
    echo "    encrypt  → encrypt files or directories"
    echo
}

encrypt() {
  local input=()
  local output=""
  local delete=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --input) shift; while [[ "$1" != "--"* && -n "$1" ]]; do input+=("$1"); shift; done ;;
      --output) output="$2"; shift 2 ;;
      --delete) delete=true; shift ;;
      --help|-h) _help; return 0 ;;
      *) log_error "Unknown argument: $1"; return 1 ;;
    esac
  done

  [[ ${#input[@]} -eq 0 ]] && log_error "No input specified" && return 1

  if [[ -n "$output" ]]; then
    [[ "$output" != *.tar.gz.gpg ]] && output="${output%.tar.gz.gpg}.tar.gz.gpg"
    tar -czf - "${input[@]}" | gpg --symmetric --cipher-algo AES256 -o "$output"
  else
    for item in "${input[@]}"; do
      local name="$(basename "$item")"
      local archive="${name}.tar.gz"
      [[ -f "$item" ]] && archive="${name%.*}.tar.gz"
      tar -czf - "$item" | gpg --symmetric --cipher-algo AES256 -o "${archive}.gpg"
    done
  fi

  if $delete; then
    safe_delete "${input[@]}"
  else
    read -rp "Delete original files/directories? [y/N]: " resp
    [[ "$resp" =~ ^[Yy](es)?$ ]] && safe_delete "${input[@]}"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  encrypt "$@"
else
  export -f encrypt
fi
