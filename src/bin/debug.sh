#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

debug_help() {
    shlog _begin-help-text
    echo
    echo "debug.sh"
    echo
    echo "  Usage: $0 <command>"
    echo
    echo "Commands:"
    echo "  enable                 → enable debug mode"
    echo "  disable                → disable debug mode"
    echo "  is_enabled             → check if debug mode is enabled (exit 0 if enabled, 1 if disabled)"
    echo "  help, --help, -h       → show this help text"
    echo
    echo "Environment:"
    echo "  DEBUG                  → set to any non-empty value to enable debug mode"
    echo
    shlog _end-help-text
}

debug_enable() {
    export DEBUG=1
    echo "Debug mode enabled"
}

debug_disable() {
    unset DEBUG
    echo "Debug mode disabled"
}

debug_is_enabled() {
    if [[ -n "${DEBUG:-}" ]]; then
        return 0  # enabled
    else
        return 1  # disabled
    fi
}

debug() {
    local cmd="${1:-}"
    case "$cmd" in
        enable)     debug_enable ;;
        disable)    debug_disable ;;
        is_enabled) debug_is_enabled ;;
        help|--help|-h) debug_help ;;
        *)          debug_help; return 1 ;;
    esac
}

debug "$@"
