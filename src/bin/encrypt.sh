#!/bin/bash

set -oue pipefail

encrypt_help() {
    shlog _begin-help-text
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

encrypt() {
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
        encrypt_help
        return 0
        ;;
      *)
        encrypt_help
        shlog error "Unknown argument: $1"
        return 1
        ;;
    esac
  done

  [[ ${#input[@]} -eq 0 ]] && slog error "No input specified" && return 1

  _ensure_gpg_loopback_enabled
  local -r gpg_command='gpg --pinentry-mode loopback --symmetric --cipher-algo AES256 -o'
  if [[ -n "$output" ]]; then
    [[ "$output" != *.tar.gz.gpg ]] && output="${output%.tar.gz.gpg}.tar.gz.gpg"
    tar -czf - "${input[@]}" | $gpg_command "$output"
  else
    for item in "${input[@]}"; do
      local name="$(basename "$item")"
      local archive="${name}.tar.gz"
      [[ -f "$item" ]] && archive="${name%.*}.tar.gz"
      tar -czf - "$item" | $gpg_command "${archive}.gpg"
    done
  fi

  if $delete; then
    deleter "${input[@]}"
  else
    read -rp "Delete original files/directories? [y/N]: " resp
    [[ "$resp" =~ ^[Yy](es)?$ ]] && deleter "${input[@]}"
  fi
}


encrypt "$@"

