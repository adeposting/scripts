#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./src/bin/color.sh"

dev_help() {
    set_color 'bright-white'
    echo ""
    echo -e "Usage: $0 <command>"
    echo ""
    echo -e "Available commands:"
    echo ""
    echo -e "  build      → Build the scripts from src/bin to dist/"
    echo -e "  clean      → Delete the dist/ directory"
    echo -e "  copy       → Copy dist to ~/.local/share/scripts"
    echo -e "  link       → Symlink each script from ~/.local/share/scripts/bin to ~/.local/bin"
    echo -e "  uninstall  → Remove symlinks and local scripts"
    echo -e "  test       → Run all test scripts in tests/"
    echo -e "  install    → Run test, clean, build, uninstall, copy, and link in order"
    echo -e "  help       → Show this help message"
    echo ""
    echo -e "Note: You can call this via 'make <command>' if the Makefile is present."
    echo
    reset_color
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_help "$@"
else
    export -f dev_help
fi
