#!/bin/bash
set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CWD/debug.sh"
source "$CWD/log.sh"
source "$CWD/ostype.sh"

_help() {
    echo
    echo "package-install.sh"
    echo
    echo "  Usage: package_install <command>..."
    echo
    echo "Behavior:"
    echo "  Installs each command if not found on the system"
    echo "  Uses the appropriate package manager for the operating system:"
    echo "    - macOS: brew (or brew cask)"
    echo "    - Debian/Ubuntu: apt"
    echo "    - Arch: pacman"
    echo "    - Fedora: dnf"
    echo "    - Void Linux: xbps-install"
    echo "    - Alpine: apk"
    echo "    - openSUSE: zypper"
    echo "    - Gentoo: emerge"
    echo
    echo "Integration:"
    echo "  You can source this script to reuse the package_install function:"
    echo "    source /path/to/package-install.sh"
    echo
    echo "  This will make the following function available:"
    echo "    package_install  → install missing commands using system package manager"
    echo
}


package_install() {
  local os
  os="$(ostype)"

  if [[ "$os" == "darwin" ]]; then
    if command -v brew >/dev/null; then
      for pkg in "$@"; do brew install "$pkg" || brew install --cask "$pkg"; done
    else
      log_error "Homebrew not installed on macOS"
      return 1
    fi
    return 0
  fi

  local manager=""
  if command -v apt >/dev/null; then manager="sudo apt install -y"
  elif command -v dnf >/dev/null; then manager="sudo dnf install -y"
  elif command -v pacman >/dev/null; then manager="sudo pacman -Sy --noconfirm"
  elif command -v xbps-install >/dev/null; then manager="sudo xbps-install -y"
  elif command -v zypper >/dev/null; then manager="sudo zypper install -y"
  elif command -v emerge >/dev/null; then manager="sudo emerge"
  elif command -v apk >/dev/null; then manager="sudo apk add"
  else log_error "No known package manager found"; return 1; fi

  for pkg in "$@"; do
    if ! command -v "$pkg" >/dev/null; then
      log_info "Installing $pkg using $manager"
      $manager "$pkg"
    else
      log_info "$pkg already installed"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  package_install "$@"
else
  export -f package_install
fi
