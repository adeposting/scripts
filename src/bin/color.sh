#!/bin/bash

set -oue pipefail

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e "$CWD/include" ]] && source "$CWD/include" || source "$CWD/include.sh"

include debug

_help() {
    echo
    echo
    echo "color.sh"
    echo
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  get <color>            → print ANSI escape sequence for the named color"
    echo "  set <color>            → set terminal text color to the named color"
    echo "  -color                 → reset terminal color to default"
    echo "  list                   → list all supported color names"
    echo "  echo <color> <msg>     → echo a message with the given color"
    echo "  cat <color> <file>     → cat a file with colored output"
    echo "  help, --help, -h       → show this help text"
    echo
    echo "Integration:"
    echo "  This script can be sourced in another Bash script to use its functions:"
    echo "    source /path/to/colors.sh"
    echo
    echo "  The following functions will be available:"
    echo "    get_color     → get ANSI code for color name"
    echo "    set_color     → change current terminal color"
    echo "    reset_color   → reset color to default"
    echo "    color_echo    → print a message in color"
    echo "    color_cat     → print a file in color"
    echo
}

get_color() {
    local color="${1:-}"
    case "$color" in
        black)         printf '\033[0;30m' ;;
        red)           printf '\033[0;31m' ;;
        green)         printf '\033[0;32m' ;;
        yellow)        printf '\033[0;33m' ;;
        blue)          printf '\033[0;34m' ;;
        magenta|purple) printf '\033[0;35m' ;;
        cyan)          printf '\033[0;36m' ;;
        white)         printf '\033[0;37m' ;;

        bright-black|gray|grey)   printf '\033[1;30m' ;;
        bright-red)               printf '\033[1;31m' ;;
        bright-green)             printf '\033[1;32m' ;;
        bright-yellow)            printf '\033[1;33m' ;;
        bright-blue)              printf '\033[1;34m' ;;
        bright-magenta|bright-purple) printf '\033[1;35m' ;;
        bright-cyan)              printf '\033[1;36m' ;;
        bright-white)             printf '\033[1;37m' ;;

        reset|default)            printf '\033[0m' ;;
        *)                        printf '' ;;
    esac
}

set_color() {
    local color="${1:-}"
    local code
    code="$(get_color "$color")"
    if [[ -n "$code" ]]; then
        echo -en "$code"
    else
        echo "Unknown color: $color" >&2
        return 1
    fi
}

reset_color() {
    set_color reset
}

list_colors() {
    grep -Eo "^[ ]*[a-z0-9|\-]+" "$BASH_SOURCE" \
      | sed -E 's/^[ ]*//' \
      | grep -vE 'case|\*' \
      | tr '|' '\n' \
      | sort -u
}

color_echo() {
    local color="${1:-}"
    shift
    local code
    code="$(get_color "$color")"
    local reset
    reset="$(get_color reset)"
    if [[ -n "$code" ]]; then
        echo -e "${code}$*${reset}"
    else
        echo "Unknown color: $color" >&2
        return 1
    fi
}

color_cat() {
    local color="${1:-}"
    local file="${2:-}"
    if [[ ! -f "$file" ]]; then
        echo "File not found: $file" >&2
        return 1
    fi
    set_color "$color"
    cat "$file"
    reset_color
}

_main() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        get)         get_color "$@" ;;
        set)         set_color "$@" ;;
        reset) reset_color ;;
        list)        list_colors ;;
        echo)        color_echo "$@" ;;
        cat)         color_cat "$@" ;;
        help|--help|-h) _help ;;
        *)           _help; return 1 ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
else
    export -f get_color set_color reset_color color_echo color_cat
fi
