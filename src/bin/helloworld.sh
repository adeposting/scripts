#!/bin/bash

set -oue pipefail

helloworld_help() {
    color set bright-white
    echo
    echo "helloworld.sh"
    echo "  Usage: $0 [help|--help|-h]"
    echo
    echo "Commands:"
    echo "  help|--help|-h  → prints this help text"
    echo
    echo "If no command is given, the script just prints"
    echo "the message 'hello world'" 
    echo
    color reset
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
