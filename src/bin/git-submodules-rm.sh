#!/bin/bash

set -oue pipefail

git_submodules_rm_help() {
  color set bright-white
  echo
  echo "git-submodules-rm.sh"
  echo
  echo "  Usage: $0 <submodule>..."
  echo
  echo "Arguments:"
  echo "  <submodule>...    → one or more submodule paths to remove"
  echo "  help, --help, -h  → show this help text"
  echo
  color reset
}

git_submodules_rm() {
  local cmd="${1:-}"
  case "$cmd" in
    help|--help|-h) 
      git_submodules_rm_help 
      return 0
      ;;
    *) 
      # Main logic moved here
      if [[ "$#" -eq 0 ]]; then
        shlog error "You must provide at least one submodule path to remove."
        return 1
      fi

      for SUBMODULE in "$@"; do
        SUBMODULE="$(echo "$SUBMODULE" | xargs)"
        if [[ -z "$SUBMODULE" ]]; then continue; fi

        shlog info "Attempting to remove submodule: $SUBMODULE"

        # Remove from .gitmodules
        if git config -f .gitmodules --get-regexp "submodule\.$SUBMODULE\." &>/dev/null; then
          shlog info "Removing section from .gitmodules"
          git config -f .gitmodules --remove-section "submodule.$SUBMODULE" || true
        else
          shlog warn "No .gitmodules section for submodule: $SUBMODULE"
        fi

        # Remove from .git/config
        if git config --get-regexp "submodule\.$SUBMODULE\." &>/dev/null; then
          shlog info "Removing section from .git/config"
          git config --remove-section "submodule.$SUBMODULE" || true
        fi

        # Remove from index (ignore errors if not added)
        if git ls-files --stage "$SUBMODULE" &>/dev/null; then
          shlog info "Removing submodule from Git index"
          git rm -f "$SUBMODULE" || true
        else
          shlog info "Submodule not staged; skipping git rm"
        fi

        # Remove submodule directory
        if [[ -d "$SUBMODULE" ]]; then
          shlog info "Removing working directory: $SUBMODULE"
          rm -rf "$SUBMODULE"
        else
          shlog warn "Directory does not exist: $SUBMODULE"
        fi

        # Remove git internal metadata
        if [[ -d ".git/modules/$SUBMODULE" ]]; then
          shlog info "Removing submodule Git metadata: .git/modules/$SUBMODULE"
          rm -rf ".git/modules/$SUBMODULE"
        else
          shlog warn "No internal .git/modules entry for: $SUBMODULE"
        fi

        # Delete the submodule if it still exists
        if [[ -d "$SUBMODULE" ]]
        then
            shlog warn "Directory for submodule '$SUBMODULE' still exists"
            shlog info "Falling back to 'rm -rf' for '$SUBMODULE"
            rm -rf "$SUBMODULE"
        fi

        # Final assertion
        if [[ ! -e "$SUBMODULE" && ! -e ".git/modules/$SUBMODULE" && ! $(git config -f .gitmodules --get-regexp "submodule.$SUBMODULE" 2>/dev/null) ]]; then
          shlog info "Submodule '$SUBMODULE' fully removed"
        else
          shlog error "Submodule '$SUBMODULE' was not fully removed"
          return 1
        fi
      done
      ;;
  esac
}

git_submodules_rm "$@"
