#!/bin/bash

set -oue pipefail

installer_help() {
    shlog _begin-help-text
    echo
    echo "installer.sh"
    echo
    echo "  Usage: $0 <package>..."
    echo
    echo "Description:"
    echo "  Installs packages using the appropriate package manager for the OS."
    echo
    echo "Arguments:"
    echo "  <package>...            one or more packages to install"
    echo
    shlog _end-help-text
}

installer() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) installer_help; return 0 ;;
    esac

    if [[ $# -eq 0 ]]; then
        installer_help
        return 1
    fi

    local os_type
    os_type=$(ostype get 2>/dev/null || echo "Unknown")

    local manager=""
    if [[ "$os_type" == "Darwin" ]]; then
        if command -v brew >/dev/null 2>&1; then
            manager="brew"
        else
            shlog error "Homebrew not installed on macOS"
            return 1
        fi
    elif [[ "$os_type" == "Linux" ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            manager="apt-get"
        elif command -v dnf >/dev/null 2>&1; then
            manager="dnf"
        elif command -v yum >/dev/null 2>&1; then
            manager="yum"
        elif command -v pacman >/dev/null 2>&1; then
            manager="pacman"
        else
            shlog error "No known package manager found"
            return 1
        fi
    else
        shlog error "Unable to determine OS type"
        return 1
    fi

    shift $((cmd == "help" ? 1 : 0))
    for pkg in "$@"; do
        shlog info "Installing $pkg using $manager"
        case "$manager" in
            brew) brew install "$pkg" ;;
            apt-get) sudo apt-get install -y "$pkg" ;;
            dnf) sudo dnf install -y "$pkg" ;;
            yum) sudo yum install -y "$pkg" ;;
            pacman) sudo pacman -S --noconfirm "$pkg" ;;
        esac
    done
}

installer "$@"
