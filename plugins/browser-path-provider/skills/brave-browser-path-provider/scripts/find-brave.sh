#!/usr/bin/env bash
# find-brave.sh — Locates the Brave browser executable on macOS and Linux.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

brave_path=""

case "$(uname -s)" in
  Darwin)
    candidates=(
      "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
      "$HOME/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    )
    ;;
  Linux)
    candidates=(
      "/usr/bin/brave-browser"
      "/usr/bin/brave-browser-stable"
      "/usr/bin/brave-browser-beta"
      "/snap/bin/brave"
    )
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    brave_path="$c"
    break
  fi
done

# Linux fallback: try PATH
if [ -z "$brave_path" ] && [ "$(uname -s)" = "Linux" ]; then
  brave_path=$(which brave-browser 2>/dev/null || which brave 2>/dev/null || true)
fi

if [ -n "$brave_path" ]; then
  echo "Brave executable path: $brave_path"
  exit 0
else
  echo "Brave is not installed. None of the standard locations contain a Brave executable."
  echo "Download Brave at: https://brave.com/download"
  exit 1
fi
