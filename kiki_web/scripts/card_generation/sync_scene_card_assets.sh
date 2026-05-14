#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/card_generation/sync_scene_card_assets.sh <scene_slug> <card_slug> [image_ext]
# Example: ./scripts/card_generation/sync_scene_card_assets.sh demo_animals kiki_dongwuyuan jpg

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <scene_slug> <card_slug> [image_ext]"
  exit 1
fi

SCENE_SLUG="$1"
CARD_SLUG="$2"
IMAGE_EXT="${3:-}"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
CARD_DIR="$ROOT_DIR/doc/card-generation/scene-info/$SCENE_SLUG/$CARD_SLUG"
ASSET_IMG_DIR="$ROOT_DIR/assets/images"
ASSET_JSON_DIR="$ROOT_DIR/assets/data"

if [[ ! -d "$CARD_DIR" ]]; then
  echo "Card directory not found: $CARD_DIR"
  exit 1
fi

if [[ -z "$IMAGE_EXT" ]]; then
  for ext in jpg jpeg png webp; do
    if [[ -f "$CARD_DIR/$CARD_SLUG.$ext" ]]; then
      IMAGE_EXT="$ext"
      break
    fi
  done
fi

if [[ -z "$IMAGE_EXT" ]]; then
  echo "Image file not found under: $CARD_DIR (expected $CARD_SLUG.[jpg|jpeg|png|webp])"
  exit 1
fi

SRC_IMAGE="$CARD_DIR/$CARD_SLUG.$IMAGE_EXT"
SRC_JSON="$CARD_DIR/$CARD_SLUG.json"
DST_IMAGE="$ASSET_IMG_DIR/$CARD_SLUG.$IMAGE_EXT"
DST_JSON="$ASSET_JSON_DIR/$CARD_SLUG.json"

if [[ ! -f "$SRC_JSON" ]]; then
  echo "JSON file not found: $SRC_JSON"
  exit 1
fi

mkdir -p "$ASSET_IMG_DIR" "$ASSET_JSON_DIR"
cp -f "$SRC_IMAGE" "$DST_IMAGE"
cp -f "$SRC_JSON" "$DST_JSON"

echo "Synced:"
echo "  $SRC_IMAGE -> $DST_IMAGE"
echo "  $SRC_JSON -> $DST_JSON"
