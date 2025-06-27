#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

unlinker_help() {
    color set bright-white
    echo
    echo "unlinker.sh - Remove symlinks and clean up broken links"
    echo
    echo "  Usage: $0 [--source <dir>] [--destination <dir>] [OPTIONS] [--dry-run]"
    echo
    echo "Description:"
    echo "  Removes symlinks and cleans up broken links in specified directories."
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
    echo "Unlinker Options:"
    echo "  --source <dir>          source directory to unlink from"
    echo "  --destination <dir>     destination directory to clean"
    echo "  --dry-run               simulate actions without removing anything"
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
    echo "  $0 --destination ~/.config              # clean broken links in ~/.config"
    echo "  $0 --source ~/config --no-hidden       # unlink from source, exclude hidden"
    echo "  $0 --destination ~/.config --dry-run   # simulate cleanup"
    echo
    color reset
}

unlinker() {
    local source=""
    local destination=""
    local dry_run=false
    local lister_args=()
    local shlog_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --source requires a directory" >&2
                    unlinker_help
                    return 1
                fi
                source="$2"
                shift 2
                ;;
            --destination)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --destination requires a directory" >&2
                    unlinker_help
                    return 1
                fi
                destination="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
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
            --quiet|--verbose|--log-level|--log-file)
                shlog_args+=("$1")
                if [[ "$1" == "--log-level" || "$1" == "--log-file" ]]; then
                    shlog_args+=("$2")
                    shift 2
                else
                    shift
                fi
                ;;
            --help|-h)
                unlinker_help
                return 0
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                unlinker_help
                return 1
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
    
    # Validate that at least one directory is specified
    if [[ -z "$source" && -z "$destination" ]]; then
        echo "At least one of --source or --destination must be provided" >&2
        return 1
    fi
    
    if [[ -n "$source" && ! -d "$source" ]]; then
        echo "Error: Source directory does not exist: $source" >&2
        return 1
    fi
    
    if [[ -n "$destination" && ! -d "$destination" ]]; then
        echo "Error: Destination directory does not exist: $destination" >&2
        return 1
    fi
    
    local unlinked_count=0
    
    # Process source directory if specified
    if [[ -n "$source" ]]; then
        if command -v shlog >/dev/null 2>&1; then
            shlog info "Unlinking based on source: $source"
        else
            echo "Unlinking based on source: $source"
        fi
        
        # Change to source directory for relative paths
        cd "$source" || return 1
        
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
                local basename_file
                basename_file=$(basename "$file")
                
                # Find and remove symlinks pointing to this file
                if [[ -n "$destination" ]]; then
                    local link_path="$destination/$basename_file"
                    if [[ -L "$link_path" ]]; then
                        if [[ "$dry_run" == "true" ]]; then
                            if command -v shlog >/dev/null 2>&1; then
                                shlog info "[dry-run] Would remove symlink: $link_path"
                            else
                                echo "[dry-run] Would remove symlink: $link_path"
                            fi
                        else
                            rm "$link_path" && {
                                if command -v shlog >/dev/null 2>&1; then
                                    shlog info "Removed symlink: $link_path"
                                else
                                    echo "Removed symlink: $link_path"
                                fi
                                ((unlinked_count++))
                            }
                        fi
                    fi
                else
                    # Search for symlinks in current directory and subdirectories
                    while IFS= read -r link; do
                        if [[ -L "$link" ]]; then
                            if [[ "$dry_run" == "true" ]]; then
                                if command -v shlog >/dev/null 2>&1; then
                                    shlog info "[dry-run] Would remove symlink: $link"
                                else
                                    echo "[dry-run] Would remove symlink: $link"
                                fi
                            else
                                rm "$link" && {
                                    if command -v shlog >/dev/null 2>&1; then
                                        shlog info "Removed symlink: $link"
                                    else
                                        echo "Removed symlink: $link"
                                    fi
                                    ((unlinked_count++))
                                }
                            fi
                        fi
                    done < <(find . -type l -name "$basename_file" 2>/dev/null)
                fi
            done <<< "$files"
        fi
    fi
    
    # Process destination directory if specified
    if [[ -n "$destination" ]]; then
        if command -v shlog >/dev/null 2>&1; then
            shlog info "Cleaning destination: $destination"
        else
            echo "Cleaning destination: $destination"
        fi
        
        # Find and remove broken symlinks
        while IFS= read -r link; do
            if [[ ! -e "$link" ]]; then
                if [[ "$dry_run" == "true" ]]; then
                    if command -v shlog >/dev/null 2>&1; then
                        shlog info "[dry-run] Would remove broken symlink: $link"
                    else
                        echo "[dry-run] Would remove broken symlink: $link"
                    fi
                else
                    rm "$link" && {
                        if command -v shlog >/dev/null 2>&1; then
                            shlog info "Removed broken symlink: $link"
                        else
                            echo "Removed broken symlink: $link"
                        fi
                        ((unlinked_count++))
                    }
                fi
            fi
        done < <(find "$destination" -type l 2>/dev/null)
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        if command -v shlog >/dev/null 2>&1; then
            shlog info "[dry-run] Would remove $unlinked_count symlinks"
        else
            echo "[dry-run] Would remove $unlinked_count symlinks"
        fi
    else
        if command -v shlog >/dev/null 2>&1; then
            shlog info "Successfully removed $unlinked_count symlinks"
        else
            echo "Successfully removed $unlinked_count symlinks"
        fi
    fi
}

unlinker "$@"