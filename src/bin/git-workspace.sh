#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug

_help() {
    echo
    echo "git-workspace.sh"
    echo
    echo "  Usage: $0 [--sync|-s] [WORKSPACE_PATH]"
    echo
    echo "Options:"
    echo "  --sync, -s      Sync all git repositories in the workspace"
    echo "  --help, -h      Show this help message"
    echo
    echo "Environment:"
    echo "  GIT_WORKSPACE_HOME can be used instead of passing the workspace path"
}

trap '_help; exit 1' ERR

_error() {
    echo "Error: $*" >&2
    exit 1
}

_sync_repository() {
    local -r namespace="${1:?}"
    local -r path="${2:?}"
    cd "$path" || _error "Could not cd into $path"

    git fetch --all || _error "Failed to fetch in $path"

    local current_branch
    current_branch=$(git symbolic-ref --short HEAD) || _error "Failed to get current branch in $path"

    if [[ "$current_branch" != "$namespace" ]]; then
        git diff --quiet || _error "Unstaged changes in $path"
        git diff --cached --quiet || _error "Uncommitted staged changes in $path"
        git switch "$namespace" || _error "Failed to switch to branch $namespace in $path"
    fi

    git add -A
    git commit -am "auto" || true

    git pull --rebase || _error "Rebase failed in $path"

    [[ ! -f .git/rebase-apply && ! -f .git/rebase-merge ]] || _error "Rebase conflict detected in $path"

    git push --set-upstream origin "$namespace" || _error "Failed to push on branch $namespace at $path"
}

_sync_submodules_recursive() {
    local -r workspace_root="${1:?}"
    local -r namespace="${2:?}"
    local -r repo_path="${3:?}"

    cd "$repo_path" || _error "Cannot cd into $repo_path"

    if [[ -f .gitmodules ]]; then
        git submodule update --init --recursive || _error "Failed to update submodules in $repo_path"
        git config -f .gitmodules --get-regexp path | while read -r _ path; do
            local sub_path="$repo_path/$path"
            _sync_submodules_recursive "$workspace_root" "$namespace" "$sub_path"
        done
    fi

    _sync_repository "$namespace" "$repo_path"
}

_sync_superproject() {
    local -r workspace="${1:?}"
    local -r namespace="${2:?}"
    local -r superproject="${3:?}"

    local spath="$workspace/$namespace/$superproject"
    _sync_submodules_recursive "$workspace" "$namespace" "$spath"
}

_sync_namespace() {
    local -r workspace="${1:?}"
    local -r namespace="${2:?}"

    for superproject in "$workspace/$namespace"/*; do
        [[ -d "$superproject" && "$(basename "$superproject")" != .* ]] || continue
        _sync_superproject "$workspace" "$namespace" "$(basename "$superproject")"
    done
}

_sync_workspace() {
    local -r workspace="${1:?}"

    for namespace in "$workspace"/*; do
        [[ -d "$namespace" && "$(basename "$namespace")" != .* ]] || continue
        _sync_namespace "$workspace" "$(basename "$namespace")"
    done
}

_sync() {
    local workspace="${1:-${GIT_WORKSPACE_HOME:-}}"
    [[ -n "$workspace" ]] || _error "Workspace path not provided and GIT_WORKSPACE_HOME not set"
    _sync_workspace "$workspace"
}

main() {
    local workspace=""
    local do_sync=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--sync)
                do_sync=true
                shift
                if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
                    workspace="$1"
                    shift
                fi
                ;;
            -h|--help)
                _help
                exit 0
                ;;
            *)
                _error "Unknown option: $1"
                ;;
        esac
    done

    if "$do_sync"; then
        _sync "$workspace"
    else
        _help
        exit 1
    fi
}

main "$@"
