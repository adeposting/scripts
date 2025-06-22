#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"

dev_clean() {
    dev_env
    log_info "Running clean task..."
    if [ -d "$APP_DIST_DIR" ]; then
        rm -rf "$APP_DIST_DIR"
        log_info "Clean task completed successfully, deleted $APP_DIST_DIR directory"
    else
        log_info "Clean task completed successfully, nothing to do, $APP_DIST_DIR directory does not exist"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_clean "$@"
else
    export -f dev_clean
fi
