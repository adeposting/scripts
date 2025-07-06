#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

deleter_help() {
    shlog _begin-help-text
    echo
    echo "deleter.sh - Secure file deletion utility"
    echo
    echo "  Usage: $0 [OPTIONS] <target>"
    echo
    echo "Description:"
    echo "  Securely deletes files and directories using shred or rm -rf fallback."
    echo "  By default: recursive, includes hidden files, respects .gitignore"
    echo
    if command -v lister >/dev/null 2>&1; then
        lister _print-common-help
    else
        echo "File Selection Options:"
        echo "  --include PATTERN       include files matching pattern"
        echo "  --exclude PATTERN       exclude files matching pattern"
        echo "  --no-hidden             exclude hidden files"
        echo "  --no-gitignore          don't respect .gitignore"
        echo "  --no-recursive          don't search recursively"
        echo "  --follow-symlinks       follow symbolic links"
    fi
    echo
    echo "Deleter Options:"
    echo "  --secure               use shred for secure deletion (if available)"
    echo "  --force                skip confirmation prompts"
    echo
    if command -v shlog >/dev/null 2>&1; then
        shlog _print-common-help
    else
        echo "Logging Options:"
        echo "  --quiet                 set shlog level to warn"
        echo "  --verbose               set shlog level to debug"
        echo "  --log-level LEVEL       set shlog level explicitly"
        echo "  --log-file FILE         shlog file path"
    fi
    echo
    echo "Examples:"
    echo "  $0 file.txt                    # delete single file"
    echo "  $0 --secure directory/         # securely delete directory"
    echo "  $0 --include '\\.tmp$' .       # delete only .tmp files"
    echo
    shlog _end-help-text
}

deleter() {
    local target=""
    local secure=false
    local force=false
    local lister_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --secure)
                secure=true
                shift
                ;;
            --force)
                force=true
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
            --help|-h)
                deleter_help
                return 0
                ;;
            --*)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    echo "Error: Unknown option: $1" >&2
                    deleter_help
                    return 1
                fi
                break
                ;;
            *)
                if [[ -z "$target" ]]; then
                    target="$1"
                else
                    echo "Error: Multiple targets not supported" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate target
    if [[ -z "$target" ]]; then
        echo "Error: Target is required" >&2
        deleter_help
        return 1
    fi
    
    # Check if target exists
    if [[ ! -e "$target" ]]; then
        echo "Error: Target does not exist: $target" >&2
        return 1
    fi
    
    # Get files using lister if target is a directory
    local files_to_delete=()
    if [[ -d "$target" ]]; then
        # Change to target directory for relative paths
        cd "$target" || return 1
        
        # Get files using lister
        local files
        if command -v lister >/dev/null 2>&1; then
            if [[ ${#lister_args[@]} -gt 0 ]]; then
                files=$(lister _get-files "${lister_args[@]}")
            else
                files=$(lister _get-files)
            fi
        else
            echo "Error: lister command not available" >&2
            return 1
        fi
        
        if [[ -n "$files" ]]; then
            while IFS= read -r file; do
                files_to_delete+=("$target/$file")
            done <<< "$files"
        fi
    else
        # Single file
        files_to_delete+=("$target")
    fi
    
    if [[ ${#files_to_delete[@]} -eq 0 ]]; then
        if command -v shlog >/dev/null 2>&1; then
            shlog info "No files found to delete"
        else
            echo "No files found to delete"
        fi
        return 0
    fi
    
    # Confirm deletion unless forced
    if [[ "$force" != "true" ]]; then
        echo "About to delete ${#files_to_delete[@]} items:"
        for file in "${files_to_delete[@]}"; do
            echo "  $file"
        done
        echo
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deletion cancelled"
            return 0
        fi
    fi
    
    # Check for shred availability
    if [[ "$secure" == "true" ]]; then
        if ! command -v shred >/dev/null 2>&1; then
            if command -v shlog >/dev/null 2>&1; then
                shlog info "shred not available, will use rm -rf as fallback"
            else
                echo "shred not available, will use rm -rf as fallback"
            fi
            secure=false
        fi
    fi
    
    # Delete files
    local deleted_count=0
    for file in "${files_to_delete[@]}"; do
        if [[ "$secure" == "true" ]]; then
            if command -v shlog >/dev/null 2>&1; then
                shlog info "Securely shredding $file using shred..."
            else
                echo "Securely shredding $file using shred..."
            fi
            shred -u "$file" && ((deleted_count++))
        else
            if command -v shlog >/dev/null 2>&1; then
                shlog info "Fallback, deleting $file with rm -rf"
            else
                echo "Fallback, deleting $file with rm -rf"
            fi
            rm -rf "$file" && ((deleted_count++))
        fi
    done
    
    if command -v shlog >/dev/null 2>&1; then
        shlog info "Successfully deleted $deleted_count items"
    else
        echo "Successfully deleted $deleted_count items"
    fi
}

deleter "$@"
