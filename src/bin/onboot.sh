#!/bin/bash

set -oue pipefail

onboot_help() {
    shlog _begin-help-text
    echo
    echo "onboot.sh"
    echo
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  add <script>             → add script to run on boot"
    echo "  remove <script>          → remove script from boot sequence"
    echo "  list                     → list all scripts in boot sequence"
    echo "  help, --help, -h         → show this help text"
    echo
    echo "Behavior:"
    echo "  When run without arguments, performs startup tasks based on OS:"
    echo "  - macOS/Darwin: Unloads plist files, launches GUI and terminal apps"
    echo "  - Linux: Performs Linux-specific startup tasks"
    echo
    shlog _end-help-text
}

onboot_darwin() {
    shlog info "Starting onboot tasks for Darwin..."

    shlog info "Unloading plist files with launchctl..."
    local -r plist_file="/Library/LaunchAgents/com.canon.usa.EWCService.plist"
    if [[ -e "$plist_file" ]]
    then
        shlog info "Unloading plist file '$plist_file'"
        launchctl unload "$plist_file" &> /dev/null || true    
    fi
    shlog info "Unloaded all plist files with launchctl"

    shlog info "Launching startup GUI applications..."
    local gui_apps=("Amethyst")
    local gui_app
    for gui_app in "${gui_apps[@]}"
    do
        shlog info "Launching GUI application '$gui_app'"
        open -a "$gui_app"
    done
    shlog info "Launched all startup GUI applications"

    shlog info "Launching startup terminal applications..."
    local term_apps=("nvim .")
    local term_app
    for term_app in "${term_apps[@]}"
    do
        shlog info "Launching terminal application '$term_app'"
        if command -v iterm &>/dev/null; then
            iterm "$term_app"
        else
            shlog warn "iterm command not available, skipping: $term_app"
        fi
    done
    shlog info "Launched all startup terminal applications"

    shlog info "Successfully completed onboot tasks for Darwin"
}

onboot_linux() {
    shlog info "Starting onboot tasks for Linux..."
    shlog info "Successfully completed onboot tasks for Linux"
}

onboot() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) 
            onboot_help 
            return 0
            ;;
        *) 
            # Main logic moved here
            shlog info "Starting onboot tasks..."
            shlog info "Determining operating system"
            
            local os
            if command -v ostype &>/dev/null; then
                os="$(ostype get)"
            else
                # Fallback OS detection
                if [[ "$(uname)" == "Darwin" ]]; then
                    os="darwin"
                else
                    os="linux"
                fi
            fi
            
            if [[ "$os" == "darwin" || "$os" == "Darwin" ]]
            then
                shlog info "Operating system is $os"
                onboot_darwin
            else
                shlog info "Operating system is $os"
                onboot_linux
            fi
            ;;
    esac
}

onboot "$@"