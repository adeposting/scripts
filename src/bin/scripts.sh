#!/bin/bash

# Cross-shell compatible error handling
set -euo pipefail

scripts_help() {
    # Check if color command exists before using it
    if command -v color >/dev/null 2>&1; then
        color set bright-white
    fi
    echo
    echo "scripts.sh"
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  bootstrap               → bootstrap the scripts environment"
    echo "  init                    → initialize the scripts environment"
    echo "  test                    → run all tests"
    echo "  build                   → build the scripts distribution"
    echo "  install                 → install scripts to ~/.local/share/scripts"
    echo "  uninstall               → uninstall scripts from ~/.local/share/scripts"
    echo "  env                     → show environment information"
    echo "  help, --help, -h        → show this help text"
    echo
    echo "Environment:"
    echo "  SCRIPTS_REPO_ROOT_DIR → exports path to the scripts repository root"
    echo
    if command -v color >/dev/null 2>&1; then
        color reset
    fi
}

# --- Detect if current working directory is the scripts repository root ---
is_cwd_scripts_repo_root_dir() {
    # Check if we're running in a Docker container
    if [[ -f /.dockerenv ]]; then
        # We're in a Docker container, bypass git checks and use current directory
        export SCRIPTS_REPO_ROOT_DIR="$(pwd)"
        echo "Detected scripts repository in Docker container at: $SCRIPTS_REPO_ROOT_DIR"
        return 0
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    # Get the remote origin URL
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Error: No remote origin configured" >&2
        return 1
    fi
    
    # Extract the repository path from various URL formats
    local repo_path
    if [[ "$remote_url" =~ ^git@ ]]; then
        # SSH format: git@github.com-adeposting:adeposting/scripts
        repo_path=$(echo "$remote_url" | sed 's/.*://')
    elif [[ "$remote_url" =~ ^https?:// ]]; then
        # HTTPS format: https://github.com/adeposting/scripts
        repo_path=$(echo "$remote_url" | sed 's|https\?://[^/]*/||')
    else
        echo "Error: Unrecognized remote URL format: $remote_url" >&2
        return 1
    fi
    
    # Check if the repository path matches adeposting/scripts
    if [[ "$repo_path" != "adeposting/scripts" ]]; then
        echo "Error: Not in the correct repository. Expected 'adeposting/scripts', got '$repo_path'" >&2
        return 1
    fi
    
    # Set SCRIPTS_REPO_ROOT_DIR to current directory
    export SCRIPTS_REPO_ROOT_DIR="$(pwd)"
    echo "Detected scripts repository at: $SCRIPTS_REPO_ROOT_DIR"
    return 0
}

# --- Bootstrap function to set up virtual environment ---
scripts_bootstrap() {
    scripts_env || {
        echo "Error: Failed to bootstrap scripts" >&2
        return 1
    }
    
    cd "$SCRIPTS_REPO_ROOT_DIR" || {
        echo "Error: Failed to change to scripts directory: $SCRIPTS_REPO_ROOT_DIR" >&2
        return 1
    }

    echo "Detected scripts repository at: $SCRIPTS_REPO_ROOT_DIR"
    echo "Bootstrapping scripts environment..."

    # Build first to ensure we have the latest distribution
    scripts_build || {
        echo "Error: Build failed, cannot bootstrap" >&2
        return 1
    }

    # Clean existing symlinks in ./.venv/bin
    rm -rf ./.venv/bin
    mkdir -p ./.venv/bin

    # Create symlinks from dist/bin to ./.venv/bin
    for script in ./dist/bin/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script" .sh)
            ln -sf "$(pwd)/$script" "./.venv/bin/$script_name"
        fi
    done

    # Add ./.venv/bin to PATH
    export PATH="$(pwd)/.venv/bin:$PATH"
    echo "Added ./.venv/bin to PATH"

    echo "Bootstrap complete. Scripts are now available in PATH."
}

scripts_env() {
    # Bootstrap first if not already done
    if [[ -z "${SCRIPTS_REPO_ROOT_DIR:-}" ]]; then
        scripts_bootstrap || return 1
    fi

    # Add scripts bin to PATH (in case bootstrap wasn't run)
    if [[ -n "$SCRIPTS_REPO_ROOT_DIR" ]]; then
        export PATH="$SCRIPTS_REPO_ROOT_DIR/src/bin:$PATH"
        echo "Added $SCRIPTS_REPO_ROOT_DIR/src/bin to PATH"
    fi

    # Source environment file if it exists and we're not in Docker
    if [[ ! -f /.dockerenv ]] && [[ -f "$SCRIPTS_REPO_ROOT_DIR/dist/env/scripts.env" ]]; then
        source "$SCRIPTS_REPO_ROOT_DIR/dist/env/scripts.env"
        echo "Sourced environment from $SCRIPTS_REPO_ROOT_DIR/dist/env/scripts.env"
    fi
}

scripts_init() {
    scripts_env || {
        echo "Error: Failed to initialize scripts" >&2
        return 1
    }
    
    cd "$SCRIPTS_REPO_ROOT_DIR" || {
        echo "Error: Failed to change to scripts directory: $SCRIPTS_REPO_ROOT_DIR" >&2
        return 1
    }

    # Build first to ensure we have the latest distribution
    scripts_build || {
        echo "Error: Build failed, cannot initialize" >&2
        return 1
    }

    echo "Running init checks..."

    # Install shellcheck if not available
    if ! command -v shellcheck &>/dev/null; then
        echo "shellcheck not found, attempting to install..."
        
        if command -v brew &>/dev/null; then
            echo "Installing shellcheck via Homebrew..."
            brew install shellcheck
            if command -v shellcheck &>/dev/null; then
                echo "shellcheck installed successfully"
            else
                echo "Error: Failed to install shellcheck" >&2
                return 1
            fi
        else
            echo "Error: Homebrew not available. Please install shellcheck manually:" >&2
            echo "  macOS: brew install shellcheck" >&2
            echo "  Ubuntu/Debian: sudo apt install shellcheck" >&2
            echo "  Arch: sudo pacman -S shellcheck" >&2
            return 1
        fi
    else
        echo "shellcheck already available"
    fi

    echo "init complete"
}

scripts_test() {
    scripts_env || {
        echo "Error: Failed to test scripts" >&2
        return 1
    }
    
    cd "$SCRIPTS_REPO_ROOT_DIR" || {
        echo "Error: Failed to change to scripts directory: $SCRIPTS_REPO_ROOT_DIR" >&2
        return 1
    }

    # Build first to ensure we have the latest distribution
    scripts_build || {
        echo "Error: Build failed, cannot run tests" >&2
        return 1
    }

    # Run init to ensure dependencies are available
    scripts_init || {
        echo "Error: init failed, cannot run tests" >&2
        return 1
    }

    echo "Running tests using shelltest CLI..."

    # Use shelltest CLI to run all tests
    if shelltest run-all "$SCRIPTS_REPO_ROOT_DIR/tests/bin"; then
        echo "All tests passed!"
        return 0
    else
        echo "Some tests failed!" >&2
        return 1
    fi
}

scripts_build() {
    # Set SCRIPTS_REPO_ROOT_DIR to current directory
    export SCRIPTS_REPO_ROOT_DIR="$(pwd)"
    
    echo "Building scripts distribution..."

    # Clean up existing build
    rm -rf ./dist

    # Create distribution directory
    cp -r ./src ./dist
    mkdir -p ./dist/env
    mkdir -p ./dist/bin

    # Create environment file
    echo "export SCRIPTS_REPO_ROOT_DIR='$(pwd)'" > ./dist/env/scripts.env
    echo "Created environment file: ./dist/env/scripts.env"

    # Create symlinks in dist/bin for easy access
    for script in ./dist/bin/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script" .sh)
            ln -sf "$(pwd)/$script" "./dist/bin/$script_name"
        fi
    done

    # Make all scripts executable
    chmod +x ./dist/bin/*.sh 2>/dev/null || true
    chmod +x ./dist/bin/* 2>/dev/null || true

    echo "Build complete. Distribution available in ./dist/"
}

scripts_install() {
    scripts_env || {
        echo "Error: Failed to install scripts" >&2
        return 1
    }
    
    cd "$SCRIPTS_REPO_ROOT_DIR" || {
        echo "Error: Failed to change to scripts directory: $SCRIPTS_REPO_ROOT_DIR" >&2
        return 1
    }

    echo "Installing scripts to ~/.local/share/scripts"

    # Build first to ensure we have the latest distribution
    scripts_build || {
        echo "Error: Build failed, cannot install" >&2
        return 1
    }

    # Clean up existing installation
    rm -rf ~/.local/share/scripts

    # Create target directory and install from dist
    mkdir -p ~/.local/share/scripts
    cp -r ./dist/* ~/.local/share/scripts/
    echo "Copied scripts to ~/.local/share/scripts"

    # Create symlinks
    if command -v unlinker &>/dev/null; then
        echo "Removing existing symlinks..."
        unlinker --source ~/.local/share/scripts
    else
        echo "Warning: unlinker not available, skipping symlink cleanup" >&2
    fi

    if command -v linker &>/dev/null; then
        echo "Creating symlinks..."
        linker --force --rename 's/\.sh$//' --source ~/.local/share/scripts --destination ~/.local
    else
        echo "Warning: linker not available, skipping symlink creation" >&2
    fi

    echo "Installation complete. Scripts are available at ~/.local/share/scripts"
    echo "Add ~/.local/bin to your PATH to use the scripts from anywhere"
}

scripts_uninstall() {
    scripts_env || {
        echo "Error: Failed to uninstall scripts" >&2
        return 1
    }
    
    cd "$SCRIPTS_REPO_ROOT_DIR" || {
        echo "Error: Failed to change to scripts directory: $SCRIPTS_REPO_ROOT_DIR" >&2
        return 1
    }

    echo "Uninstalling scripts from ~/.local/share/scripts"

    # Remove symlinks
    if command -v unlinker &>/dev/null; then
        echo "Removing symlinks..."
        unlinker --force --source ~/.local/share/scripts --destination ~/.local
    else
        echo "Warning: unlinker not available, skipping symlink removal" >&2
    fi

    # Remove installed scripts
    rm -rf ~/.local/share/scripts
    echo "Removed ~/.local/share/scripts"

    # Clean up local dist
    rm -rf ./dist
    echo "Cleaned up local dist directory"

    echo "Uninstallation complete"
}

scripts() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        help|--help|-h) scripts_help ;;
        bootstrap) scripts_bootstrap ;;
        init) scripts_bootstrap && scripts_init ;;
        test) scripts_bootstrap && scripts_test ;;
        build) scripts_build ;;
        install) scripts_bootstrap && scripts_install ;;
        uninstall) scripts_bootstrap && scripts_uninstall ;;
        env) scripts_bootstrap && scripts_env ;;
        *) scripts_help ;;
    esac
}

scripts "$@"