#!/bin/bash

set -oue pipefail

_help() {
    echo
    echo "debug.sh"
    echo
    echo "  Usage: $0 <command>"
    echo
    echo "Commands:"
    echo "  enable        → Enable debugging (DEBUG=1, -x)"
    echo "  disable       → Disable debugging (NDEBUG=1, +x)"
    echo "  restore       → Restore previous debug mode from stack"
    echo "  is_enabled    → Exit with error if not enabled"
    echo "  help          → Show this help message"
    echo
    echo "Integration:"
    echo "  Source this script in other scripts:"
    echo "    source /path/to/debug.sh"
    echo
    echo "  Exported functions:"
    echo "    enable_debug_mode"
    echo "    disable_debug_mode"
    echo "    restore_debug_mode"
    echo "    is_debug_enabled"
    echo
}

# Internal stack for previous debug states
__DEBUG_STACK=()

# Helper: is shell tracing on?
__is_tracing_enabled() {
    [[ $- == *x* ]]
}

# Check if debugging is currently enabled
is_debug_enabled() {
    __is_tracing_enabled
}

# Push current state (DEBUG/NDEBUG + -x status)
__push_debug_state() {
    local state=""
    if [[ -n "${DEBUG:-}" ]]; then state+="DEBUG=1 "; fi
    if [[ -n "${NDEBUG:-}" ]]; then state+="NDEBUG=1 "; fi
    if __is_tracing_enabled; then state+="TRACE=1 "; fi
    __DEBUG_STACK+=("$state")
}

# Pop state and restore DEBUG/NDEBUG/-x exactly
restore_debug_mode() {
    local saved="${__DEBUG_STACK[-1]:-}"
    unset '__DEBUG_STACK[-1]'

    unset DEBUG NDEBUG
    set +x

    for part in $saved; do
        case "$part" in
            DEBUG=1) export DEBUG=1 ;;
            NDEBUG=1) export NDEBUG=1 ;;
            TRACE=1) set -x ;;
        esac
    done
}

enable_debug_mode() {
    __push_debug_state
    export DEBUG=1
    unset NDEBUG
    set -x
}

disable_debug_mode() {
    __push_debug_state
    export NDEBUG=1
    unset DEBUG
    set +x
}

_main() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        enable)  enable_debug_mode ;;
        disable) disable_debug_mode ;;
        restore) restore_debug_mode ;;
        is_enabled) return is_debug_enabled ;;
        help|--help|-h) _help ;;
        *) _help; return 1 ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
else
    [[ ! -z "${DEBUG:-}" ]] && enable_debug_mode
    export -f enable_debug_mode
    export -f disable_debug_mode
    export -f restore_debug_mode
    export -f is_debug_enabled
fi
