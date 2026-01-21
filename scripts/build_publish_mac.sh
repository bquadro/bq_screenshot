#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKDIR/app"

NODE_VERSION="$(node -v 2>/dev/null || echo '')"
NODE_MAJOR="$(echo "${NODE_VERSION#v}" | cut -d. -f1)"
REQUIRED_MAJOR="25"

if [[ "$NODE_MAJOR" != "$REQUIRED_MAJOR" ]]; then
  echo "Node.js $REQUIRED_MAJOR is required for this build, found $NODE_VERSION"
  exit 1
fi

echo "Installing dependencies..."
npm install

echo "Creating make artifacts..."
npm run make

echo "Publishing via electron-forge..."
# Ensure Apple credentials (APPLE_ID, APPLE_ID_PASSWORD, etc.) are exported before running publish.
npm run publish

echo "Done. Check out/make for generated macOS artifacts."
