#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

LOG_LEVEL="${LOG_LEVEL:-}"
LOG_FILE="${LOG_FILE:-}"

log_help() {
    color set bright-white
    echo
    echo "shlog.sh"
    echo
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  info <msg>              → log info message"
    echo "  warn <msg>              → log warning message"
    echo "  error <msg>             → log error message"
    echo "  debug <msg>             → log debug message (if debug enabled)"
    echo "  note <msg>              → log note message"
    echo "  help, --help, -h        → show this help text"
    echo
    echo "Environment Variables:"
    echo "  VERBOSE                 → enable verbose mode (sets log level to debug)"
    echo "  QUIET                   → enable quiet mode (sets log level to warn)"
    echo "  DEBUG                   → enable debug mode (sets log level to debug)"
    echo "  LOG_LEVEL               → set log level (debug, info, note, warn, error)"
    echo "  LOG_FILE                → set log file path for output"
    echo
    echo "Setters:"
    echo "  set-verbose             → set VERBOSE=1"
    echo "  set-quiet               → set QUIET=1"
    echo "  set-debug               → set DEBUG=1"
    echo "  set-level <level>       → set LOG_LEVEL"
    echo "  set-file <path>         → set LOG_FILE"
    echo
    echo "Getters:"
    echo "  get-level               → get current LOG_LEVEL"
    echo "  get-level-number        → get current LOG_LEVEL rank number"
    echo "  get-level-color         → get current LOG_LEVEL color"
    echo "  get-file                → get current LOG_FILE"
    echo "  is-verbose              → check if verbose mode is enabled"
    echo "  is-quiet                → check if quiet mode is enabled"
    echo "  is-debug                → check if debug mode is enabled"
    echo
    color reset
}

# --- Internal function: Print common logging help text for other scripts ---
_shlog_print_common_help() {
    echo "Logging Options:"
    echo "  --quiet                 set shlog level to warn"
    echo "  --verbose               set shlog level to debug"
    echo "  --log-level LEVEL       set shlog level explicitly"
    echo "  --log-file FILE         shlog file path"
}

# --- Internal function: Parse common logging options for other scripts ---
_shlog_parse_options() {
    local args=("$@")
    local remaining_args=()
    local log_level_set=false
    
    for ((i=0; i<${#args[@]}; i++)); do
        case "${args[i]}" in
            --quiet)
                export LOG_LEVEL="warn"
                log_level_set=true
                ;;
            --verbose)
                export LOG_LEVEL="debug"
                log_level_set=true
                ;;
            --log-level)
                if [[ $((i+1)) -lt ${#args[@]} ]]; then
                    export LOG_LEVEL="${args[i+1]}"
                    log_level_set=true
                    ((i++))  # Skip next argument
                else
                    echo "Error: --log-level requires a value" >&2
                    return 1
                fi
                ;;
            --log-file)
                if [[ $((i+1)) -lt ${#args[@]} ]]; then
                    export LOG_FILE="${args[i+1]}"
                    ((i++))  # Skip next argument
                else
                    echo "Error: --log-file requires a value" >&2
                    return 1
                fi
                ;;
            *)
                remaining_args+=("${args[i]}")
                ;;
        esac
    done
    
    # Return remaining arguments
    printf '%s\n' "${remaining_args[@]}"
}

# --- Log level ranking ---
get_log_level_number() {
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
get_log_level_color() {
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
get_log_level() {
    if [[ -n "${VERBOSE:-}" && -n "${QUIET:-}" ]]; then
        echo "Cannot set VERBOSE and QUIET at the same time" >&2
        exit 1
    fi

    if [[ -n "${LOG_LEVEL:-}" ]]; then
        echo "$(echo "$LOG_LEVEL" | tr '[:upper:]' '[:lower:]')"
    elif [[ -n "${QUIET:-}" ]]; then
        echo "warn"
    elif command -v debug >/dev/null 2>&1 && debug is_enabled >/dev/null 2>&1; then
        echo "debug"
    elif [[ -n "${VERBOSE:-}" ]]; then
        echo "debug"
    else
        echo "info"
    fi
}

# --- Setters ---
set_verbose() {
    export VERBOSE=1
    echo "Verbose mode enabled"
}

set_quiet() {
    export QUIET=1
    echo "Quiet mode enabled"
}

set_debug() {
    export DEBUG=1
    echo "Debug mode enabled"
}

set_level() {
    local level="$1"
    if [[ -z "$level" ]]; then
        echo "log level required" >&2
        return 1
    fi
    LOG_LEVEL="$level"
    export LOG_LEVEL
    echo "Log level set to: $level"
}

set_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Error: log file path required" >&2
        return 1
    fi
    LOG_FILE="$file"
    export LOG_FILE
    echo "Log file set to: $file"
}

# --- Getters ---
get_file() {
    [[ -n "${LOG_FILE:-}" ]] && echo "$LOG_FILE"
}

is_verbose() {
    [[ -n "${VERBOSE:-}" ]]
}

is_quiet() {
    [[ -n "${QUIET:-}" ]]
}

is_debug() {
    [[ -n "${DEBUG:-}" ]]
}

# --- Flush output ---
_flush_log_buffer() {
    sleep 0
}

# --- Check if message should be logged based on level ---
_should_log() {
    local message_level="$1"
    local current_level
    current_level=$(get_log_level)
    
    local message_rank
    local current_rank
    message_rank=$(get_log_level_number "$message_level")
    current_rank=$(get_log_level_number "$current_level")
    
    [[ $message_rank -ge $current_rank ]]
}

log_info() {
    if _should_log "info"; then
        echo "[INFO] $*"
    fi
}

log_warn() {
    if _should_log "warn"; then
        echo "[WARN] $*" >&2
    fi
}

log_error() {
    if _should_log "error"; then
        echo "[ERROR] $*" >&2
    fi
}

log_debug() {
    if _should_log "debug"; then
        echo "[DEBUG] $*"
    fi
}

log_note() {
    if _should_log "note"; then
        echo "[NOTE] $*"
    fi
}

log() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        _print-common-help)
            _shlog_print_common_help
            ;;
        _parse-options)
            shift
            _shlog_parse_options "$@"
            ;;
        info)               log_info "$@" ;;
        warn)               log_warn "$@" ;;
        error)              log_error "$@" ;;
        debug)              log_debug "$@" ;;
        note)               log_note "$@" ;;
        set-verbose)        set_verbose ;;
        set-quiet)          set_quiet ;;
        set-debug)          set_debug ;;
        set-level)          shift; set_level "$@" ;;
        set-file)           shift; set_file "$@" ;;
        get-level)          get_log_level ;;
        get-level-number)   get_log_level_number "$(get_log_level)" ;;
        get-level-color)    get_log_level_color "$(get_log_level)" ;;
        get-file)           get_file ;;
        is-verbose)         is_verbose ;;
        is-quiet)           is_quiet ;;
        is-debug)           is_debug ;;
        help|--help|-h)     log_help ;;
        *)                  log_help; return 1 ;;
    esac
}

log "$@"
