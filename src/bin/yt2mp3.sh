#!/bin/bash

set -euo pipefail

# === Functions ===

print_usage() {
  cat <<EOF
Usage: $0 [URL ...]
Download one or more YouTube videos and extract high-quality audio.
You can also pipe URLs into this script.

Examples:
  $0 https://www.youtube.com/watch?v=...
  echo "https://youtu.be/..." | $0
  cat urls.txt | $0

Options:
  -h, --help    Show this help message and exit
EOF
}

ensure_dependencies() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh/"
    exit 1
  fi

  for dep in yt-dlp ffmpeg; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      echo "Installing missing dependency: $dep"
      brew install "$dep"
    fi
  done
}

parse_input() {
  if [[ $# -gt 0 ]]; then
    for arg in "$@"; do
      echo "$arg"
    done
  else
    cat
  fi
}

download_and_extract_audio() {
  local url="$1"

  echo "Processing URL $url..."
  local -r title=$(yt-dlp --get-title "$url" | tr -d '\n' | tr -cd '[:alnum:] _-' | tr ' ' '_')

  echo "Downloading audio for $title"
  yt-dlp -f bestaudio -o "${title}.tmp" "$url"

  local -r tmpfile=$(find . -type f -name "${title}.tmp*" | head -n 1)
  local -r audiofile="${title}.mp3"

  echo "Extracting audio from $tmpfile to $audiofile..."
  ffmpeg -y -i "$tmpfile" -vn -acodec libmp3lame -q:a 0 "$audiofile"

  echo "Cleaning up $tmpfile..."
  rm -f "$tmpfile"
}

main() {
  if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    print_usage
    exit 0
  fi

  ensure_dependencies

  local urls=()
  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    urls+=("$url")
  done < <(parse_input "$@")

  if [[ ${#urls[@]} -eq 0 ]]; then
    echo "No URLs provided."
    print_usage
    exit 1
  fi

  for url in "${urls[@]}"; do
    download_and_extract_audio "$url"
  done
}

# === Entry Point ===
main "$@"

