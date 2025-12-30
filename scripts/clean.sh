#!/usr/bin/env bash
set -euo pipefail

DIR="$(pwd)"
JAR="$DIR/openapi-generator-cli.jar"
GEN_DIR="$DIR/generated"

if [ -f "$JAR" ]; then
  echo "Removing $JAR"
  rm -f "$JAR"
else
  echo "No JAR found at $JAR"
fi

if [ -d "$GEN_DIR" ]; then
  echo "Removing contents of $GEN_DIR"
  rm -rf "$GEN_DIR"/* "$GEN_DIR"/.[!.]* "$GEN_DIR"/..?* 2>/dev/null || true
else
  echo "No generated directory at $GEN_DIR"
fi

echo "Clean complete."

exit 0
