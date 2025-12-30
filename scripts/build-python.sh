#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PKG_DIR="$ROOT_DIR/generated/python-client"
VENV="$PKG_DIR/.venv-build"
DIST_DIR="$PKG_DIR/dist"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--upload-testpypi|--upload-pypi]
Build sdist and wheel for the package in $PKG_DIR and run 'twine check'.
If --upload-testpypi or --upload-pypi is provided, uploads using TWINE_USERNAME/TWINE_PASSWORD.
EOF
}

UPLOAD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --upload-testpypi) UPLOAD="testpypi"; shift ;;
    --upload-pypi) UPLOAD="pypi"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [ ! -d "$PKG_DIR" ]; then
  echo "Package dir not found: $PKG_DIR" >&2
  exit 1
fi

python3 -m venv "$VENV"
. "$VENV/bin/activate"

python -m pip install --upgrade pip
python -m pip install build twine

rm -rf "$DIST_DIR"
python -m build --sdist --wheel "$PKG_DIR"
python -m twine check "$DIST_DIR"/*

if [ -n "$UPLOAD" ]; then
  : "${TWINE_USERNAME:?Set TWINE_USERNAME environment variable}"
  : "${TWINE_PASSWORD:?Set TWINE_PASSWORD environment variable}"
  python -m twine upload --repository "$UPLOAD" "$DIST_DIR"/*
fi

echo "Build complete: $DIST_DIR"
