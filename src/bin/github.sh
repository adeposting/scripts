#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

github_help() {
    shlog _begin-help-text
    echo
    echo "github.sh - GitHub repository management utility"
    echo
    echo "  Usage: $0 <command> [OPTIONS]"
    echo
    echo "Commands:"
    echo "  create-repos [OPTIONS]    → create multiple repositories"
    echo "  delete-repos [OPTIONS]    → delete multiple repositories"
    echo "  help, --help, -h          → show this help text"
    echo
    echo "Create Repos Options:"
    echo "  --user <username>         GitHub username (defaults to git config)"
    echo "  --license <type>          license type (default: MIT)"
    echo "  --branch <name>           default branch name (default: main)"
    echo "  --repos <name>...         space-separated list of repository names"
    echo
    echo "Delete Repos Options:"
    echo "  --user <username>         GitHub username (defaults to git config)"
    echo "  --force                   skip confirmation prompts"
    echo "  --repos <name>...         space-separated list of repository names"
    echo
    shlog _print-common-help
    echo
    echo "Examples:"
    echo "  $0 create-repos --user myuser --repos repo1 repo2 repo3"
    echo "  $0 create-repos --license Apache-2.0 --repos myproject"
    echo "  $0 delete-repos --user myuser --force --repos oldrepo1 oldrepo2"
    echo
    shlog _end-help-text
}

github_create_repos() {
    local DEFAULT_USER=""
    local LICENSE="MIT"
    local BRANCH_NAME=""
    local REPOS=()
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --user)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --user requires a username" >&2
                    return 1
                fi
                DEFAULT_USER="$2"
                shift 2
                ;;
            --license)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --license requires a license type" >&2
                    return 1
                fi
                LICENSE="$2"
                shift 2
                ;;
            --branch)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --branch requires a branch name" >&2
                    return 1
                fi
                BRANCH_NAME="$2"
                shift 2
                ;;
            --repos)
                shift
                while [[ "$#" -gt 0 && ! "$1" =~ ^-- ]]; do
                    REPOS+=("$1")
                    shift
                done
                ;;
            --help|-h)
                github_help
                return 0
                ;;
            --*)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    echo "Error: Unknown argument: $1" >&2
                    return 1
                fi
                break
                ;;
            *)
                echo "Error: Unknown argument: $1" >&2
                return 1
                ;;
        esac
    done
    
    if [[ "${#REPOS[@]}" -eq 0 ]]; then
        echo "Error: --repos must be provided with one or more space-separated repo names." >&2
        return 1
    fi
    
    local ALLOW_MERGE_COMMIT=false
    local ALLOW_SQUASH_MERGE=true
    local ALLOW_REBASE_MERGE=true
    local HAS_ISSUES=false
    local HAS_PROJECTS=false
    local HAS_WIKI=false
    
    for INPUT in "${REPOS[@]}"; do
        INPUT="$(echo "$INPUT" | xargs)"
        local EXPECTED_GIT_USER REPO
        
        if [[ "$INPUT" == */* ]]; then
            EXPECTED_GIT_USER="${INPUT%%/*}"
            REPO="${INPUT##*/}"
        else
            if [[ -z "$DEFAULT_USER" ]]; then
                echo "Error: No user provided for repo '$INPUT'. Use --user to set a default." >&2
                return 1
            fi
            EXPECTED_GIT_USER="$DEFAULT_USER"
            REPO="$INPUT"
            INPUT="$EXPECTED_GIT_USER/$REPO"
        fi
        
        ACTUAL_GIT_USER="$(gh api user --jq .login 2>/dev/null || true)"
        
        if [[ -z "$ACTUAL_GIT_USER" ]]; then
            echo "Error: You are not authenticated. Please run: gh auth login" >&2
            return 1
        elif [[ "$ACTUAL_GIT_USER" != "$EXPECTED_GIT_USER" ]]; then
            echo "Error: Authenticated as '$ACTUAL_GIT_USER', expected '$EXPECTED_GIT_USER'. Run: gh auth logout && gh auth login" >&2
            return 1
        fi
        
        if gh repo view "$INPUT" &>/dev/null; then
            shlog info "Skipping existing repo: $INPUT"
            continue
        fi
        
        shlog info "Creating repo: $INPUT"
        gh repo create "$INPUT" \
            --private \
            --description "" \
            --disable-wiki \
            --disable-issues \
            --license="$LICENSE" \
            --add-readme
        
        shlog info "Patching repo settings: $INPUT"
        gh api -X PATCH "repos/$EXPECTED_GIT_USER/$REPO" \
            -f has_projects=$HAS_PROJECTS \
            -f allow_merge_commit=$ALLOW_MERGE_COMMIT \
            -f allow_squash_merge=$ALLOW_SQUASH_MERGE \
            -f allow_rebase_merge=$ALLOW_REBASE_MERGE \
            > /dev/null
        
        if [[ -n "$BRANCH_NAME" ]]; then
            shlog info "Creating branch '$BRANCH_NAME' in $INPUT"
            local DEFAULT_BRANCH
            DEFAULT_BRANCH=$(gh api "repos/$EXPECTED_GIT_USER/$REPO" --jq .default_branch)
            local COMMIT_SHA
            COMMIT_SHA=$(gh api "repos/$EXPECTED_GIT_USER/$REPO/git/refs/heads/$DEFAULT_BRANCH" --jq .object.sha)
            gh api "repos/$EXPECTED_GIT_USER/$REPO/git/refs" \
                -f ref="refs/heads/$BRANCH_NAME" \
                -f sha="$COMMIT_SHA" \
                > /dev/null
        fi
    done
}

