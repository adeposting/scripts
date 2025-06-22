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

_ensure_gpg_loopback_enabled() {
  local conf="$HOME/.gnupg/gpg-agent.conf"
  local opt="allow-loopback-pinentry"
  mkdir -p "$(dirname "$conf")"
  if ! grep -Fxq "$opt" "$conf" 2>/dev/null; then
    echo "$opt" >> "$conf"
  fi
  gpgconf --kill gpg-agent
}

decrypt() {
  local input=()
  local output=""
  local delete=false


  while [[ $# -gt 0 ]]; do
    case "$1" in
      --input)
        shift
        if [[ $# -eq 0 || "$1" == "--"* ]]; then
          log_error "--input requires at least one path"; return 1
        fi
        while [[ $# -gt 0 && "$1" != "--"* ]]; do
          input+=("$1")
          shift
        done
        ;;
      --output)
        if [[ $# -lt 2 || "$2" == "--"* ]]; then
          log_error "--output requires a filename"; return 1
        fi
        output="$2"
        shift 2
        ;;
      --delete)
        delete=true
        shift
        ;;
      --help|-h)
        _help
        return 0
        ;;
      *)
        _help
        log_error "Unknown argument: $1"
        return 1
        ;;
    esac
  done

  for f in "${input[@]}"; do
    [[ ! -f "$f" ]] && log_error "File not found: $f" && return 1
  done

  mkdir -p "${output:-.}"

  _ensure_gpg_loopback_enabled
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
