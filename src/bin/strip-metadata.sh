#!/bin/bash

set -oue pipefail

_strip_metadata_help() {
    shlog _begin-help-text
    echo
    echo "strip-metadata.sh"
    echo "  Usage: $0 <path-to-file-or-dir>"
    echo
    echo "Description:"
    echo "  Strips all metadata from image files under the specified path."
    echo "  - If inside a git repo, processes only git-tracked files."
    echo "  - Otherwise, processes all files recursively."
    echo
    shlog _end-help-text
}

_strip_metadata_detect_os() {
    local os
    os="$(ostype get)" || {
        shlog error "Failed to detect OS type via ostype.sh"
        exit 1
    }
    echo "$os"
}

_strip_metadata_install_exiftool() {
    local os
    os="$(_strip_metadata_detect_os)"
    shlog info "Detected OS type of '$os'"

    if ! command -v exiftool >/dev/null 2>&1; then
        case "$os" in
            darwin)
                shlog info "Installing exiftool via Homebrew..."
                if ! command -v brew >/dev/null 2>&1; then
                    shlog error "Homebrew not found. Please install Homebrew first: https://brew.sh"
                    exit 1
                fi
                brew install exiftool
                ;;
            ubuntu)
                shlog info "Installing exiftool via apt..."
                sudo apt update
                sudo apt install -y libimage-exiftool-perl
                ;;
            *)
                shlog error "Unsupported OS or OS detection failed. Please install exiftool manually."
                exit 1
                ;;
        esac
    fi
}

_strip_metadata_find_files_git() {
    local path="$1"
    git -C "$path" ls-files "$path"
}

_strip_metadata_find_files_non_git() {
    local path="$1"
    find "$path" -type f
}

_strip_metadata_is_git_repo() {
    local path="$1"
    if git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

_strip_metadata_main() {
    local target="${1:-}"

    if [[ -z "$target" ]]; then
        _strip_metadata_help
        exit 1
    fi

    if [[ ! -e "$target" ]]; then
        shlog error "Target path does not exist: $target"
        exit 1
    fi

    _strip_metadata_install_exiftool

    local files=""
    if [[ -f "$target" ]]; then
        files="$target"
    else
        if _strip_metadata_is_git_repo "$target"; then
            shlog info "Recursively scanning all files under $target"
            files="$(_strip_metadata_find_files_git "$target")"
        else
            shlog info "Recursively scanning all files under $target"
            files="$(_strip_metadata_find_files_non_git "$target")"
        fi
    fi

    local file
    while IFS= read -r file; do
        # Check if file ends with image extensions
        case "$file" in
            *.jpg|*.jpeg|*.png|*.tif|*.tiff|*.heic|*.webp)
                shlog info "Stripping metadata from: $file"
                exiftool -overwrite_original -all= "$file"
                ;;
            *)
                # Not an image file we care about
                :
                ;;
        esac
    done <<< "$files"

    shlog info "All done."
}

strip_metadata() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        help|--help|-h) _strip_metadata_help ;;
        *) _strip_metadata_main "$cmd" ;;
    esac
}

strip_metadata "$@"
