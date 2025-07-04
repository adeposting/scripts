#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

test_help() {
    echo
    echo "test.sh - Run tests using Docker containers"
    echo
    echo "  Usage: $0 [test_name]"
    echo
    echo "Runs all tests or a specific test using Docker containers"
    echo
}

test() {
    local test_arg="${1:-}"
    
    echo "Preparing for Docker testing..."

    # Ensure .docker directory is fresh
    rm -rf .docker
    mkdir -p .docker/darwin .docker/linux

    # Copy repository contents (excluding git-ignored files) to both docker directories
    echo "Copying repository contents to .docker directories..."
    
    # Use git ls-files to get all tracked files (excluding ignored ones)
    if git ls-files >/dev/null 2>&1; then
        # Copy all tracked files to both directories
        git ls-files | while read -r file; do
            if [[ -f "$file" ]]; then
                # Create directory structure if needed
                mkdir -p ".docker/darwin/$(dirname "$file")"
                mkdir -p ".docker/linux/$(dirname "$file")"
                # Copy file to both directories
                cp "$file" ".docker/darwin/$file"
                cp "$file" ".docker/linux/$file"
            fi
        done
        echo "Copied $(git ls-files | wc -l | tr -d ' ') files to .docker directories"
    else
        echo "Warning: Not in a git repository, copying all non-ignored files..."
        # Fallback: copy everything except common ignored patterns
        rsync -av --exclude='.git' --exclude='.docker' --exclude='dist' --exclude='.venv' \
              --exclude='*.log' --exclude='__pycache__' --exclude='*.pyc' \
              --exclude='.DS_Store' --exclude='*.tmp' --exclude='*.swp' \
              ./ .docker/darwin/
        rsync -av --exclude='.git' --exclude='.docker' --exclude='dist' --exclude='.venv' \
              --exclude='*.log' --exclude='__pycache__' --exclude='*.pyc' \
              --exclude='.DS_Store' --exclude='*.tmp' --exclude='*.swp' \
              ./ .docker/linux/
    fi

    # Build first to ensure we have the latest distribution
    ./dev/bin/build.sh || {
        echo "Error: Build failed, cannot run tests" >&2
        return 1
    }

    # Check if a specific test was provided
    if [[ -n "$test_arg" ]]; then
        echo "Running specific test: $test_arg"
        # Use Docker test runner to run specific test
        cd ./dev/docker && make test-specific TEST="$test_arg"
    else
        echo "Running all tests using Docker containers..."
        # Use Docker test runner to run all tests
        cd ./dev/docker && make test-all
    fi
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        help|--help|-h) test_help ;;
        *) test "$@" ;;
    esac
}

main "$@" 