github_delete_repos() {
    local DEFAULT_USER=""
    local FORCE=false
    local REPOS=()
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --user)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --user requires a username" >&2
                    return 1
                fi
                DEFAULT_USER="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --repos)
                shift
                while [[ "$#" -gt 0 && ! "$1" =~ ^-- ]]; do
                    REPOS+=("$1")
                    shift
                done
                ;;
            --help|-h)
                github_help
                return 0
                ;;
            --*)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    echo "Error: Unknown argument: $1" >&2
                    return 1
                fi
                break
                ;;
            *)
                echo "Error: Unknown argument: $1" >&2
                return 1
                ;;
        esac
    done
    
    if [[ "${#REPOS[@]}" -eq 0 ]]; then
        echo "Error: --repos must be provided with one or more space-separated repo names." >&2
        return 1
    fi
    
    for INPUT in "${REPOS[@]}"; do
        INPUT="$(echo "$INPUT" | xargs)"
        local EXPECTED_GIT_USER REPO
        
        if [[ "$INPUT" == */* ]]; then
            EXPECTED_GIT_USER="${INPUT%%/*}"
            REPO="${INPUT##*/}"
        else
            if [[ -z "$DEFAULT_USER" ]]; then
                echo "Error: No user provided for repo '$INPUT'. Use --user to set a default." >&2
                return 1
            fi
            EXPECTED_GIT_USER="$DEFAULT_USER"
            REPO="$INPUT"
            INPUT="$EXPECTED_GIT_USER/$REPO"
        fi
        
        ACTUAL_GIT_USER="$(gh api user --jq .login 2>/dev/null || true)"
        if [[ -z "$ACTUAL_GIT_USER" ]]; then
            echo "Error: You are not authenticated. Please run: gh auth login" >&2
            return 1
        elif [[ "$ACTUAL_GIT_USER" != "$EXPECTED_GIT_USER" ]]; then
            echo "Error: Authenticated as '$ACTUAL_GIT_USER', expected '$EXPECTED_GIT_USER'. Run: gh auth logout && gh auth login" >&2
            return 1
        fi
        
        if ! gh repo view "$INPUT" &>/dev/null; then
            shlog warn "Repo does not exist or is inaccessible: $INPUT"
            continue
        fi
        
        if [[ "$FORCE" = false ]]; then
            read -r -p "Are you sure you want to delete '$INPUT'? Type 'yes' to confirm: " CONFIRM
            if [[ "$CONFIRM" != "yes" ]]; then
                shlog info "Skipping deletion of $INPUT"
                continue
            fi
        fi
        
        shlog info "Deleting repo: $INPUT"
        gh api -X DELETE "repos/$EXPECTED_GIT_USER/$REPO" \
            > /dev/null || shlog error "Deletion failed, ensure you have delete permissions with 'gh auth refresh -s delete_repo'"
    done
}

github() {
    local cmd="${1:-}"
    case "$cmd" in
        create-repos)
            shift
            github_create_repos "$@"
            ;;
        delete-repos)
            shift
            github_delete_repos "$@"
            ;;
        help|--help|-h)
            github_help
            ;;
        *)
            echo "Error: Unknown command '$cmd'" >&2
            github_help
            return 1
            ;;
    esac
}

github "$@" 
