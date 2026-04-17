#!/usr/bin/env bash
# install-python.sh — Downloads and installs Python on macOS/Linux from source.
# Usage: bash install-python.sh [<version>]
# Falls back to DEFAULT_PYTHON_VERSION env var, then to '3.14.4'.

set -euo pipefail

PYTHON_VERSION="${1:-${DEFAULT_PYTHON_VERSION:-3.14.4}}"
ARCHIVE_NAME="Python-$PYTHON_VERSION.tgz"
DOWNLOAD_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$ARCHIVE_NAME"
TEMP_DIR=$(mktemp -d)
ARCHIVE_PATH="$TEMP_DIR/$ARCHIVE_NAME"

echo "Downloading Python $PYTHON_VERSION from $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$ARCHIVE_PATH"

echo "Extracting $ARCHIVE_NAME..."
tar -xzf "$ARCHIVE_PATH" -C "$TEMP_DIR"

echo "Configuring Python $PYTHON_VERSION..."
cd "$TEMP_DIR/Python-$PYTHON_VERSION"
./configure --enable-optimizations

echo "Building Python $PYTHON_VERSION..."
make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)"

echo "Installing Python $PYTHON_VERSION..."
sudo make altinstall

echo "Python $PYTHON_VERSION installation complete."
