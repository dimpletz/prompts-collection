#!/usr/bin/env bash
# find-edge.sh — Locates the Microsoft Edge executable on macOS and Linux.
# Checks standard installation directories and outputs the first path found,
# or exits with code 1 and prints a not-found message.

edge_path=""

case "$(uname -s)" in
  Darwin)
    candidates=(
      "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
      "$HOME/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    )
    ;;
  Linux)
    candidates=(
      "/usr/bin/microsoft-edge"
      "/usr/bin/microsoft-edge-stable"
      "/usr/bin/microsoft-edge-beta"
      "/usr/bin/microsoft-edge-dev"
      "/snap/bin/microsoft-edge"
    )
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    edge_path="$c"
    break
  fi
done

# Linux fallback: try PATH
if [ -z "$edge_path" ] && [ "$(uname -s)" = "Linux" ]; then
  edge_path=$(which microsoft-edge 2>/dev/null || which microsoft-edge-stable 2>/dev/null || true)
fi

if [ -n "$edge_path" ]; then
  echo "Edge executable path: $edge_path"
  exit 0
else
  echo "Microsoft Edge is not installed. None of the standard locations contain an Edge executable."
  echo "Download Edge at: https://www.microsoft.com/edge"
  exit 1
fi
