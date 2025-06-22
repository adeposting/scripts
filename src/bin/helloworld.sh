#!/bin/bash

set -oue pipefail

_help() {
    echo
    echo "helloworld.sh"
    echo
    echo "  Usage: $0 [help|--help|-h]"
    echo
    echo "Commands:"
    echo "  help|--help|-h  → prints this help text"
    echo
    echo "If no command is given, the script just prints"
    echo "the message 'hello world'" 
    echo
    echo "Integration:"
    echo "  You can source this script in another Bash script:"
    echo "    source /path/to/helloworld.sh"
    echo
    echo "  This will export the following functions:"
    echo "    hello_world → prints 'hello world'"
    echo
}

helloworld() {
    echo "hello world"
}

_main() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        help|--help|-h) _help ;;
        *) helloworld ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
else
    export -f helloworld
fi
