#!/bin/bash

set -oue pipefail

git_workspace_help() {
    color set bright-white
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
    color reset
}

trap 'git_workspace_help; exit 1' ERR

_error() {
    echo "Error: $*" >&2
    exit 1
}

git_workspace_sync_repository() {
    local -r namespace="${1:?}"
    local -r path="${2:?}"
    cd "$path" || _error "Could not cd into $path"

    git fetch --all || _error "Failed to fetch in $path"

    local current_branch
    current_branch=$(git symbolic-ref --short HEAD) || git checkout "$namespace" || git checkout -b "$namespace" || _error "Failed to get current branch or checkout branch $namespace in $path"

    if [[ "$current_branch" != "$namespace" ]]; then
        git diff --quiet || _error "Unstaged changes in $path"
        git diff --cached --quiet || _error "Uncommitted staged changes in $path"
        git checkout "$namespace" || _error "Failed to checkout branch $namespace in $path"
    fi

    git add -A
    git commit -am "auto" || true

    git pull --rebase || _error "Rebase failed in $path"

    [[ ! -f .git/rebase-apply && ! -f .git/rebase-merge ]] || _error "Rebase conflict detected in $path"

    git push --set-upstream origin "$namespace" || _error "Failed to push on branch $namespace at $path"
}

git_workspace_sync_submodules_recursive() {
    local -r workspace_root="${1:?}"
    local -r namespace="${2:?}"
    local -r repo_path="${3:?}"

    cd "$repo_path" || _error "Cannot cd into $repo_path"

    if [[ -f .gitmodules ]]; then
        git config -f .gitmodules --get-regexp path | while read -r _ path; do
            local sub_path="$repo_path/$path"
            git_workspace_sync_submodules_recursive "$workspace_root" "$namespace" "$sub_path"
        done
    fi

    git_workspace_sync_repository "$namespace" "$repo_path"
}

git_workspace_sync_superproject() {
    local -r workspace="${1:?}"
    local -r namespace="${2:?}"
    local -r superproject="${3:?}"

    local spath="$workspace/$namespace/$superproject"
    git_workspace_sync_submodules_recursive "$workspace" "$namespace" "$spath"
}

git_workspace_sync_namespace() {
    local -r workspace="${1:?}"
    local -r namespace="${2:?}"

    for superproject in "$workspace/$namespace"/*; do
        [[ -d "$superproject" && "$(basename "$superproject")" != .* ]] || continue
        git_workspace_sync_superproject "$workspace" "$namespace" "$(basename "$superproject")"
    done
}

git_workspace_sync_workspace() {
    local -r workspace="${1:?}"

    for namespace in "$workspace"/*; do
        [[ -d "$namespace" && "$(basename "$namespace")" != .* ]] || continue
        git_workspace_sync_namespace "$workspace" "$(basename "$namespace")"
    done
}

git_workspace_sync() {
    local workspace="${1:-${GIT_WORKSPACE_HOME:-}}"
    [[ -n "$workspace" ]] || _error "Workspace path not provided and GIT_WORKSPACE_HOME not set"
    git_workspace_sync_workspace "$workspace"
}

git_workspace() {
    local workspace=""
    local dogit_workspace_sync=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--sync)
                dogit_workspace_sync=true
                shift
                if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
                    workspace="$1"
                    shift
                fi
                ;;
            -h|--help)
                git_workspace_help
                exit 0
                ;;
            *)
                _error "Unknown option: $1"
                ;;
        esac
    done

    if "$dogit_workspace_sync"; then
        git_workspace_sync "$workspace"
    else
        git_workspace_help
        exit 1
    fi
}

git_workspace "$@"
