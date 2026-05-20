#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/deploy-release/bin/common.sh
source "$SCRIPT_DIR/bin/common.sh"

PROFILE_NAME="${1:-}"
load_profile "$PROFILE_NAME"

print_header "DB 发布流程 (${DEPLOY_PROVIDER})"

ensure_ssh

echo -e "${YELLOW}1) 启动数据库容器...${NC}"
remote_compose "up -d postgres"

echo -e "${YELLOW}  - 等待数据库就绪...${NC}"
for _ in {1..30}; do
  if remote_compose "exec -T postgres pg_isready -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER}" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if ! remote_compose "exec -T postgres pg_isready -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER}" >/dev/null 2>&1; then
  echo -e "${RED}❌ 数据库容器未就绪，终止发布。${NC}"
  exit 1
fi

BACKUP_FILE="backups/${DEPLOY_DATABASE_NAME}_$(date +%Y%m%d_%H%M%S).sql.gz"

echo -e "${YELLOW}2) 备份线上数据库...${NC}"
ssh "$SERVER" "set -o pipefail; cd $REMOTE_DIR && mkdir -p backups && docker compose -p $STACK_NAME -f $COMPOSE_FILE --env-file scripts/deploy-release/runtime/.env exec -T postgres pg_dump -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} ${DEPLOY_DATABASE_NAME} | gzip > ${BACKUP_FILE}" \
  && echo -e "${GREEN}✅ 备份完成: ${BACKUP_FILE}${NC}" \
  || echo -e "${YELLOW}⚠️ 备份跳过（可能是首次部署或数据库尚未初始化）${NC}"

echo -e "${YELLOW}3) 确保迁移表存在...${NC}"
db_exists=$(remote_compose "exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -tAc \"SELECT 1 FROM pg_database WHERE datname='${DEPLOY_DATABASE_NAME}'\"" | tr -d '[:space:]')
if [[ "$db_exists" != "1" ]]; then
  echo -e "${YELLOW}  - 数据库 ${DEPLOY_DATABASE_NAME} 不存在，正在创建...${NC}"
  remote_compose "exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -c \"CREATE DATABASE ${DEPLOY_DATABASE_NAME};\""
fi

remote_compose "exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME} -c \"CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(32) PRIMARY KEY, applied_at TIMESTAMPTZ DEFAULT NOW());\""

core_users_exists=$(remote_compose "exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME} -tAc \"SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='users'\"" | tr -d '[:space:]')
if [[ "$core_users_exists" != "1" ]]; then
  echo -e "${YELLOW}  - 检测到基础表缺失，先执行 scripts/deploy-release/db/init.sql${NC}"
  ssh "$SERVER" "cd $REMOTE_DIR && cat scripts/deploy-release/db/init.sql | docker compose -p $STACK_NAME -f $COMPOSE_FILE --env-file scripts/deploy-release/runtime/.env exec -T postgres psql -h 127.0.0.1 -v ON_ERROR_STOP=1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME}"
fi

echo -e "${YELLOW}4) 执行增量迁移...${NC}"
for file in "$ROOT_DIR"/scripts/deploy-release/db/migrations/*.sql; do
  [ -e "$file" ] || continue
  filename="$(basename "$file")"
  version="${filename%%_*}"

  applied=$(ssh "$SERVER" "cd $REMOTE_DIR && docker compose -p $STACK_NAME -f $COMPOSE_FILE --env-file scripts/deploy-release/runtime/.env exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME} -tAc \"SELECT 1 FROM schema_migrations WHERE version='${version}'\"" | tr -d '[:space:]')

  if [[ "$applied" == "1" ]]; then
    echo -e "${GREEN}  - 跳过 ${filename}（已执行）${NC}"
    continue
  fi

  echo -e "${YELLOW}  - 执行 ${filename}${NC}"
  ssh "$SERVER" "cd $REMOTE_DIR && cat scripts/deploy-release/db/migrations/${filename} | docker compose -p $STACK_NAME -f $COMPOSE_FILE --env-file scripts/deploy-release/runtime/.env exec -T postgres psql -h 127.0.0.1 -v ON_ERROR_STOP=1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME}"
  remote_compose "exec -T postgres psql -h 127.0.0.1 -U ${DEPLOY_DATABASE_USER} -d ${DEPLOY_DATABASE_NAME} -c \"INSERT INTO schema_migrations(version) VALUES('${version}');\""
done

echo -e "${GREEN}✅ 数据库发布流程完成${NC}"
