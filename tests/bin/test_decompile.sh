#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

test_decompile_help() {
    shlog info "Testing decompile help"
    local output
    output=$(decompile --help 2>&1)
    if [[ $? -eq 0 && "$output" == *"decompile.sh - Universal decompilation tool"* ]]; then
        shlog info "PASS: Help function works"
        return 0
    else
        shlog error "FAIL: Help function failed"
        return 1
    fi
}

test_decompile_validation() {
    shlog info "Testing validation functions"
    
    # Test language validation
    if decompile --language invalid_lang --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject invalid language"
        return 1
    fi
    
    # Test tool validation
    if decompile --tool invalid_tool --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject invalid tool"
        return 1
    fi
    
    # Test file type validation
    if decompile --file-type invalid_type --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject invalid file type"
        return 1
    fi
    
    # Test valid options
    if ! decompile --language java --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept valid language"
        return 1
    fi
    
    if ! decompile --tool jadx --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept valid tool"
        return 1
    fi
    
    if ! decompile --file-type apk --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept valid file type"
        return 1
    fi
    
    shlog info "PASS: Validation functions work"
    return 0
}

test_decompile_compatibility() {
    shlog info "Testing compatibility validation"
    
    # Test incompatible language and tool
    if decompile --language python --tool jadx --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject incompatible language and tool"
        return 1
    fi
    
    # Test incompatible tool and file type
    if decompile --tool jadx --file-type pyc --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject incompatible tool and file type"
        return 1
    fi
    
    # Test compatible options
    if ! decompile --language java --tool jadx --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept compatible language and tool"
        return 1
    fi
    
    if ! decompile --tool jadx --file-type apk --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept compatible tool and file type"
        return 1
    fi
    
    shlog info "PASS: Compatibility validation works"
    return 0
}

test_decompile_missing_target() {
    shlog info "Testing missing target validation"
    
    if decompile >/dev/null 2>&1; then
        shlog error "FAIL: Should require target"
        return 1
    fi
    
    shlog info "PASS: Missing target validation works"
    return 0
}

test_decompile_nonexistent_target() {
    shlog info "Testing nonexistent target validation"
    
    if decompile nonexistent_file >/dev/null 2>&1; then
        shlog error "FAIL: Should reject nonexistent file"
        return 1
    fi
    
    shlog info "PASS: Nonexistent target validation works"
    return 0
}

test_decompile_install_only() {
    shlog info "Testing install-only mode"
    
    # This test just checks that the option is accepted
    if ! decompile --install-only >/dev/null 2>&1; then
        shlog error "FAIL: Should accept --install-only"
        return 1
    fi
    
    shlog info "PASS: Install-only mode works"
    return 0
}

test_decompile_logging_options() {
    shlog info "Testing logging options integration"
    
    # Test that shlog options are handled
    if ! decompile --debug --help >/dev/null 2>&1; then
        shlog error "FAIL: Should handle --debug option"
        return 1
    fi
    
    if ! decompile --verbose --help >/dev/null 2>&1; then
        shlog error "FAIL: Should handle --verbose option"
        return 1
    fi
    
    if ! decompile --quiet --help >/dev/null 2>&1; then
        shlog error "FAIL: Should handle --quiet option"
        return 1
    fi
    
    shlog info "PASS: Logging options integration works"
    return 0
}

test_decompile_file_type_detection() {
    shlog info "Testing file type detection"
    
    # Create test files
    local test_dir="/tmp/decompile_test_$$"
    mkdir -p "$test_dir"
    
    # Test APK detection
    echo "fake apk content" > "$test_dir/test.apk"
    if ! decompile --file-type apk "$test_dir/test.apk" --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept APK file type"
        rm -rf "$test_dir"
        return 1
    fi
    
    # Test JAR detection
    echo "fake jar content" > "$test_dir/test.jar"
    if ! decompile --file-type jar "$test_dir/test.jar" --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept JAR file type"
        rm -rf "$test_dir"
        return 1
    fi
    
    # Test PYc detection
    echo "fake pyc content" > "$test_dir/test.pyc"
    if ! decompile --file-type pyc "$test_dir/test.pyc" --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept PYC file type"
        rm -rf "$test_dir"
        return 1
    fi
    
    rm -rf "$test_dir"
    shlog info "PASS: File type detection works"
    return 0
}

test_decompile_output_options() {
    shlog info "Testing output options"
    
    # Test output directory option
    if ! decompile --output /tmp/test_output --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept --output option"
        return 1
    fi
    
    # Test force option
    if ! decompile --force --help >/dev/null 2>&1; then
        shlog error "FAIL: Should accept --force option"
        return 1
    fi
    
    shlog info "PASS: Output options work"
    return 0
}

test_decompile_argument_parsing() {
    shlog info "Testing argument parsing"
    
    # Test multiple arguments
    if decompile arg1 arg2 --help >/dev/null 2>&1; then
        shlog error "FAIL: Should reject multiple targets"
        return 1
    fi
    
    # Test missing option values
    if decompile --language --help >/dev/null 2>&1; then
        shlog error "FAIL: Should require value for --language"
        return 1
    fi
    
    if decompile --tool --help >/dev/null 2>&1; then
        shlog error "FAIL: Should require value for --tool"
        return 1
    fi
    
    if decompile --file-type --help >/dev/null 2>&1; then
        shlog error "FAIL: Should require value for --file-type"
        return 1
    fi
    
    if decompile --output --help >/dev/null 2>&1; then
        shlog error "FAIL: Should require value for --output"
        return 1
    fi
    
    shlog info "PASS: Argument parsing works"
    return 0
}

test_decompile() {
    shlog info "Running decompile.sh tests"
    
    local failed=0
    
    test_decompile_help || ((failed++))
    test_decompile_validation || ((failed++))
    test_decompile_compatibility || ((failed++))
    test_decompile_missing_target || ((failed++))
    test_decompile_nonexistent_target || ((failed++))
    test_decompile_install_only || ((failed++))
    test_decompile_logging_options || ((failed++))
    test_decompile_file_type_detection || ((failed++))
    test_decompile_output_options || ((failed++))
    test_decompile_argument_parsing || ((failed++))
    
    if [[ $failed -eq 0 ]]; then
        shlog info "All decompile.sh tests passed"
        return 0
    else
        shlog error "$failed decompile.sh tests failed"
        return 1
    fi
}

test_decompile "$@" 