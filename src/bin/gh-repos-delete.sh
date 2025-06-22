#!/bin/bash
set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CWD/debug.sh"
source "$CWD/log.sh"

_help() {
  echo
  echo "gh-repos-delete.sh"
  echo
  echo "  Usage: gh_repos_delete --repos <repo>... [--user <user>] [--force]"
  echo
  echo "Options:"
  echo "  --repos   <repo>...   → one or more repo names (with or without owner prefix)"
  echo "  --user    <username>  → default GitHub username (used if repo has no owner prefix)"
  echo "  --force               → skip confirmation prompt"
  echo
  echo "Integration:"
  echo "  You can source this script to reuse the gh_repos_delete function:"
  echo "    source /path/to/gh-repos-delete.sh"
  echo
  echo "  This will make the following function available:"
  echo "    gh_repos_delete → delete GitHub repos with confirmation and checks"
  echo
}

gh_repos_delete() {
  local DEFAULT_USER=""
  local FORCE=false
  local REPOS=()

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --user)  DEFAULT_USER="$2"; shift 2 ;;
      --force) FORCE=true; shift ;;
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
        return 1
    elif [[ "$ACTUAL_GIT_USER" != "$EXPECTED_GIT_USER" ]]; then
        log_error "Authenticated as '$ACTUAL_GIT_USER', expected '$EXPECTED_GIT_USER'. Run: gh auth logout && gh auth login"
        return 1
    fi

    if ! gh repo view "$INPUT" &>/dev/null; then
      log_warn "Repo does not exist or is inaccessible: $INPUT"
      continue
    fi

    if [[ "$FORCE" = false ]]; then
      read -p "Are you sure you want to delete '$INPUT'? Type 'yes' to confirm: " CONFIRM
      if [[ "$CONFIRM" != "yes" ]]; then
        log_note "Skipping deletion of $INPUT"
        continue
      fi
    fi

    log_info "Deleting repo: $INPUT"
    gh api -X DELETE "repos/$EXPECTED_GIT_USER/$REPO" \
    > /dev/null || log_error "Deletion failied, ensure you have delete permissions with 'gh auth refresh -s delete_repo'"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  gh_repos_delete "$@"
else
  export -f gh_repos_delete
fi
