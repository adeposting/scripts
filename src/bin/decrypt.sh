#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

decrypt_help() {
    color set bright-white
    echo
    echo "decrypt.sh - File decryption utility"
    echo
    echo "  Usage: $0 --input <file> --output <filename> [OPTIONS]"
    echo
    echo "Description:"
    echo "  Decrypts GPG-encrypted files and extracts archives."
    echo
    echo "Options:"
    echo "  --input <file>          input encrypted file to decrypt"
    echo "  --output <filename>     output filename for decrypted archive"
    echo "  --extract               extract the archive after decryption"
    echo "  --recipient <email>     GPG recipient email (optional)"
    echo
    _shlog_print_common_help
    echo
    echo "Examples:"
    echo "  $0 --input encrypted.tar.gz.gpg --output decrypted.tar.gz"
    echo "  $0 --input backup.tar.gz.gpg --output backup.tar.gz --extract"
    echo "  $0 --input file.tar.gz.gpg --output file.tar.gz --recipient user@example.com"
    echo
    color reset
}

decrypt() {
    local input=""
    local output=""
    local extract=false
    local recipient=""
    local shlog_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --input)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --input requires a file" >&2
                    return 1
                fi
                input="$2"
                shift 2
                ;;
            --output)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --output requires a filename" >&2
                    return 1
                fi
                output="$2"
                shift 2
                ;;
            --extract)
                extract=true
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
                decrypt_help
                return 0
                ;;
            *)
                echo "Error: Unknown argument: $1" >&2
                decrypt_help
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
    if [[ -z "$input" ]]; then
        echo "Error: --input is required" >&2
        decrypt_help
        return 1
    fi
    
    if [[ -z "$output" ]]; then
        echo "Error: --output is required" >&2
        decrypt_help
        return 1
    fi
    
    # Check if input file exists
    if [[ ! -f "$input" ]]; then
        echo "Error: Input file not found: $input" >&2
        return 1
    fi
    
    # Setup GPG loopback if available
    if command -v gpgrc >/dev/null 2>&1; then
        gpgrc init >/dev/null 2>&1
    else
        shlog warn "gpgrc command not available, GPG loopback may not work"
    fi
    
    # Decrypt the file
    local gpg_args=()
    if [[ -n "$recipient" ]]; then
        gpg_args+=("--recipient" "$recipient")
    fi
    
    if gpg --decrypt "${gpg_args[@]}" "$input" > "$output"; then
        echo "Decryption complete: $output"
        
        # Extract if requested
        if [[ "$extract" == "true" ]]; then
            if [[ "$output" == *.tar.gz ]]; then
                echo "Extracting archive..."
                tar -xzf "$output"
                
                # Clean up the archive unless --keep is specified
                if command -v deleter >/dev/null 2>&1; then
                    deleter --force "$output"
                else
                    shlog warn "deleter command not available, using rm -f"
                    rm -f "$output"
                fi
                
                echo "Extraction complete"
            else
                echo "Warning: Output file doesn't appear to be a tar.gz archive, skipping extraction"
            fi
        fi
    else
        echo "Decryption failed" >&2
        rm -f "$output"
        return 1
    fi
}

decrypt "$@"
