#!/usr/bin/env bash
set -euo pipefail

# Run tox inside a venv located at generated/python-client/.venv
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="$ROOT_DIR/generated/ts-client"
VENV_DIR="$PKG_DIR/.venv"

if [ ! -d "$PKG_DIR" ]; then
  echo "Error: generated package not found at $PKG_DIR" >&2
  exit 1
fi

python_cmd="python3"
if ! command -v "$python_cmd" >/dev/null 2>&1; then
  python_cmd="python"
fi

echo "Creating venv at $VENV_DIR (if missing)"
if [ ! -d "$VENV_DIR" ]; then
  "$python_cmd" -m venv "$VENV_DIR"
fi

echo "Activating venv and installing tox..."
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel >/dev/null
pip install --upgrade tox >/dev/null

echo "Running tox in $PKG_DIR"
cd "$PKG_DIR"
tox -v
EXIT_CODE=$?
deactivate || true
exit $EXIT_CODE
