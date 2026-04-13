#!/usr/bin/env bash
# find-firefox.sh — Locates the Mozilla Firefox executable on macOS and Linux.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

firefox_path=""

case "$(uname -s)" in
  Darwin)
    candidates=(
      "/Applications/Firefox.app/Contents/MacOS/firefox"
      "$HOME/Applications/Firefox.app/Contents/MacOS/firefox"
    )
    ;;
  Linux)
    candidates=(
      "/usr/bin/firefox"
      "/usr/bin/firefox-esr"
      "/snap/bin/firefox"
      "/usr/lib/firefox/firefox"
    )
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    firefox_path="$c"
    break
  fi
done

# Linux fallback: try PATH
if [ -z "$firefox_path" ] && [ "$(uname -s)" = "Linux" ]; then
  firefox_path=$(which firefox 2>/dev/null || which firefox-esr 2>/dev/null || true)
fi

if [ -n "$firefox_path" ]; then
  echo "Firefox executable path: $firefox_path"
  exit 0
else
  echo "Mozilla Firefox is not installed. None of the standard locations contain a Firefox executable."
  echo "Download Firefox at: https://www.mozilla.org/firefox"
  exit 1
fi
