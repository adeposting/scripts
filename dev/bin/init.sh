#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

init_help() {
    echo
    echo "init.sh - Initialize development environment"
    echo
    echo "  Usage: $0"
    echo
    echo "Sets up development dependencies and tools"
    echo
}

init() {
    echo "Running init checks..."

    # Install shellcheck if not available
    if ! command -v shellcheck &>/dev/null; then
        echo "shellcheck not found, attempting to install..."
        
        if command -v brew &>/dev/null; then
            echo "Installing shellcheck via Homebrew..."
            brew install shellcheck
            if command -v shellcheck &>/dev/null; then
                echo "shellcheck installed successfully"
            else
                echo "Error: Failed to install shellcheck" >&2
                return 1
            fi
        else
            echo "Error: Homebrew not available. Please install shellcheck manually:" >&2
            echo "  macOS: brew install shellcheck" >&2
            echo "  Ubuntu/Debian: sudo apt install shellcheck" >&2
            echo "  Arch: sudo pacman -S shellcheck" >&2
            return 1
        fi
    else
        echo "shellcheck already available"
    fi

    echo "init complete"
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) init_help ;;
        *) init ;;
    esac
}

main "$@" 