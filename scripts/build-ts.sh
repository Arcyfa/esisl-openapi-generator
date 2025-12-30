#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PKG_DIR="$ROOT_DIR/generated/ts-client"

usage() {
  cat <<EOF
Usage: $(basename "$0")
Builds the generated TypeScript client located at $PKG_DIR by running npm install and npm run build, then creates a packaged tarball with npm pack.
EOF
}

if [ ! -d "$PKG_DIR" ]; then
  echo "Package dir not found: $PKG_DIR" >&2
  exit 1
fi

cd "$PKG_DIR"
if [ ! -f package.json ]; then
  echo "No package.json found in $PKG_DIR" >&2
  exit 1
fi

# Prefer npm ci for reproducible installs when lockfile present
if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then
  npm ci --silent
else
  npm install --silent
fi

# Run build if defined
if npm run | sed -n '1,200p' | grep -q " build"; then
  npm run build --silent
fi

# Create package tarball
npm pack --silent

echo "Build complete: $(pwd)"
