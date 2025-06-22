#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"

dev_build() {
    dev_env
    log_info "Running build task..."
    if [ ! -d "$APP_SRC_BIN" ]
    then
        log_error "Build task failed, directory $APP_SRC_BIN not found"
    fi
    if [ -d "$APP_DIST_DIR" ]
    then
        log_error "Build task failed, directory $APP_DIST_DIR already exists, run 'clean' first"
    fi
    mkdir -p "$APP_DIST_DIR"
    cp -r "$APP_SRC_BIN" "$APP_DIST_DIR/"
    log_info "Build task completed successfully, scripts in $APP_SRC_BIN copied to $APP_DIST_DIR"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_build "$@"
else
    export -f dev_build
fi
