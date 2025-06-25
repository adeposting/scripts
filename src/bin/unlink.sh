#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include log
include debug

_help() {
    echo
    echo "unlink.sh"
    echo
    echo "  Removes symbolic links under --destination based on matches from --source"
    echo
    echo "Optional:"
    echo "  --source DIR        base source directory to compare"
    echo "  --destination DIR   base destination directory to clean"
    echo "  --include REGEX     include only files matching this regex (default: all)"
    echo "  --exclude REGEX     exclude files matching this regex (default: none)"
    echo "  --dry-run           simulate unlinking without modifying filesystem"
    echo
    echo "Logging:"
    echo "  --quiet             set log level to warn"
    echo "  --verbose           set log level to debug"
    echo "  --log-level LEVEL   set log level explicitly"
    echo "  --log-file FILE     log file path"
    echo
    echo "Usage:"
    echo "  unlink.sh [--source DIR] [--destination DIR] [options]"
    echo
    echo "Integration:"
    echo "  When sourced, this script exports the 'unlink' function:"
    echo "    source /path/to/unlink.sh"
    echo "    unlink --destination ./dst"
    echo
}

unlink() {
    local include_regex=".*"
    local exclude_regex=""
    local source_dir=""
    local destination_dir=""
    local dry_run=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --include)     include_regex="$2"; shift 2 ;;
            --exclude)     exclude_regex="$2"; shift 2 ;;
            --source)      source_dir="$2"; shift 2 ;;
            --destination) destination_dir="$2"; shift 2 ;;
            --dry-run)     dry_run=1; shift ;;
            --quiet)       export QUIET=1; shift ;;
            --verbose)     export VERBOSE=1; shift ;;
            --log-level)   export LOG_LEVEL="$2"; shift 2 ;;
            --log-file)    export LOG_FILE="$2"; shift 2 ;;
            --help|-h)     _help; return 0 ;;
            *) log_error "Unknown option: $1"; _help; return 1 ;;
        esac
    done

    get_log_level > /dev/null
    [[ -n "$LOG_FILE" ]] && set_log_file "$LOG_FILE"

    [[ -z "$source_dir" && -z "$destination_dir" ]] && {
        log_error "At least one of --source or --destination must be provided"
    }

    [[ -n "$source_dir" && ! -d "$source_dir" ]] && {
        log_error "Source directory does not exist: $source_dir"
    }

    [[ -n "$destination_dir" && ! -d "$destination_dir" ]] && {
        log_error "Destination directory does not exist: $destination_dir"
    }

    [[ -n "$source_dir" ]] && source_dir="$(cd "$source_dir" && pwd)"
    [[ -n "$destination_dir" ]] && destination_dir="$(cd "$destination_dir" && pwd)"

    [[ -n "$source_dir" ]] && log_info "Unlinking based on source: $source_dir"
    [[ -n "$destination_dir" ]] && log_info "Cleaning destination: $destination_dir"

    local targets=()

    if [[ -n "$source_dir" && -n "$destination_dir" ]]; then
        IFS=$'\n' read -rd '' -a targets < <(
            find "$source_dir" -type f | grep -E "$include_regex" | {
                if [[ -n "$exclude_regex" ]]; then
                    grep -Ev "$exclude_regex"
                else
                    cat
                fi
            }
        )
        for src in "${targets[@]}"; do
            local rel="${src#$source_dir/}"
            local dst="$destination_dir/$rel"
            if [[ -L "$dst" ]]; then
                if [[ ! "$dry_run" -eq 1 ]]; then
                    rm "$dst"
                fi
                log_note "Unlinked: $dst"
            elif [[ -e "$dst" ]]; then
                log_warn "Not a symlink, skipping: $dst"
            fi
        done

    elif [[ -n "$destination_dir" && -z "$source_dir" ]]; then
        IFS=$'\n' read -rd '' -a targets < <(
            find "$destination_dir" -type l | grep -E "$include_regex" | {
                if [[ -n "$exclude_regex" ]]; then
                    grep -Ev "$exclude_regex"
                else
                    cat
                fi
            }
        )
        for link in "${targets[@]}"; do
            if [[ ! -e "$link" ]]; then
                if [[ "$dry_run" -eq 1 ]]; then
                    log_info "[dry-run] Would remove broken symlink: $link"
                else
                    rm "$link"
                    log_note "Removed broken symlink: $link"
                fi
            fi
        done

    elif [[ -n "$source_dir" && -z "$destination_dir" ]]; then
        log_error "Cannot unlink without destination when source is given"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    unlink "$@"
else
    export -f unlink
fi