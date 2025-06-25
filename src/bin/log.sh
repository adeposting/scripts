#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include color

LOG_LEVEL="${LOG_LEVEL:-}"
LOG_FILE="${LOG_FILE:-}"

_help() {
    echo
    echo "log.sh"
    echo
    echo "  Usage: log <level> <message>"
    echo
    echo "Levels:"
    echo "  debug   → detailed developer output"
    echo "  info    → normal runtime info"
    echo "  note    → notable event"
    echo "  warn    → warning that doesn't stop execution"
    echo "  error   → error message and exits with code 1"
    echo
    echo "Environment:"
    echo "  LOG_LEVEL=level    override default level"
    echo "  VERBOSE=1          implies LOG_LEVEL=debug"
    echo "  QUIET=1            implies LOG_LEVEL=warn"
    echo "  DEBUG=1            implies LOG_LEVEL=debug (unless QUIET)"
    echo "  LOG_FILE=/path     also log to file (no color)"
    echo
    echo "Integration:"
    echo "  Source this script:"
    echo "    source /path/to/log.sh"
    echo
    echo "  Exported functions:"
    echo "    log, log_debug, log_info, log_note, log_warn, log_error"
    echo "    get_log_level, set_log_level, get_log_file, set_log_file"
    echo
}

# --- Accessors ---
get_log_level() {
    _resolve_log_level
}

set_log_level() {
    LOG_LEVEL="$1"
}

get_log_file() {
    [[ -n "${LOG_FILE:-}" ]] && echo "$LOG_FILE"
}

set_log_file() {
    LOG_FILE="$1"
}

# --- Log level ranking ---
_log_level_rank() {
    case "$1" in
        debug) echo 0 ;;
        info)  echo 1 ;;
        note)  echo 2 ;;
        warn)  echo 3 ;;
        error) echo 4 ;;
        *)     echo 999 ;;
    esac
}

# --- Log level to color ---
_log_level_to_color() {
    case "$1" in
        debug) echo "cyan" ;;
        info)  echo "green" ;;
        note)  echo "blue" ;;
        warn)  echo "yellow" ;;
        error) echo "red" ;;
        *)     echo "white" ;;
    esac
}

# --- Determine log level ---
_resolve_log_level() {
    if [[ -n "${VERBOSE:-}" && -n "${QUIET:-}" ]]; then
        echo "Cannot set VERBOSE and QUIET at the same time" >&2
        exit 1
    fi

    if [[ -n "${LOG_LEVEL:-}" ]]; then
        echo "${LOG_LEVEL,,}"
    elif [[ -n "${QUIET:-}" ]]; then
        echo "warn"
    elif is_debug_enabled; then
        echo "debug"
    elif [[ -n "${VERBOSE:-}" ]]; then
        echo "debug"
    else
        echo "info"
    fi
}

# --- Flush output ---
_flush_log_buffer() {
    sleep 0
}

# --- Main log function ---
log() {
    local level="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    [[ -z "$level" ]] && level="info"
    shift || true

    local effective_level="$(_resolve_log_level)"
    local level_rank="$(_log_level_rank "$level")"
    local effective_rank="$(_log_level_rank "$effective_level")"

    [[ "$level_rank" -lt "$effective_rank" ]] && return 0

    local now color reset label line
    now="$(date +'%Y-%m-%d %H:%M:%S')"
    color="$(get_color "$(_log_level_to_color "$level")")"
    reset="$(get_color reset)"
    label="$(echo "$level" | tr '[:lower:]' '[:upper:]')"

    # Terminal output (colorized)
    line="${color}[${label}]${reset} [$now] $*"
    printf "%b\n" "$line"

    # Log file output (no color)
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[${label}] [$now] $*" >> "$LOG_FILE"
    fi

    [[ "$level" == "error" ]] && exit 1

    _flush_log_buffer
}

# --- Convenience wrappers ---
log_debug() { log debug "$@"; }
log_info()  { log info "$@"; }
log_note()  { log note "$@"; }
log_warn()  { log warn "$@"; }
log_error() { log error "$@"; }

# --- Export ---
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f get_log_file
    export -f get_log_level
    export -f log
    export -f log_debug
    export -f log_error
    export -f log_info
    export -f log_note
    export -f log_warn
    export -f set_log_file
    export -f set_log_level
else
    if ! log "$@"; then
        _help
        exit 1
    fi
fi
