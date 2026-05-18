#!/usr/bin/env bash
# Fetch the protagonist source photo for convert_image_to_sprite.
# Image is press photography hosted at the URL below — kept out of git.

set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p assets/source

URL="https://i.epochtimes.com/assets/uploads/2025/04/id14478400-GettyImages-2208183148.jpg"
DEST="assets/source/trump.jpg"

if [ -f "$DEST" ]; then
  echo "[download_assets] already present: $DEST"
  exit 0
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$DEST"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$URL" -O "$DEST"
else
  echo "Need curl or wget on PATH." >&2
  exit 1
fi

echo "[download_assets] saved: $DEST"
