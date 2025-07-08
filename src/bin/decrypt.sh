#!/bin/bash

set -oue pipefail

decrypt_help() {
    shlog _begin-help-text
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
    shlog _end-help-text

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
          shlog error "--input requires at least one path"; return 1
        fi
        while [[ $# -gt 0 && "$1" != "--"* ]]; do
          input+=("$1")
          shift
        done
        ;;
      --output)
        if [[ $# -lt 2 || "$2" == "--"* ]]; then
          shlog error "--output requires a filename"; return 1
        fi
        output="$2"
        shift 2
        ;;
      --delete)
        delete=true
        shift
        ;;
      --help|-h)
        decrypt_help
        return 0
        ;;
      *)
        decrypt_help
        shlog error "Unknown argument: $1"
        return 1
        ;;
    esac
  done

  for f in "${input[@]}"; do
    [[ ! -f "$f" ]] && shlog error "File not found: $f" && return 1
  done

  mkdir -p "${output:-.}"

  _ensure_gpg_loopback_enabled
  for f in "${input[@]}"; do
    local outdir="${output:-.}"
    gpg --decrypt "$f" | tar -xzf - -C "$outdir"
  done

  if $delete; then
    deleter "${input[@]}"
  fi
}

decrypt "$@"
