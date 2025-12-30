#!/usr/bin/env bash
set -euo pipefail
DIR="$PWD"   # calling directory

# JVM options
JVM_OPTS=(
  -Dorg.slf4j.simpleLogger.defaultLogLevel=warn
  -Dorg.slf4j.simpleLogger.log.org.openapitools=warn
  -Dorg.slf4j.simpleLogger.log.org.openapitools.codegen=warn
  -Dorg.slf4j.simpleLogger.showThreadName=false
  --add-opens java.base/java.util=ALL-UNNAMED
  --add-opens java.base/java.lang=ALL-UNNAMED
)

JAR_PATH="./openapi-generator-cli.jar"
CONFIG_PATH="./config.json"
TEMPLATE_DIR="$DIR/templates/ts"

# If the JAR is not present, download a default version from Maven Central.
# Override with environment variables:
#  OPENAPI_GENERATOR_CLI_VERSION (e.g. 6.6.0)
#  OPENAPI_GENERATOR_CLI_URL to set a full custom URL
# Determine which jar version to use:
# Priority:
# 1) OPENAPI_GENERATOR_CLI_URL (full URL)
# 2) OPENAPI_GENERATOR_CLI_VERSION (explicit version)
# 3) Resolve latest from Maven metadata
# 4) Fallback to known-good version 7.18.0
FALLBACK_VERSION="7.17.0"
BASE_URL="https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli"
METADATA_URL="/maven-metadata.xml"

if [ -n "${OPENAPI_GENERATOR_CLI_URL:-}" ]; then
  JAR_URL="$OPENAPI_GENERATOR_CLI_URL"
else
  if [ -n "${OPENAPI_GENERATOR_CLI_VERSION:-}" ]; then
    JAR_VERSION="$OPENAPI_GENERATOR_CLI_VERSION"
  else
    # try to resolve <release> from maven-metadata.xml, otherwise take last <version>
    RESOLVED=""
    if command -v curl >/dev/null 2>&1; then
      METADATA_XML=$(curl -fsSL "$METADATA_URL" 2>/dev/null || true)
    elif command -v wget >/dev/null 2>&1; then
      METADATA_XML=$(wget -qO- "$METADATA_URL" 2>/dev/null || true)
    else
      METADATA_XML=""
    fi
    if [ -n "$METADATA_XML" ]; then
      RESOLVED=$(printf '%s' "$METADATA_XML" | sed -n 's:.*<release>\(.*\)</release>.*:\1:p' | head -n1)
      if [ -z "$RESOLVED" ]; then
        RESOLVED=$(printf '%s' "$METADATA_XML" | sed -n 's:.*<version>\(.*\)</version>.*:\1:p' | tail -n1)
      fi
    fi
    if [ -n "$RESOLVED" ]; then
      JAR_VERSION="$RESOLVED"
    else
      JAR_VERSION="$FALLBACK_VERSION"
    fi
  fi
  DEFAULT_JAR_URL="https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${JAR_VERSION}/openapi-generator-cli-${JAR_VERSION}.jar"
  JAR_URL="${DEFAULT_JAR_URL}"
fi

# If JAR missing, attempt to download JAR_URL; on failure try GitHub release for the same version.
if [ ! -f "$JAR_PATH" ]; then
  GITHUB_RELEASE_URL="https://github.com/OpenAPITools/openapi-generator/releases/download/v${JAR_VERSION}/openapi-generator-cli-${JAR_VERSION}.jar"

  try_download() {
    url="$1"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$url" -o "$JAR_PATH" 2>/dev/null && return 0 || return 1
    elif command -v wget >/dev/null 2>&1; then
      wget -q -O "$JAR_PATH" "$url" >/dev/null 2>&1 && return 0 || return 1
    else
      return 2
    fi
  }

  if try_download "$JAR_URL"; then
    echo "Downloaded openapi-generator CLI jar"
  elif [ -n "${JAR_VERSION:-}" ] && try_download "$GITHUB_RELEASE_URL"; then
    echo "Downloaded openapi-generator CLI jar from GitHub release"
  else
    echo "Error: could not download openapi-generator CLI. Please set OPENAPI_GENERATOR_CLI_URL or install the jar at $JAR_PATH." >&2
    exit 2
  fi
fi

# stop linter from complaining
mkdir -p generated/ts-client/src/
cp -f temp/serviceFacade.ts generated/ts-client/src/
# --model-name-prefix Api

GEN_CMD=(java "${JVM_OPTS[@]}" -jar "$JAR_PATH" generate -c "$CONFIG_PATH" -t "$TEMPLATE_DIR" --skip-validate-spec)

# Always run quietly: filter noisy TemplateManager INFO lines but keep WARN/ERROR
set -o pipefail
"${GEN_CMD[@]}" 2>&1 | sed -E '/TemplateManager|writing file|\[main\] INFO/d'

exit 0


