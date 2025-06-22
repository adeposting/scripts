#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log

_help() {
  echo
  echo "gh-repos-create.sh"
  echo
  echo "  Usage: gh_repos_create --repos <repo>... [--user <user>] [--license <license>] [--branch <branch-name>]"
  echo
  echo "Options:"
  echo "  --repos   <repo>...   → one or more repo names (with or without owner prefix)"
  echo "  --user    <username>  → default GitHub username (used if repo has no owner prefix)"
  echo "  --license <license>   → license to apply (default: MIT)"
  echo "  --branch  <name>      → create branch after repo creation"
  echo
  echo "Integration:"
  echo "  You can source this script to reuse the gh_repos_create function:"
  echo "    source /path/to/gh-repos-create.sh"
  echo
  echo "  This will make the following function available:"
  echo "    gh_repos_create → create GitHub repos with sensible defaults"
  echo
}

gh_repos_create() {
  local DEFAULT_USER=""
  local LICENSE="MIT"
  local BRANCH_NAME=""
  local REPOS=()

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --user)     DEFAULT_USER="$2"; shift 2 ;;
      --license)  LICENSE="$2"; shift 2 ;;
      --branch)   BRANCH_NAME="$2"; shift 2 ;;
      --repos)
        shift
        while [[ "$#" -gt 0 && ! "$1" =~ ^-- ]]; do
          REPOS+=("$1")
          shift
        done
        ;;
      --help|-h)
        _help
        return 0
        ;;
      *)
        log_error "Unknown argument: $1"
        return 1
        ;;
    esac
  done

  if [[ "${#REPOS[@]}" -eq 0 ]]; then
    log_error "--repos must be provided with one or more space-separated repo names."
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
        log_error "No user provided for repo '$INPUT'. Use --user to set a default."
        return 1
      fi
      EXPECTED_GIT_USER="$DEFAULT_USER"
      REPO="$INPUT"
      INPUT="$EXPECTED_GIT_USER/$REPO"
    fi

    ACTUAL_GIT_USER="$(gh api user --jq .login 2>/dev/null || true)"

    if [[ -z "$ACTUAL_GIT_USER" ]]; then
        log_error "You are not authenticated. Please run: gh auth login"
    elif [[ "$ACTUAL_GIT_USER" != "$EXPECTED_GIT_USER" ]]; then
        log_error "Authenticated as '$ACTUAL_GIT_USER', expected '$EXPECTED_GIT_USER'. Run: gh auth logout && gh auth login"
    fi

    if gh repo view "$INPUT" &>/dev/null; then
      log_note "Skipping existing repo: $INPUT"
      continue
    fi

    log_info "Creating repo: $INPUT"
    gh repo create "$INPUT" \
      --private \
      --description "" \
      --disable-wiki \
      --disable-issues \
      --license="$LICENSE" \
      --add-readme

    log_info "Patching repo settings: $INPUT"
    gh api -X PATCH "repos/$EXPECTED_GIT_USER/$REPO" \
      -f has_projects=$HAS_PROJECTS \
      -f allow_merge_commit=$ALLOW_MERGE_COMMIT \
      -f allow_squash_merge=$ALLOW_SQUASH_MERGE \
      -f allow_rebase_merge=$ALLOW_REBASE_MERGE \
      > /dev/null

    if [[ -n "$BRANCH_NAME" ]]; then
      log_info "Creating branch '$BRANCH_NAME' in $INPUT"
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  gh_repos_create "$@"
else
  export -f gh_repos_create
fi
