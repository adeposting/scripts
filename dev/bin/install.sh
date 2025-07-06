#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

install_help() {
    echo
    echo "install.sh - Install scripts to system"
    echo
    echo "  Usage: $0"
    echo
    echo "Installs scripts to ~/.local/share/scripts and creates symlinks"
    echo
}

install() {
    echo "Installing scripts to ~/.local/share/scripts"

    # Build first to ensure we have the latest distribution
    ./dev/bin/build.sh || {
        echo "Error: Build failed, cannot install" >&2
        return 1
    }

    # Clean up existing installation
    rm -rf ~/.local/share/scripts

    # Create target directory and install from dist
    mkdir -p ~/.local/share/scripts
    cp -r ./dist/* ~/.local/share/scripts/
    echo "Copied scripts to ~/.local/share/scripts"

    # Remove existing symlinks
    echo "Removing existing symlinks..."
    if [[ -d ~/.local/bin ]]; then
        # Find and remove symlinks that point to our scripts directory
        while IFS= read -r link; do
            if [[ -L "$link" ]]; then
                local target
                target=$(readlink "$link")
                if [[ "$target" == ~/.local/share/scripts/* ]]; then
                    rm -f "$link"
                    echo "Removed existing symlink: $link"
                fi
            fi
        done < <(find ~/.local/bin -type l 2>/dev/null)
    fi

    # Create symlinks
    echo "Creating symlinks..."
    if [[ ! -d ~/.local/bin ]]; then
        mkdir -p ~/.local/bin
    fi
    
    # Create symlinks for all scripts, removing .sh and .py extensions
    for script in ~/.local/share/scripts/bin/*; do
        if [[ -f "$script" ]]; then
            local script_name
            script_name=$(basename "$script")
            # Remove .sh or .py extension for the symlink name
            local link_name
            link_name=$(echo "$script_name" | sed -E 's/\.[sp][hy]$//')
            local link_path="$HOME/.local/bin/$link_name"
            
            # Remove existing file if it exists
            if [[ -e "$link_path" ]]; then
                rm -f "$link_path"
            fi
            
            # Create symlink
            if ln -s "$script" "$link_path"; then
                echo "Created symlink: $script → $link_path"
            else
                echo "Error: Failed to create symlink: $script → $link_path" >&2
            fi
        fi
    done

    echo "Installation complete. Scripts are available at ~/.local/share/scripts"
    echo "Add ~/.local/bin to your PATH to use the scripts from anywhere"
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) install_help ;;
        *) install ;;
    esac
}

main "$@" 