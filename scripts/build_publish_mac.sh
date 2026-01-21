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

if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is required to extract the macOS bundle."
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "Error: hdiutil is required for DMG creation (macOS only)."
  exit 1
fi

PRODUCT_NAME="$(node -p "const pkg=require('./package.json'); pkg.productName || pkg.name || 'BqScreenshot'")"

ZIP_ARCHIVE="$(find "$WORKDIR/app/out/make" -type f -name '*.zip' -path '*darwin*' | head -n 1 || true)"

if [[ -z "$ZIP_ARCHIVE" ]]; then
  echo "Error: no macOS ZIP artifact found under out/make."
  exit 1
fi

echo "Extracting $ZIP_ARCHIVE..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
unzip -q "$ZIP_ARCHIVE" -d "$TMP_DIR"

APP_BUNDLE="$(find "$TMP_DIR" -maxdepth 2 -name '*.app' -type d | head -n 1 || true)"

if [[ -z "$APP_BUNDLE" ]]; then
  echo "Error: extracted archive did not contain a .app bundle."
  exit 1
fi

DMG_DIR="$WORKDIR/app/out/make/dmg"
mkdir -p "$DMG_DIR"
DMG_NAME="${PRODUCT_NAME// /-}"
DMG_PATH="$DMG_DIR/${DMG_NAME}.dmg"

echo "Creating DMG via hdiutil..."
hdiutil create -ov -format UDZO -fs HFS+ -volname "$PRODUCT_NAME" -srcfolder "$APP_BUNDLE" "$DMG_PATH"

echo "Created DMG at $DMG_PATH"

echo "Publishing via electron-forge..."
# Ensure Apple credentials (APPLE_ID, APPLE_ID_PASSWORD, etc.) are exported before running publish.
npm run publish

echo "Done. Check out/make for generated macOS artifacts."
