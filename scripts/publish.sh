#!/bin/bash
set -euo pipefail

cd ./generated/ts-client

# clean install
npm ci

npm run build

# create package tarball
npm pack

# publish and login with OTP
npm publish --otp=

cd ../..
