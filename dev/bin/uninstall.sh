#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

uninstall_help() {
    echo
    echo "uninstall.sh - Uninstall scripts from system"
    echo
    echo "  Usage: $0"
    echo
    echo "Removes scripts from ~/.local/share/scripts and cleans up symlinks"
    echo
}

uninstall() {
    echo "Uninstalling scripts from ~/.local/share/scripts"

    # Remove symlinks
    echo "Removing symlinks..."
    if [[ -d ~/.local/bin ]]; then
        # Find and remove symlinks that point to our scripts directory
        while IFS= read -r link; do
            if [[ -L "$link" ]]; then
                local target
                target=$(readlink "$link")
                if [[ "$target" == ~/.local/share/scripts/* ]]; then
                    rm -f "$link"
                    echo "Removed symlink: $link"
                fi
            fi
        done < <(find ~/.local/bin -type l 2>/dev/null)
    fi

    # Remove installed scripts
    rm -rf ~/.local/share/scripts
    echo "Removed ~/.local/share/scripts"

    # Clean up local dist
    rm -rf ./dist
    echo "Cleaned up local dist directory"

    echo "Uninstallation complete"
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) uninstall_help ;;
        *) uninstall ;;
    esac
}

main "$@" 