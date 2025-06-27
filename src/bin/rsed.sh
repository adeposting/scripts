#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

rsed_help() {
    if command -v color >/dev/null 2>&1; then
        color set bright-white
    fi
    echo
    echo "rsed.sh"
    echo "  Usage: $0 [options] <sed-script> [path ...]"
    echo
    echo "Recursive sed utility for batch editing files."
    echo
    echo "Options:"
    echo "  -i[SUFFIX]   → edit files in place (optionally create backup)"
    echo "  --include    → only include files matching pattern"
    echo "  --exclude    → exclude files matching pattern"
    echo "  --no-hidden  → skip hidden files"
    echo "  -h, --help   → show this help text"
    echo
    if command -v color >/dev/null 2>&1; then
        color reset
    fi
}

# --- Detect and configure sed implementation ---
_rsed_configure_sed() {
    local os_type
    os_type=$(ostype get 2>/dev/null || echo "Unknown")
    
    if [[ "$os_type" == "Darwin" ]]; then
        if command -v gsed >/dev/null 2>&1; then
            SED_CMD="gsed"
            SED_EXTENDED="-E"
        else
            SED_CMD="sed"
            SED_EXTENDED="-E"
        fi
    else
        # Linux or other Unix-like systems
        SED_CMD="sed"
        SED_EXTENDED="-E"
    fi
}

# --- Build sed command ---
_rsed_build_sed_command() {
    local script="$1"
    local files="$2"
    
    # Start with sed command
    local cmd="$SED_CMD"
    
    # Add options
    if [[ "$QUIET" == "1" ]]; then
        cmd="$cmd -n"
    fi
    
    if [[ "$DEBUG" == "1" ]]; then
        cmd="$cmd --debug"
    fi
    
    if [[ -n "$IN_PLACE" ]]; then
        cmd="$cmd -i$IN_PLACE"
    fi
    
    if [[ -n "$LINE_LENGTH" ]]; then
        cmd="$cmd -l $LINE_LENGTH"
    fi
    
    if [[ "$POSIX" != "1" ]]; then
        cmd="$cmd $SED_EXTENDED"
    fi
    
    if [[ "$UNBUFFERED" == "1" ]]; then
        cmd="$cmd -u"
    fi
    
    if [[ "$NULL_DATA" == "1" ]]; then
        cmd="$cmd -z"
    fi
    
    # Always use separate mode for recursive processing
    cmd="$cmd -s"
    
    # Add the script
    cmd="$cmd '$script'"
    
    # Add files
    if [[ -n "$files" ]]; then
        cmd="$cmd $files"
    fi
    
    echo "$cmd"
}

# --- Main rsed function ---
rsed() {
    local script=""
    local IN_PLACE=""
    local LINE_LENGTH=""
    local POSIX=""
    local UNBUFFERED=""
    local NULL_DATA=""
    local QUIET=""
    local DEBUG=""
    local lister_args=()
    local shlog_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--quiet|--silent)
                QUIET="1"
                shift
                ;;
            --debug)
                DEBUG="1"
                shift
                ;;
            -i|--in-place)
                IN_PLACE=""
                shift
                ;;
            -i*)
                IN_PLACE="${1#-i}"
                shift
                ;;
            --in-place=*)
                IN_PLACE="${1#--in-place=}"
                shift
                ;;
            -l|--line-length)
                LINE_LENGTH="$2"
                shift 2
                ;;
            --line-length=*)
                LINE_LENGTH="${1#--line-length=}"
                shift
                ;;
            --posix)
                POSIX="1"
                shift
                ;;
            -u|--unbuffered)
                UNBUFFERED="1"
                shift
                ;;
            -z|--null-data)
                NULL_DATA="1"
                shift
                ;;
            --include|--exclude|--no-hidden|--no-gitignore|--no-recursive|--follow-symlinks)
                lister_args+=("$1")
                if [[ "$1" == "--include" || "$1" == "--exclude" ]]; then
                    lister_args+=("$2")
                    shift 2
                else
                    shift
                fi
                ;;
            --quiet-log|--verbose-log|--log-level|--log-file)
                shlog_args+=("$1")
                if [[ "$1" == "--log-level" || "$1" == "--log-file" ]]; then
                    shlog_args+=("$2")
                    shift 2
                else
                    shift
                fi
                ;;
            --help|-h)
                rsed_help
                return 0
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                rsed_help
                return 1
                ;;
            *)
                if [[ -z "$script" ]]; then
                    script="$1"
                else
                    echo "Error: Multiple sed scripts not supported" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Parse logging options
    if [[ ${#shlog_args[@]} -gt 0 ]]; then
        local remaining_shlog_args
        if ! remaining_shlog_args=$(shlog _parse-options "${shlog_args[@]}"); then
            return 1
        fi
    fi
    
    # Check if script was provided
    if [[ -z "$script" ]]; then
        echo "Error: sed script is required" >&2
        rsed_help
        return 1
    fi
    
    # Configure sed implementation
    _rsed_configure_sed
    
    # Get files using lister
    local files
    if command -v lister >/dev/null 2>&1; then
        if [[ ${#lister_args[@]} -gt 0 ]]; then
            files=$(lister _get-files "${lister_args[@]}")
        else
            files=$(lister _get-files)
        fi
    else
        # Fallback: use find if lister is not available
        if [[ ${#lister_args[@]} -gt 0 ]]; then
            echo "Warning: lister command not available, using basic find fallback" >&2
        fi
        files=$(find . -type f -name "*.txt" 2>/dev/null | head -10)
    fi
    
    if [[ -z "$files" ]]; then
        echo "No files found matching criteria" >&2
        return 0
    fi
    
    # Build and execute sed command
    local sed_cmd
    sed_cmd=$(_rsed_build_sed_command "$script" "$files")
    
    # Execute the command
    eval "$sed_cmd"
}

rsed "$@"
