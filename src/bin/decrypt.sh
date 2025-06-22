#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log
include safe-delete

_help() {
    echo
    echo "decrypt.sh"
    echo
    echo "  Usage: decrypt --input <archive>... [--output <directory>] [--delete]"
    echo
    echo "Options:"
    echo "  --input <file>...    → one or more .tar.gz.gpg archives to decrypt"
    echo "  --output <directory> → directory to extract files to (defaults to current directory)"
    echo "  --delete             → securely delete encrypted archives after decryption"
    echo
    echo "Behavior:"
    echo "  - All input archives are checked for existence before processing"
    echo "  - Extracted contents are placed in the specified or current directory"
    echo "  - If --delete is specified, original archives are securely deleted"
    echo
    echo "Integration:"
    echo "  You can source this script to reuse the decrypt function:"
    echo "    source /path/to/decrypt.sh"
    echo
    echo "  This will make the following function available:"
    echo "    decrypt  → decrypt encrypted archives"
    echo
}

decrypt() {
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

  for f in "${input[@]}"; do
    [[ ! -f "$f" ]] && log_error "File not found: $f" && return 1
  done

  mkdir -p "${output:-.}"

  for f in "${input[@]}"; do
    local outdir="${output:-.}"
    gpg --decrypt "$f" | tar -xzf - -C "$outdir"
  done

  if $delete; then
    safe_delete "${input[@]}"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  decrypt "$@"
else
  export -f decrypt
fi
