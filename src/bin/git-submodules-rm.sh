#!/bin/bash
set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CWD/debug.sh"
source "$CWD/log.sh"

_help() {
  echo
  echo "git-submodules-rm.sh"
  echo
  echo "  Usage: git-submodules-rm <submodule>..."
  echo
  echo "Arguments:"
  echo "  <submodule>...    → one or more submodule paths to remove"
  echo
  echo "Integration:"
  echo "  You can source this script to reuse the git_submodules_rm function:"
  echo "    source /path/to/git-submodules-rm.sh"
  echo
  echo "  This will make the following function available:"
  echo "    git_submodules_rm → remove git submodules cleanly and safely"
  echo
}

git_submodules_rm() {
  if [[ "$#" -eq 0 ]]; then
    log_error "You must provide at least one submodule path to remove."
    return 1
  fi

  for SUBMODULE in $@; do
    SUBMODULE="$(echo "$SUBMODULE" | xargs)"
    if [[ -z "$SUBMODULE" ]]; then continue; fi

    log_info "Attempting to remove submodule: $SUBMODULE"

    # Remove from .gitmodules
    if git config -f .gitmodules --get-regexp "submodule\.$SUBMODULE\." &>/dev/null; then
      log_info "Removing section from .gitmodules"
      git config -f .gitmodules --remove-section "submodule.$SUBMODULE" || true
    else
      log_warn "No .gitmodules section for submodule: $SUBMODULE"
    fi

    # Remove from .git/config
    if git config --get-regexp "submodule\.$SUBMODULE\." &>/dev/null; then
      log_info "Removing section from .git/config"
      git config --remove-section "submodule.$SUBMODULE" || true
    fi

    # Remove from index (ignore errors if not added)
    if git ls-files --stage "$SUBMODULE" &>/dev/null; then
      log_info "Removing submodule from Git index"
      git rm -f "$SUBMODULE" || true
    else
      log_note "Submodule not staged; skipping git rm"
    fi

    # Remove submodule directory
    if [[ -d "$SUBMODULE" ]]; then
      log_info "Removing working directory: $SUBMODULE"
      rm -rf "$SUBMODULE"
    else
      log_warn "Directory does not exist: $SUBMODULE"
    fi

    # Remove git internal metadata
    if [[ -d ".git/modules/$SUBMODULE" ]]; then
      log_info "Removing submodule Git metadata: .git/modules/$SUBMODULE"
      rm -rf ".git/modules/$SUBMODULE"
    else
      log_warn "No internal .git/modules entry for: $SUBMODULE"
    fi

    # Delete the submodule if it still exists
    if [[ -d "$SUBMODULE" ]]
    then
        log_warn "Directory for submodule '$SUBMODULE' still exists"
        log_info "Falling back to 'rm -rf' for '$SUBMODULE"
        rm -rf "$SUBMODULE"
    fi

    # Final assertion
    if [[ ! -e "$SUBMODULE" && ! -e ".git/modules/$SUBMODULE" && ! $(git config -f .gitmodules --get-regexp "submodule.$SUBMODULE" 2>/dev/null) ]]; then
      log_info "Submodule '$SUBMODULE' fully removed"
    else
      log_error "Submodule '$SUBMODULE' was not fully removed"
      return 1
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  git_submodules_rm "$@"
else
  export -f git_submodules_rm
fi
