#!/bin/bash

set -oue pipefail

source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"

dev_copy() {
    dev_env
    log_info "Running copy task..."
    if [ ! -d "$APP_DATA_HOME" ]; then
        mkdir -p "$APP_DATA_HOME"
        log_info "Copying files in $APP_DIST_DIR to $APP_DATA_HOME..."
        cp -R "$APP_DIST_DIR/." "$APP_DATA_HOME/"
        log_info "Copy task completed successfully, files in $APP_DIST_DIR copied to $APP_DATA_HOME"
    else
        log_info "Copy task failed, directory $APP_DATA_HOME already exists, run 'uninstall' first"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_copy "$@"
else
    export -f dev_copy
fi
