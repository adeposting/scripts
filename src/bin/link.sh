#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include log
include debug

_help() {
    echo
    echo "link.sh"
    echo
    echo "  Recursively links files from --source to --destination"
    echo
    echo "Required options:"
    echo "  --source        source directory"
    echo "  --destination   destination directory"
    echo
    echo "Optional:"
    echo "  --include REGEX     include only files matching this regex"
    echo "  --exclude REGEX     exclude files matching this regex"
    echo "  --force             use 'ln -f' to overwrite existing files"
    echo "  --dry-run           simulate actions without writing anything"
    echo
    echo "Logging:"
    echo "  --quiet             set log level to warn"
    echo "  --verbose           set log level to debug"
    echo "  --log-level LEVEL   set log level explicitly"
    echo "  --log-file FILE     log file path"
    echo
    echo "Usage:"
    echo "  ./link.sh --source ./src --destination ./dst [options]"
    echo
    echo "Integration:"
    echo "  When sourced, this script exports the 'link' function:"
    echo "    source /path/to/link.sh"
    echo "    link --source ./src --destination ./dst [options]"
    echo
}

link() {
    local include_regex=".*"
    local exclude_regex=""
    local source_dir=""
    local destination_dir=""
    local force=0
    local dry_run=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --include)     include_regex="$2"; shift 2 ;;
            --exclude)     exclude_regex="$2"; shift 2 ;;
            --source)      source_dir="$2"; shift 2 ;;
            --destination) destination_dir="$2"; shift 2 ;;
            --force)       force=1; shift ;;
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

    [[ -z "$source_dir" || -z "$destination_dir" ]] && {
        log_error "--source and --destination are required"
    }

    [[ ! -d "$source_dir" ]] && {
        log_error "Source directory does not exist: $source_dir"
    }

    source_dir="$(cd "$source_dir" && pwd)"
    destination_dir="$(mkdir -p "$destination_dir" && cd "$destination_dir" && pwd)"

    log_info "Linking from: $source_dir"
    log_info "Linking into: $destination_dir"

    local files
    IFS=$'\n' read -rd '' -a files < <(
        find "$source_dir" -type f | grep -E "$include_regex" | {
            if [[ -n "$exclude_regex" ]]; then
                grep -Ev "$exclude_regex"
            else
                cat
            fi
        }
    )

    if [[ "$force" -eq 0 ]]; then
        local conflicts=()
        for src in "${files[@]}"; do
            local rel="${src#$source_dir/}"
            local dst="$destination_dir/$rel"
            if [[ -e "$dst" || -L "$dst" ]]; then
                conflicts+=("$dst")
            fi
        done

        if [[ "${#conflicts[@]}" -gt 0 ]]; then
            log_error "The following files already exist in destination:"
            for path in "${conflicts[@]}"; do
                log_error "  $path"
            done
            log_error "Use --force to override existing files"
        fi
    fi

    for src in "${files[@]}"; do
        local rel="${src#$source_dir/}"
        local dst="$destination_dir/$rel"
        local dst_dir
        dst_dir="$(dirname "$dst")"

        mkdir -p "$dst_dir"

        if [[ ! "$dry_run" -eq 1 ]]; then
            if [[ "$force" -eq 1 ]]; then
                ln -sf "$src" "$dst"
            else
                ln -s "$src" "$dst"
            fi
        fi
        log_note "Linked: $src → $dst"
    done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    link "$@"
else
    export -f link
fi
