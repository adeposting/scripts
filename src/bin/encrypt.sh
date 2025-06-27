#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

encrypt_help() {
    color set bright-white
    echo
    echo "encrypt.sh - File encryption utility"
    echo
    echo "  Usage: $0 --input <path> --output <filename> [OPTIONS]"
    echo
    echo "Description:"
    echo "  Encrypts files using GPG with automatic cleanup of source files."
    echo
    echo "Options:"
    echo "  --input <path>          input file or directory to encrypt"
    echo "  --output <filename>     output filename for encrypted archive"
    echo "  --keep                  keep source files after encryption"
    echo "  --recipient <email>     GPG recipient email (optional)"
    echo
    _shlog_print_common_help
    echo
    echo "Examples:"
    echo "  $0 --input file.txt --output encrypted.tar.gz"
    echo "  $0 --input directory/ --output backup.tar.gz --keep"
    echo "  $0 --input file.txt --output encrypted.tar.gz --recipient user@example.com"
    echo
    color reset
}

encrypt() {
    local input=()
    local output=""
    local keep=false
    local recipient=""
    local shlog_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --input)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --input requires at least one path" >&2
                    return 1
                fi
                shift
                while [[ $# -gt 0 && "$1" != "--"* ]]; do
                    input+=("$1")
                    shift
                done
                ;;
            --output)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --output requires a filename" >&2
                    return 1
                fi
                output="$2"
                shift 2
                ;;
            --keep)
                keep=true
                shift
                ;;
            --recipient)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --recipient requires an email" >&2
                    return 1
                fi
                recipient="$2"
                shift 2
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
                encrypt_help
                return 0
                ;;
            *)
                echo "Error: Unknown argument: $1" >&2
                encrypt_help
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
    
    # Validate required arguments
    if [[ ${#input[@]} -eq 0 ]]; then
        echo "Error: No input specified" >&2
        encrypt_help
        return 1
    fi
    
    if [[ -z "$output" ]]; then
        echo "Error: --output is required" >&2
        encrypt_help
        return 1
    fi
    
    # Setup GPG loopback if available
    if command -v gpgrc >/dev/null 2>&1; then
        gpgrc init >/dev/null 2>&1
    else
        shlog warn "gpgrc command not available, GPG loopback may not work"
    fi
    
    # Create temporary directory for archive
    local temp_dir
    temp_dir=$(mktemp -d)
    local archive_path="$temp_dir/archive.tar.gz"
    
    # Create archive
    if [[ ${#input[@]} -eq 1 && -f "${input[0]}" ]]; then
        # Single file
        tar -czf "$archive_path" "${input[0]}"
    else
        # Multiple files or directory
        tar -czf "$archive_path" "${input[@]}"
    fi
    
    # Encrypt the archive
    local gpg_args=()
    if [[ -n "$recipient" ]]; then
        gpg_args+=("--recipient" "$recipient")
    fi
    
    if gpg --encrypt "${gpg_args[@]}" "$archive_path"; then
        # Move encrypted file to output location
        mv "$archive_path.gpg" "$output"
        
        # Clean up source files unless --keep is specified
        if [[ "$keep" != "true" ]]; then
            for f in "${input[@]}"; do
                if command -v deleter >/dev/null 2>&1; then
                    deleter --force "$f"
                else
                    shlog warn "deleter command not available, using rm -rf"
                    rm -rf "$f"
                fi
            done
        fi
        
        # Clean up temporary directory
        if command -v deleter >/dev/null 2>&1; then
            deleter --force "$temp_dir"
        else
            shlog warn "deleter command not available, using rm -rf"
            rm -rf "$temp_dir"
        fi
        
        echo "Encryption complete: $output"
    else
        echo "Encryption failed" >&2
        rm -rf "$temp_dir"
        return 1
    fi
}

encrypt "$@"
