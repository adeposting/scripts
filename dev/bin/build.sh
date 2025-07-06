#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

build_help() {
    echo
    echo "build.sh - Build scripts distribution"
    echo
    echo "  Usage: $0"
    echo
    echo "Builds the scripts distribution in ./dist/"
    echo
}

build() {
    echo "Building scripts distribution..."

    # Clean up existing build
    rm -rf ./dist

    # Create distribution directory
    cp -r ./src ./dist
    mkdir -p ./dist/bin

    # Create symlinks in dist/bin for easy access (both .sh and .py files)
    for script in ./dist/bin/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script" .sh)
            ln -sf "$(pwd)/$script" "./dist/bin/$script_name"
        fi
    done
    
    for script in ./dist/bin/*.py; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script" .py)
            ln -sf "$(pwd)/$script" "./dist/bin/$script_name"
        fi
    done

    # Make all scripts executable
    chmod +x ./dist/bin/*.sh 2>/dev/null || true
    chmod +x ./dist/bin/*.py 2>/dev/null || true
    chmod +x ./dist/bin/* 2>/dev/null || true

    echo "Build complete. Distribution available in ./dist/"
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) build_help ;;
        *) build ;;
    esac
}

main "$@" 