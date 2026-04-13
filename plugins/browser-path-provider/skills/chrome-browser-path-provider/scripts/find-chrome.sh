#!/usr/bin/env bash
# find-chrome.sh — Locates the Google Chrome executable on macOS and Linux.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

chrome_path=""

case "$(uname -s)" in
  Darwin)
    candidates=(
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      "$HOME/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    )
    ;;
  Linux)
    candidates=(
      "/usr/bin/google-chrome"
      "/usr/bin/google-chrome-stable"
      "/usr/bin/chromium-browser"
      "/usr/bin/chromium"
      "/snap/bin/chromium"
      "/snap/bin/google-chrome"
    )
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    chrome_path="$c"
    break
  fi
done

# Linux fallback: try PATH
if [ -z "$chrome_path" ] && [ "$(uname -s)" = "Linux" ]; then
  chrome_path=$(which google-chrome 2>/dev/null || which google-chrome-stable 2>/dev/null || which chromium-browser 2>/dev/null || which chromium 2>/dev/null || true)
fi

if [ -n "$chrome_path" ]; then
  echo "Chrome executable path: $chrome_path"
  exit 0
else
  echo "Google Chrome is not installed. None of the standard locations contain a Chrome executable."
  echo "Download Chrome at: https://www.google.com/chrome/"
  exit 1
fi
