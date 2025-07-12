#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

rcat_help() {
    shlog _begin-help-text
    echo
    echo "rcat.sh - Recursive cat utility"
    echo
    echo "  Usage: $0 [OPTIONS] <PATH> [PATHS...]"
    echo
    echo "Description:"
    echo "  Recursively prints the contents of all files. Includes hidden" 
    echo "  files and respects .gitignore by default."
    echo
    echo "Arguments:"
    echo "  PATH       The path to a file or directory to process."
    echo "  PATHS...   Additional paths to process."
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
    shlog _print-common-help
    echo
    echo "Examples:"
    echo "  $0 src/"                      # print all files in src/ directory
    echo "  $0 --include '\\.txt$' src/"  # only .txt files in src/
    echo "  $0 file1.txt file2.txt"       # print specific files
    echo
    echo "Example with directory structure:"
    echo "  src/"
    echo "    ├── file1.txt"
    echo "    └── file2.txt"
    echo
    echo "Output:"
    echo "  file1.txt"
    echo
    echo "  \`\`\`"
    echo "  content of file1"
    echo "  \`\`\`"
    echo
    echo "  file2.txt"
    echo
    echo "  \`\`\`"
    echo "  content of file2"
    echo "  \`\`\`"
    echo
    shlog _end-help-text
}

# --- Main rcat function ---
rcat() {
    local paths=()
    local lister_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
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
                rcat_help
                return 0
                ;;
            --*)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    echo "Error: Unknown option $1" >&2
                    rcat_help
                    return 1
                fi
                break
                ;;
            *)
                paths+=("$1")
                shift
                ;;
        esac
    done
    
    # Check if paths were provided
    if [[ ${#paths[@]} -eq 0 ]]; then
        echo "Error: No input paths provided." >&2
        rcat_help
        return 1
    fi
    
    # Process each path
    for input_path in "${paths[@]}"; do
        case "$input_path" in
            /*) abs_path="$input_path" ;;
            *) abs_path="$(pwd)/$input_path" ;;
        esac
        
        if [[ -f "$abs_path" ]]; then
            # Single file
            root_dir=$(dirname "$abs_path")
            if command -v lister >/dev/null 2>&1; then
                if [[ ${#lister_args[@]} -gt 0 ]]; then
                    files=$(lister _get-files "${lister_args[@]}" "$abs_path")
                else
                    files=$(lister _get-files "$abs_path")
                fi
            else
                # Fallback: just use the file itself
                files="$abs_path"
            fi
        elif [[ -d "$abs_path" ]]; then
            # Directory
            root_dir="$abs_path"
            if command -v lister >/dev/null 2>&1; then
                if [[ ${#lister_args[@]} -gt 0 ]]; then
                    files=$(lister _get-files "${lister_args[@]}" "$abs_path")
                else
                    files=$(lister _get-files "$abs_path")
                fi
            else
                # Fallback: use find
                echo "Warning: lister command not available, using basic find fallback" >&2
                files=$(find "$abs_path" -type f 2>/dev/null | head -10)
            fi
        else
            echo "Skipping invalid path: $input_path" >&2
            continue
        fi
        
        if [[ -z "$files" ]]; then
            echo "No files found matching criteria for: $input_path" >&2
            continue
        fi
        
        # Process each file
        echo "$files" | while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                rel_path="${file#$root_dir/}"
                
                echo "$rel_path"
                echo
                echo '```'
                cat "$file"
                echo '```'
                echo
            fi
        done
    done
}

rcat "$@"
