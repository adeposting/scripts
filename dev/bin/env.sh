#!/bin/bash
set -oue pipefail
source "./src/bin/debug.sh"

dev_env() {
    export APP_REPO_ROOT="$(pwd)"
    export APP_DIST_DIR="./dist"
    export APP_SRC_BIN="./src/bin"
    export APP_DATA_HOME="$HOME/.local/share/scripts"
    export APP_DATA_BIN_DIR="$APP_DATA_HOME/bin"
    export USER_BIN_HOME="$HOME/.local/bin"
    export APP_README_FILE="$APP_REPO_ROOT/README.md"
    export APP_TESTS_DIR="$APP_REPO_ROOT/tests/bin"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dev_env "$@"
else
    export -f dev_env
fi
