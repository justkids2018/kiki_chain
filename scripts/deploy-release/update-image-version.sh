#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSION_FILE="$SCRIPT_DIR/versions/current.env"
DOC_FILE="$SCRIPT_DIR/docker-image-version.md"

TAG="${1:-}"
COMMIT_SHA="${2:-$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)}"
UPDATED_AT="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ -z "$TAG" ]]; then
  echo "Usage: ./scripts/deploy-release/update-image-version.sh <image-tag> [commit-sha]"
  exit 1
fi

cat > "$VERSION_FILE" <<EOF
# Current deploy image tag for scripts/deploy-release
# Updated by scripts/deploy-release/update-image-version.sh
DEPLOY_IMAGE_TAG=${TAG}
EOF

mkdir -p "$(dirname "$DOC_FILE")"
cat > "$DOC_FILE" <<EOF
# Docker Image Version

- Updated At: ${UPDATED_AT}
- Commit: ${COMMIT_SHA}
- Image Tag: ${TAG}

## Images

- ghcr.io/justkids2018/kiki-chain-backend:${TAG}
- ghcr.io/justkids2018/kiki-chain-admin:${TAG}

## Usage

1. Build and push images via GitHub Actions (kiki branch push).
2. Update this version file:
   - ./scripts/deploy-release/update-image-version.sh ${TAG}
3. Deploy with current tracked version:
   - ./scripts/deploy-release/step1-prepare.sh tencent
   - ./scripts/deploy-release/step2-deploy.sh tencent

EOF

echo "Updated version file: $VERSION_FILE"
echo "Updated document: $DOC_FILE"
