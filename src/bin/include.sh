#!/bin/bash

set -oue pipefail

_help() {
  echo
  echo "include.sh"
  echo
  echo "  Provides an 'include' function to source sibling scripts by name (with or without .sh)."
  echo
  echo "Usage (from script):"
  echo "  source /path/to/include"
  echo "  include debug"
  echo
  echo "Usage (via PATH):"
  echo "  source <(include)      # temporarily"
  echo "  echo 'source \$(which include)' >> ~/.bashrc  # permanently"
  echo
  echo "Notes:"
  echo "  This script must be *sourced* to define the 'include' function in your shell."
  echo "  Running it directly will show this help text and do nothing else."
  echo
  echo "Features:"
  echo "  - Automatically resolves calling script directory"
  echo "  - Supports both '<name>' and '<name>.sh'"
  echo
}

include() {
  local CALLER="${BASH_SOURCE[1]}"
  local DIR="$(cd "$(dirname "$CALLER")" && pwd)"
  local NAME="$1"

  if [[ -f "$DIR/$NAME" ]]; then
    source "$DIR/$NAME"
  elif [[ -f "$DIR/$NAME.sh" ]]; then
    source "$DIR/$NAME.sh"
  else
    echo "include: cannot find '$NAME' or '$NAME.sh' in $DIR" >&2
    return 1
  fi
}

# Behavior control: show help if executed, export if sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _help
else
  export -f include
fi
