#!/bin/bash

set -oue pipefail

source "./src/bin/debug.sh"
source "./dev/bin/test.sh"
source "./dev/bin/clean.sh"
source "./dev/bin/build.sh"
source "./dev/bin/uninstall.sh"
source "./dev/bin/copy.sh"
source "./dev/bin/link.sh"
source "./src/bin/log.sh"

dev_install() {
    log_info "Running install task..."
    dev_test
    dev_clean
    dev_build
    dev_uninstall
    dev_copy
    dev_link
    log_info 'Install task completed successfully, to use add "export PATH=$HOME/.local/bin:$PATH" to ~/.bashrc or ~/.profile'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_install "$@"
else
    export -f dev_install
fi
