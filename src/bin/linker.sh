#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

linker_help() {
    shlog _begin-help-text
    echo
    echo "linker.sh - Create symlinks from source to destination"
    echo
    echo "  Usage: $0 --source <dir> --destination <dir> [OPTIONS] [--force] [--rename <sed-expr>]"
    echo
    echo "Description:"
    echo "  Creates symlinks from files in source directory to destination directory."
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
    echo "Linker Options:"
    echo "  --source <dir>          source directory containing files to link"
    echo "  --destination <dir>     destination directory for symlinks"
    echo "  --force                 overwrite existing files in destination"
    echo "  --rename <sed-expr>     sed expression to rename files (extended regex)"
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
    echo "  $0 --source ~/config --destination ~/.config"
    echo "  $0 --source ~/config --destination ~/.config --no-hidden"
    echo "  $0 --source ~/config --destination ~/.config --include '\\.conf$'"
    echo "  $0 --source ~/config --destination ~/.config --rename 's/config\\.sh$/.conf/'"
    echo "  $0 --source ~/config --destination ~/.config --rename 's/^([^/]+)\\.sh$/\1.conf/'"
    echo
    shlog _end-help-text
}

linker() {
    local source_dir=""
    local destination_dir=""
    local force=false
    local rename_expr=""
    local lister_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source)
                if [[ $# -lt 2 ]]; then
                    shlog error "--source requires a directory"
                    linker_help
                    return 1
                fi
                source_dir="$2"
                shift 2
                ;;
            --destination)
                if [[ $# -lt 2 ]]; then
                    shlog error "--destination requires a directory"
                    linker_help
                    return 1
                fi
                destination_dir="$2"
                shift 2
                ;;
            --force)
                force=true
                shift
                ;;
            --rename)
                if [[ $# -lt 2 ]]; then
                    shlog error "--rename requires a sed expression"
                    linker_help
                    return 1
                fi
                rename_expr="$2"
                shift 2
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
                linker_help
                return 0
                ;;
            --*)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    shlog error "Unknown option: $1"
                    linker_help
                    return 1
                fi
                break
                ;;
            *)
                shlog error "Unknown option: $1" >&2
                linker_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$source_dir" || -z "$destination_dir" ]]; then
        shlog error "--source and --destination are required"
        linker_help
        return 1
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        shlog error "Source directory does not exist: $source_dir"
        return 1
    fi
    
    if [[ ! -d "$destination_dir" ]]; then
        shlog error "Destination directory does not exist: $destination_dir"
        return 1
    fi
    
    # Change to source directory for relative paths
    cd "$source_dir" || return 1
    
    shlog info "Linking from: $source_dir"
    shlog info "Linking into: $destination_dir"
    if [[ -n "$rename_expr" ]]; then
        shlog info "Using rename expression: $rename_expr"
    fi
    
    # Get files using lister
    local files
    if command -v lister >/dev/null 2>&1; then
        if [[ ${#lister_args[@]} -gt 0 ]]; then
            files=$(lister _get-files "${lister_args[@]}")
        else
            files=$(lister _get-files)
        fi
    else
        shlog error "lister command not available"
        return 1
    fi
    
    if [[ -z "$files" ]]; then
        shlog info "No files found to link"
        return 0
    fi
    
    # Check for existing files in destination
    local existing_files=()
    while IFS= read -r file; do
        local dest_path="$destination_dir/$file"
        
        # Apply rename expression if provided
        if [[ -n "$rename_expr" ]]; then
            local renamed_file
            renamed_file=$(echo "$file" | sed -E "$rename_expr")
            dest_path="$destination_dir/$renamed_file"
        fi
        
        if [[ -e "$dest_path" ]]; then
            existing_files+=("$dest_path")
        fi
    done <<< "$files"
    
    # Report existing files if not forcing
    if [[ ${#existing_files[@]} -gt 0 && "$force" != "true" ]]; then
        shlog error "The following files already exist in destination:"
        for path in "${existing_files[@]}"; do
            echo "  $path" >&2
        done
        shlog error "Use --force to override existing files"
        return 1
    fi
    
    # Create symlinks
    local linked_count=0
    while IFS= read -r file; do
        local src_path="$source_dir/$file"
        local dst_path="$destination_dir/$file"
        
        # Apply rename expression if provided
        if [[ -n "$rename_expr" ]]; then
            local renamed_file
            renamed_file=$(echo "$file" | sed -E "$rename_expr")
            dst_path="$destination_dir/$renamed_file"
        fi
        
        # Create destination directory if it doesn't exist
        local dst_dir
        dst_dir=$(dirname "$dst_path")
        if [[ ! -d "$dst_dir" ]]; then
            mkdir -p "$dst_dir" || {
                shlog error "Failed to create directory: $dst_dir"
                continue
            }
        fi
        
        # Remove existing file if forcing
        if [[ "$force" == "true" && -e "$dst_path" ]]; then
            rm -f "$dst_path"
        fi
        
        # Create symlink
        if ln -s "$src_path" "$dst_path" 2>/dev/null; then
            shlog info "Linked: $src_path → $dst_path"
            ((linked_count++))
        else
            shlog error "Failed to link: $src_path → $dst_path"
        fi
    done <<< "$files"
    
    shlog info "Successfully linked $linked_count files"
}

linker "$@"
