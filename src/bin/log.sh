#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include color

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
    echo "  LOG_FILE=/path     also log to file"
    echo
    echo "Integration:"
    echo "  You can source this script in another Bash script to reuse its functions:"
    echo "    source /path/to/log.sh"
    echo
    echo "  This will make the following functions available:"
    echo "    log        → main logging function (log <level> <message>)"
    echo "    log_debug  → shortcut for log debug ..."
    echo "    log_info   → shortcut for log info ..."
    echo "    log_note   → shortcut for log note ..."
    echo "    log_warn   → shortcut for log warn ..."
    echo "    log_error  → shortcut for log error ..."
    echo
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

# --- Determine log level from environment ---
_resolve_log_level() {
    if [[ -n "${VERBOSE:-}" && -n "${QUIET:-}" ]]; then
        echo "Cannot set VERBOSE and QUIET at the same time" >&2
        exit 1
    fi

    if [[ -n "${LOG_LEVEL:-}" ]]; then
        echo "${LOG_LEVEL,,}"
    elif [[ -n "${QUIET:-}" ]]; then
        echo "warn"
    elif [[ -n "${DEBUG:-}" ]]; then
        echo "debug"
    elif [[ -n "${VERBOSE:-}" ]]; then
        echo "debug"
    else
        echo "info"
    fi
}

# --- Flush the log stdout/stderr buffer ---
_flush_log_buffer() {
    sleep 0
}

# --- Main log function ---
log() {
local level="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    [[ -z "$level" ]] && level="info"
    shift || true
    [[ -z "$level" ]] && return 1

    local effective_level="$(_resolve_log_level)"
    local level_rank="$(_log_level_rank "$level")"
    local effective_rank="$(_log_level_rank "$effective_level")"

    [[ "$level_rank" -lt "$effective_rank" ]] && return 0

    local now color reset label line
    now="$(date +'%Y-%m-%d %H:%M:%S')"
    color="$(get_color "$(_log_level_to_color "$level")")"
    reset="$(get_color reset)"
    label="$(echo "$level" | tr '[:lower:]' '[:upper:]')"
    line="${color}[${label}]${reset} [$now] $*"

    echo -e "$line"
    [[ -n "${LOG_FILE:-}" ]] && echo "[${label}] [$now] $*" >> "$LOG_FILE"
    [[ "$level" == "error" ]] && exit 1

    _flush_log_buffer
}

# --- Convenience wrappers ---
log_debug() { log debug "$@"; }
log_info()  { log info "$@"; }
log_note()  { log note "$@"; }
log_warn()  { log warn "$@"; }
log_error() { log error "$@"; }

# --- Execution and Export Handling ---
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f log log_debug log_info log_note log_warn log_error
else
    if ! log "$@"; then
        _help
        exit 1
    fi
fi
