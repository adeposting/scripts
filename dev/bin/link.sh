#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"

dev_link() {
    dev_env
    log_info "Running link task..."

    if [ ! -d "$APP_DATA_BIN_DIR" ]; then
        log_error "Link task failed, directory $APP_DATA_BIN_DIR not found"
    fi

    mkdir -p "$USER_BIN_HOME"

    for src in "$APP_DATA_BIN_DIR"/*; do
        [ -f "$src" ] || continue
        base="$(basename "${src%.*}")"
        dest="$USER_BIN_HOME/$base"

        if [ -e "$dest" ]; then
            log_error "Link task failed, $dest already exists"
        fi

        ln -s "$src" "$dest"
        log_info "Created symlink $dest -> $src"
    done

    log_info "Link task completed successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_link "$@"
else
    export -f dev_link
fi
