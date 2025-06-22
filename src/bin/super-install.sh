#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug
include log
include ostype

_help() {
    echo
    echo "super-install.sh"
    echo
    echo "  Usage: super_install <command>..."
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
    echo "  You can source this script to reuse the super_install function:"
    echo "    source /path/to/super-install.sh"
    echo
    echo "  This will make the following function available:"
    echo "    super_install  → install missing commands using system package manager"
    echo
}


super_install() {
  local os
  os="$(ostype)"

  if [[ "$os" == "darwin" ]]; then
    if command -v brew >/dev/null; then
      for pkg in "$@"
      do
        if ! command -v $pkg >/dev/null
        then
          brew install "$pkg" || brew install --cask "$pkg" 
        fi
      done
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
  super_install "$@"
else
  export -f super_install
fi
