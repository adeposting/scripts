#!/bin/bash

set -oue pipefail

source "./src/bin/helloworld.sh"

test_helloworld() {
    local -r expected="hello world"
    local actual
    actual="$(helloworld 2>/dev/null)"
    if [[ "$actual" == "$expected" ]]; then
        echo "test_hello_world: PASS"
    else
        echo "test_hello_world: FAIL (expected: '$expected', actual: '$actual')"
        return 1
    fi
}

main() {
    test_helloworld
}

main