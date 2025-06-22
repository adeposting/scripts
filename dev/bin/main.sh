#!/bin/bash
set -oue pipefail

source "./src/bin/log.sh"
source "./src/bin/debug.sh"

source "./dev/bin/env.sh"
source "./dev/bin/build.sh"
source "./dev/bin/clean.sh"
source "./dev/bin/copy.sh"
source "./dev/bin/install.sh"
source "./dev/bin/link.sh"
source "./dev/bin/test.sh"
source "./dev/bin/uninstall.sh"
source "./dev/bin/help.sh"

dev_main() {
    log_info "Executing $0 $@..."

    CMD="${1:-}"

    case "$CMD" in
        build) dev_build ;;
        clean) dev_clean ;;
        copy) dev_copy ;;
        install) dev_install ;;
        link) dev_link ;;
        test) dev_test ;;
        uninstall) dev_uninstall ;;
        help|-h|--help) dev_help ;;
        '') log_error "No command provided, run $0 --help for usage" ;;
        *) log_error "Unknown command $CMD, run $0 --help for usage" ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_main "$@"
else
    export -f dev_main
fi
