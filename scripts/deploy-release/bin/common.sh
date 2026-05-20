#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
UNIFIED_DIR="$ROOT_DIR/scripts/deploy-release"
DEFAULT_PROFILE="$UNIFIED_DIR/profiles/tencent.env"
LOCAL_ARTIFACTS_DIR="$UNIFIED_DIR/deploy_files"
LOCAL_LATEST_DIR="$LOCAL_ARTIFACTS_DIR/latest"
LOCAL_RELEASES_DIR="$LOCAL_ARTIFACTS_DIR/releases"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

load_profile() {
  local profile_arg="${1:-}"

  if [[ -z "$profile_arg" ]]; then
    PROFILE_FILE="$DEFAULT_PROFILE"
  elif [[ -f "$profile_arg" ]]; then
    PROFILE_FILE="$profile_arg"
  else
    PROFILE_FILE="$UNIFIED_DIR/profiles/$profile_arg.env"
  fi

  if [[ ! -f "$PROFILE_FILE" ]]; then
    echo -e "${RED}❌ Profile not found: $PROFILE_FILE${NC}"
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$PROFILE_FILE"

  SERVER="${DEPLOY_SSH_USER}@${DEPLOY_SERVER_IP}"
  REMOTE_DIR="$DEPLOY_REMOTE_DIR"
  STACK_NAME="$DEPLOY_STACK_NAME"
  COMPOSE_FILE="scripts/deploy-release/docker-compose.yml"
}

print_header() {
  local title="$1"
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  $title${NC}"
  echo -e "${CYAN}========================================${NC}"
}

ensure_ssh() {
  echo -e "${YELLOW}检查 SSH 连接: $SERVER${NC}"
  if ! ssh -o ConnectTimeout=5 "$SERVER" "echo ok" >/dev/null 2>&1; then
    echo -e "${RED}❌ SSH 连接失败: $SERVER${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ SSH 连接正常${NC}"
}

sync_deploy_assets() {
  echo -e "${YELLOW}同步部署所需最小资产到远端目录: $REMOTE_DIR${NC}"
  ssh "$SERVER" "mkdir -p $REMOTE_DIR"

  rsync -az \
    --include 'scripts/' \
    --include 'scripts/deploy-release/***' \
    --exclude '*' \
    "$ROOT_DIR/" "$SERVER:$REMOTE_DIR/"

  echo -e "${GREEN}✅ 部署资产同步完成（仅部署目录）${NC}"
}

remote_compose() {
  local compose_cmd="$1"
  ssh "$SERVER" "cd $REMOTE_DIR && docker compose -p $STACK_NAME -f $COMPOSE_FILE --env-file scripts/deploy-release/runtime/.env $compose_cmd"
}

preflight_conflict_check() {
  echo -e "${YELLOW}预检查: 命名与端口冲突${NC}"

  case "$REMOTE_DIR" in
    *"kiki_chain"*|*"qisd_eda_college"*)
      echo -e "${YELLOW}⚠️ 当前 DEPLOY_REMOTE_DIR 仍指向历史项目目录: $REMOTE_DIR${NC}"
      echo -e "${YELLOW}建议使用独立目录（例如 ~/kk_project），避免与旧项目混合。${NC}"
      ;;
    *)
      echo -e "${GREEN}✅ 远端目录独立: $REMOTE_DIR${NC}"
      ;;
  esac

  if [[ "$STACK_NAME" != kiki* ]]; then
    echo -e "${YELLOW}⚠️ 建议 DEPLOY_STACK_NAME 使用 kiki 前缀，当前: $STACK_NAME${NC}"
  else
    echo -e "${GREEN}✅ Stack 命名符合前缀规范: $STACK_NAME${NC}"
  fi

  local conflict_output
  conflict_output=$(ssh "$SERVER" "docker ps --format '{{.Names}} {{.Ports}}' | grep -E '127.0.0.1:(${DEPLOY_ADMIN_HOST_PORT}|${DEPLOY_BACKEND_HOST_PORT}|${DEPLOY_POSTGRES_HOST_PORT})->' | grep -v '^${STACK_NAME}-' || true")

  if [[ -n "$conflict_output" ]]; then
    echo -e "${RED}❌ 端口冲突，以下容器已占用目标端口:${NC}"
    echo "$conflict_output"
    echo -e "${YELLOW}请在 profile 中修改 DEPLOY_*_HOST_PORT 后重试。${NC}"
    exit 1
  fi

  echo -e "${GREEN}✅ 端口预检查通过${NC}"
}
