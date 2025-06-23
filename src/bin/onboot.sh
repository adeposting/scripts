set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log
include ostype
include iterm

_help() {
  echo
  echo "onboot.sh"
  echo
  echo "  Run system-specific startup tasks at boot time."
  echo
  echo "Usage:"
  echo "  ./onboot.sh"
  echo
  echo "Behavior:"
  echo "  Automatically detects the OS using ostype() and runs:"
  echo "    → onboot_darwin for macOS"
  echo "    → onboot_linux for Linux"
  echo
  echo "macOS tasks (Darwin):"
  echo "  - Unloads known problematic LaunchAgents (e.g. Canon EWCService)"
  echo "  - Starts selected startup GUI applications (e.g. Amethyst)"
  echo "  - Starts selected startup terminal applications (e.g. nvim)"
  echo
  echo "Linux tasks:"
  echo "  - Currently a stub (logs execution only)"
  echo
  echo "Integration:"
  echo "  You can source this script to make the following functions available:"
  echo "    onboot         → run the appropriate onboot_* function"
  echo "    onboot_darwin  → macOS-specific logic"
  echo "    onboot_linux   → Linux-specific logic"
  echo
}

onboot_darwin() {
    log_info "Starting onboot tasks for $(ostype)..."

    log_info "Unloading plist files with launchctl..."
    local -r plist_file="/Library/LaunchAgents/com.canon.usa.EWCService.plist"
    if [[ -e "$plist_file" ]]
    then
        log_info "Unloading plist file '$plist_file'"
        launchctl unload "$plist_file" &> /dev/null || true    
    fi
    log_info "Unloaded all plist files with launchctl"

    log_info "Launching startup GUI applications..."
    local gui_apps=("Amethyst")
    local gui_app
    for gui_app in "${gui_apps[@]}"
    do
        log_info "Launching GUI application '$gui_app'"
        open -a "$gui_app"
    done
    log_info "Launched all startup GUI applications"

    log_info "Launching startup terminal applications..."
    local term_apps=("nvim .")
    local term_app
    for term_app in "${term_apps[@]}"
    do
        log_info "Launching terminal application '$term_app'"
        iterm "$term_app"
    done
    log_info "Launched all startup terminal applications"

    log_info "Successfully completed onboot tasks for Darwin"
}

onboot_linux() {
    log_info "Starting onboot tasks for $(ostype)..."
    log_info "Successfully completed onboot tasks for Linux"
}

onboot() {
    log_info "Starting onboot tasks..."
    log_info "Determining operating system"
    os="$(ostype)"
    if [[ "$(ostype)" == "Darwin" ]]
    then
        log_info "Operating system is $os"
        onboot_darwin
    else
        log_info "Operating system is $os"
        onboot_linux
    fi
}

# --- Execution and Export Handling ---
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f onboot onboot_darwin onboot_linux
else
    if ! onboot; then
        _help
        exit 1
    fi
fi