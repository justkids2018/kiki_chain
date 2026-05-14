#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/card_generation/init_scene_card.sh <scene_slug> <card_slug> [image_ext]
# Example: ./scripts/card_generation/init_scene_card.sh demo_classroom kiki_jiaoshi jpg

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <scene_slug> <card_slug> [image_ext]"
  exit 1
fi

SCENE_SLUG="$1"
CARD_SLUG="$2"
IMAGE_EXT="${3:-jpg}"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
CARD_DIR="$ROOT_DIR/doc/card-generation/scene-info/$SCENE_SLUG/$CARD_SLUG"

mkdir -p "$CARD_DIR"

IMAGE_PATH="$CARD_DIR/$CARD_SLUG.$IMAGE_EXT"
JSON_PATH="$CARD_DIR/$CARD_SLUG.json"
PROMPT_PATH="$CARD_DIR/prompt.md"

if [[ ! -f "$PROMPT_PATH" ]]; then
  cat > "$PROMPT_PATH" <<EOF
# Prompt - $CARD_SLUG

## 场景
- scene_slug: $SCENE_SLUG
- card_slug: $CARD_SLUG

## 生成要求
- 分辨率: 1024x1024
- 风格: 3D 卡通等距
- 数量: 8 个词条，卡片文字清晰

## 待办
- 生成图片并保存为: $CARD_SLUG.$IMAGE_EXT
- 生成热区并保存为: $CARD_SLUG.json
EOF
fi

if [[ ! -f "$JSON_PATH" ]]; then
  cat > "$JSON_PATH" <<'EOF'
[]
EOF
fi

echo "Created/checked:"
echo "  $CARD_DIR"
echo "  $IMAGE_PATH"
echo "  $JSON_PATH"
echo "  $PROMPT_PATH"
