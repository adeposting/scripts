set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log
include ostype

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
  echo "  - Starts selected startup applications (e.g. Amethyst)"
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

    log_info "Launching startup applications..."
    applications=""
    applications+="Amethyst"
    for application in $applications
    do
        log_info "Launching application '$application'"
        open -a "$application"
    done
    log_info "Launched all startup applications"

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