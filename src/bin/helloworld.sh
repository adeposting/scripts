#!/bin/bash

set -oue pipefail

helloworld_help() {
    shlog _begin-help-text
    echo
    echo "helloworld.sh"
    echo
    echo "  Usage: $0 [OPTIONS]"
    echo
    echo "Description:"
    echo "  A simple hello world script for testing purposes."
    echo
    echo "Commands:"
    echo "  (default)               prints hello world"
    echo "  help, --help, -h        prints this help text"
    echo
    echo "Options:"
    echo "  --name <name>           specify a custom name (default: World)"
    echo
    shlog _end-help-text
}

helloworld() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) helloworld_help ;;
        "") echo "hello world";;
        *) helloworld_help ;;
    esac
}

helloworld "$@"
