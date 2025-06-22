#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"

dev_uninstall() {
    dev_env
    log_info "Running uninstall task..."

    if [ ! -d "$APP_DATA_HOME" ]; then
        log_info "Uninstall task completed successfully, nothing to do, $APP_DATA_HOME directory does not exist"
        return
    fi

    if [ ! -d "$APP_DATA_BIN_DIR" ]; then
        log_error "Uninstall task failed, unexpected directory structure, $APP_DATA_HOME directory does not contain a $(basename $APP_DATA_BIN_DIR) directory"
    fi

    log_info "Deleting all symlinks from files in $APP_DATA_BIN_DIR" to files in "$USER_BIN_HOME"...
    for src in "$APP_DATA_BIN_DIR"/*; do
        [ -f "$src" ] || continue
        base="$(basename "${src%.*}")"
        dest="$USER_BIN_HOME/$base"
        if [ -L "$dest" ]; then
            if [ "$(readlink "$dest")" = "$src" ]; then
                rm "$dest"
                log_info "Removed symlink $dest"
            else
                log_error "Uninstall task failed, $dest is a symlink but does not point to $src"
            fi
        elif [ -e "$dest" ]; then
            log_error "Uninstall task failed, $dest exists but is not a symlink"
        fi
    done
    log_info "Successfully deleted all symlinks from files in $APP_DATA_BIN_DIR" to files in "$USER_BIN_HOME"...

    log_info "Deleting directory $APP_DATA_HOME and all contents..."
    rm -rf "$APP_DATA_HOME"
    log_info "Successfully deleted directory $APP_DATA_HOME and all contents"

    log_info "Uninstall task completed successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_uninstall "$@"
else
    export -f dev_uninstall
fi
