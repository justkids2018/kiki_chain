#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/deploy-release/bin/common.sh
source "$SCRIPT_DIR/bin/common.sh"

PROFILE_NAME="${1:-}"
load_profile "$PROFILE_NAME"

print_header "检查远端目录整洁度 (${DEPLOY_PROVIDER})"
ensure_ssh

allowed_regex='^(\./backups|\./scripts|\./scripts/deploy-release)$'

remote_dirs=$(ssh "$SERVER" "cd $REMOTE_DIR && find . -maxdepth 2 -mindepth 1 -type d | sort")

echo "$remote_dirs"

echo -e "${YELLOW}校验仅保留: backups / scripts / scripts/deploy-release${NC}"

unexpected=$(echo "$remote_dirs" | grep -Ev "$allowed_regex" || true)
if [[ -n "$unexpected" ]]; then
  echo -e "${RED}❌ 发现非预期目录:${NC}"
  echo "$unexpected"
  exit 1
fi

echo -e "${GREEN}✅ 远端目录结构整洁${NC}"
