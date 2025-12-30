#!/usr/bin/env bash
set -euo pipefail

#!/usr/bin/env bash
set -euo pipefail

# Run tests for the generated TypeScript client
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="$ROOT_DIR/generated/ts-client"

if [ ! -d "$PKG_DIR" ]; then
  echo "Error: generated package not found at $PKG_DIR" >&2
  exit 1
fi

cd "$PKG_DIR"

if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then
  npm ci --silent
else
  npm install --silent
fi

if npm run | sed -n '1,200p' | grep -q " test"; then
  npm test --silent
else
  echo "No test script defined in package.json; skipping tests"
fi

exit 0
