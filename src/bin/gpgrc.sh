#!/bin/bash

set -oue pipefail

gpgrc_help() {
    color set bright-white
    echo
    echo "gpgrc.sh"
    echo "  Usage: $0 <command>"
    echo
    echo "Commands:"
    echo "  init              → ensure GPG loopback pinentry is enabled"
    echo "  help, --help, -h  → show this help text"
    echo
    color reset
}

gpgrc_init() {
    local conf="$HOME/.gnupg/gpg-agent.conf"
    local opt="allow-loopback-pinentry"
    mkdir -p "$(dirname "$conf")"
    if ! grep -Fxq "$opt" "$conf" 2>/dev/null; then
        echo "$opt" >> "$conf"
        shlog info "Added allow-loopback-pinentry to GPG agent config"
    else
        shlog info "GPG loopback pinentry already enabled"
    fi
    gpgconf --kill gpg-agent
    shlog info "GPG agent restarted"
}

gpgrc() {
    local cmd="${1:-}"
    case "$cmd" in
        init)       gpgrc_init ;;
        help|--help|-h) gpgrc_help ;;
        *)          gpgrc_help; return 1 ;;
    esac
}

gpgrc "$@" 