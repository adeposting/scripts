#!/bin/bash
set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CWD/debug.sh"
source "$CWD/log.sh"
source "$CWD/super-install.sh"

_help() {
    echo
    echo "safe-delete.sh"
    echo
    echo "  Usage: safe-delete <path>..."
    echo
    echo "Behavior:"
    echo "  Securely deletes each specified file or directory using the most secure method available:"
    echo "    - srm (secure remove), if available"
    echo "    - shred, if available"
    echo "    - rm -rf, as a fallback"
    echo
    echo "Integration:"
    echo "  You can source this script to reuse the delete function:"
    echo "    source /path/to/safe-delete.sh"
    echo
    echo "  This will make the following function available:"
    echo "    safe_delete  → securely delete files or directories"
    echo
}


safe_delete() {
  super_install srm || super_install shred

  for target in "$@"; do
    if command -v srm &>/dev/null; then
      log_info "Securely deleting $target using srm..."
      srm -fzv "$target"
    elif command -v shred &>/dev/null; then
      log_info "Securely shredding $target using shred..."
      shred -uz "$target"
    else
      log_info "Fallback, deleting $target with rm -rf"
      rm -rf "$target"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  safe_delete "$@"
else
  export -f delete
fi
