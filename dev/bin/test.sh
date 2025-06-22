#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"
source "./dev/bin/env.sh"
source "./src/bin/log.sh"
source "./src/bin/color.sh"

dev_test() {
    dev_env
    log_info "Running test task..."
    if [[ -d "$APP_TESTS_DIR" ]]; then
        log_info "Running all test scripts in $APP_TESTS_DIR..."
        for test_script in "$APP_TESTS_DIR"/*; do
            log_info "Running test script $test_script..."
            chmod +x "$test_script"
            set_color 'gray' 
            "$test_script" || log_error "Test command failed, test script $test_script exited with error"
            reset_color
        done
    else
        log_info "Test task failed, no directory found at $APP_TESTS_DIR"
    fi
    log_info "Test task completed successfully, all tests passed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_test "$@"
else
    export -f dev_test
fi
