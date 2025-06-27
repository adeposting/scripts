#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

lister_help() {
    color set bright-white
    echo
    echo "lister.sh - File listing utility"
    echo
    echo "  Usage: $0 [OPTIONS] [PATH...]"
    echo
    echo "Description:"
    echo "  Lists files and directories with git-aware filtering."
    echo "  By default: recursive, includes hidden files, respects .gitignore"
    echo
    _lister_print_common_help
    echo
    echo "Examples:"
    echo "  $0                      # list all files in current directory recursively"
    echo "  $0 --no-hidden          # exclude hidden files"
    echo "  $0 --include '\\.txt$'  # only .txt files"
    echo "  $0 --exclude '\\.git'   # exclude .git directory"
    echo "  $0 --no-recursive       # current directory only"
    echo "  $0 /path/to/dir         # list specific directory"
    echo
    color reset
}

# --- Internal function: Print common help text for other scripts ---
_lister_print_common_help() {
    echo "Options:"
    echo "  --include <pattern>     include files matching regex pattern"
    echo "  --exclude <pattern>     exclude files matching regex pattern"
    echo "  --no-hidden            exclude hidden files and directories"
    echo "  --no-gitignore         ignore .gitignore rules"
    echo "  --no-recursive         list only current directory (no subdirectories)"
    echo "  --follow-symlinks      follow symbolic links"
    echo "  --help, -h             show this help text"
    echo
    echo "Arguments:"
    echo "  [PATH...]              paths to process (defaults to current directory)"
}

# --- Internal function: Get filtered file list for other scripts ---
_lister_get_files() {
    local paths=""
    local INCLUDE_PATTERN=""
    local EXCLUDE_PATTERN=""
    local NO_HIDDEN=""
    local NO_GITIGNORE=""
    local NO_RECURSIVE=""
    local FOLLOW_SYMLINKS=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --include)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --include requires a pattern" >&2
                    return 1
                fi
                INCLUDE_PATTERN="$2"
                shift 2
                ;;
            --exclude)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --exclude requires a pattern" >&2
                    return 1
                fi
                EXCLUDE_PATTERN="$2"
                shift 2
                ;;
            --no-hidden)
                NO_HIDDEN="1"
                shift
                ;;
            --no-gitignore)
                NO_GITIGNORE="1"
                shift
                ;;
            --no-recursive)
                NO_RECURSIVE="1"
                shift
                ;;
            --follow-symlinks)
                FOLLOW_SYMLINKS="1"
                shift
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                return 1
                ;;
            *)
                # Additional arguments are paths
                if [[ -z "$paths" ]]; then
                    paths="$1"
                else
                    paths="$paths $1"
                fi
                shift
                ;;
        esac
    done
    
    # Build find command
    local find_cmd
    find_cmd=$(_build_find_cmd "$paths")
    
    # Execute find and filter results
    local files
    files=$(eval "$find_cmd" 2>/dev/null | sort)
    
    if [[ -z "$files" ]]; then
        echo "No files found matching criteria" >&2
        return 0
    fi
    
    # Filter files based on git status and .gitignore
    _filter_files "$files"
}

# --- Check if we're in a git repository ---
_is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# --- Get git status for files ---
_get_git_status() {
    local file="$1"
    
    if ! _is_git_repo; then
        return 0  # Not in git repo, file is "tracked"
    fi
    
    # Check if file exists first
    if [[ ! -e "$file" ]]; then
        return 1  # File doesn't exist
    fi
    
    # Get git status for the file
    local status
    status=$(git status --porcelain "$file" 2>/dev/null)
    
    if [[ -z "$status" ]]; then
        return 0  # File is tracked and clean
    fi
    
    # Check if it's a deleted file that's not staged
    if [[ "$status" =~ ^\?\? ]]; then
        return 0  # Untracked file, include it
    elif [[ "$status" =~ ^\ D ]]; then
        return 1  # Deleted file, exclude it
    else
        return 0  # Modified/staged file, include it
    fi
}

# --- Check if file should be ignored by .gitignore ---
_is_gitignored() {
    local file="$1"
    
    if ! _is_git_repo; then
        return 1  # Not in git repo, not ignored
    fi
    
    # Use git check-ignore to see if file is ignored
    git check-ignore --quiet "$file" 2>/dev/null
}

# --- Build find command with options ---
_build_find_cmd() {
    local paths="$1"
    local include_pattern="${INCLUDE_PATTERN:-}"
    local exclude_pattern="${EXCLUDE_PATTERN:-}"
    local no_hidden="${NO_HIDDEN:-}"
    local no_recursive="${NO_RECURSIVE:-}"
    local follow_symlinks="${FOLLOW_SYMLINKS:-}"
    
    # If no paths provided, use current directory
    if [[ -z "$paths" ]]; then
        paths="."
    fi
    
    # Start with find command
    local find_cmd="find $paths"
    
    # Add type filter
    find_cmd="$find_cmd -type f"
    
    # Add recursion control
    if [[ "$no_recursive" == "1" ]]; then
        find_cmd="$find_cmd -maxdepth 1"
    fi
    
    # Add symlink following
    if [[ "$follow_symlinks" == "1" ]]; then
        find_cmd="$find_cmd -follow"
    fi
    
    # Add hidden file filter
    if [[ "$no_hidden" == "1" ]]; then
        find_cmd="$find_cmd ! -name '.*'"
    fi
    
    # Add include pattern if specified
    if [[ -n "$include_pattern" ]]; then
        # For testing, always include files
        find_cmd="$find_cmd -regex '$include_pattern'"
    fi
    
    # Add exclude pattern if specified
    if [[ -n "$exclude_pattern" ]]; then
        find_cmd="$find_cmd ! -regex '$exclude_pattern'"
    fi
    
    echo "$find_cmd"
}

# --- Filter files based on git status and .gitignore ---
_filter_files() {
    local files="$1"
    local no_gitignore="${NO_GITIGNORE:-}"
    
    while IFS= read -r file; do
        # Skip empty lines
        [[ -z "$file" ]] && continue
        
        # Check if file should be ignored by .gitignore
        if [[ "$no_gitignore" != "1" ]] && _is_gitignored "$file"; then
            continue
        fi
        
        # Check git status
        if _get_git_status "$file"; then
            echo "$file"
        fi
    done <<< "$files"
}

# --- Main lister function ---
lister() {
    local cmd="${1:-}"
    case "$cmd" in
        _get-files)
            shift
            _lister_get_files "$@"
            ;;
        _print-common-help)
            _lister_print_common_help
            ;;
        help|--help|-h)
            lister_help
            return 0
            ;;
        *)
            # Default behavior: list files
            _lister_get_files "$@"
            ;;
    esac
}

lister "$@" 