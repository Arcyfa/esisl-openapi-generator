#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$ROOT_DIR/config.json"

if [ ! -f "$CONFIG" ]; then
  echo "0.0.0"
  exit 0
fi

# Try to extract `packageVersion` from `additionalProperties` block first,
# then fallback to top-level `packageVersion`, then `version`.
version=""

# 1) Try within the additionalProperties block
version=$(sed -n '/"additionalProperties"[[:space:]]*:/,/}/p' "$CONFIG" \
  | sed -n 's/.*"packageVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | tr -d '\r' | head -n1 || true)

# 2) Fallback to top-level packageVersion
if [ -z "$version" ]; then
  version=$(sed -n 's/.*"packageVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG" \
    | tr -d '\r' | head -n1 || true)
fi

# 3) Fallback to version
if [ -z "$version" ]; then
  version=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG" \
    | tr -d '\r' | head -n1 || true)
fi

if [ -z "$version" ]; then
  version="0.0.0"
fi

echo "$version"
