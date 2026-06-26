#!/bin/bash

set -euo pipefail

# ============================================
# Hi Kiki 本地数据库迁移脚本
# ============================================
# 说明:
# - 使用与线上一致的数据库事实源: kiki_server/database
# - 基础表缺失时执行 init.sql
# - 通过 schema_migrations 记录已执行版本，避免重复执行
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INIT_SQL="$PROJECT_ROOT/kiki_server/database/init.sql"
MIGRATION_DIR="$PROJECT_ROOT/kiki_server/database/migrations"
CONTAINER="hikiki_postgres_local"
DB_USER="postgres"
DB_NAME="hikiki_db"
DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err() { echo -e "${RED}[ERR]${NC} $1"; }

if ! command -v docker >/dev/null 2>&1 && [[ -x "$DOCKER_DESKTOP_BIN/docker" ]]; then
  export PATH="$DOCKER_DESKTOP_BIN:$PATH"
fi

if ! command -v docker >/dev/null 2>&1; then
  log_err "docker 未安装"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  log_err "数据库容器未运行: ${CONTAINER}"
  log_err "请先执行: ./scripts/local_dev/start.sh 或 ./kiki_server/scripts/db-start.sh"
  exit 1
fi

if [[ ! -f "$INIT_SQL" ]]; then
  log_err "初始化脚本不存在: ${INIT_SQL}"
  exit 1
fi

if [[ ! -d "$MIGRATION_DIR" ]]; then
  log_err "迁移目录不存在: ${MIGRATION_DIR}"
  exit 1
fi

log_info "等待数据库就绪..."
for _ in {1..20}; do
  if docker exec -i "$CONTAINER" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! docker exec -i "$CONTAINER" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
  log_err "数据库未就绪，无法执行迁移"
  exit 1
fi

docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c \
  "CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(32) PRIMARY KEY, applied_at TIMESTAMPTZ DEFAULT NOW());" >/dev/null

core_users_exists="$(docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='users'" | tr -d '[:space:]')"
if [[ "$core_users_exists" != "1" ]]; then
  log_warn "检测到基础表缺失，执行 init.sql"
  docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 < "$INIT_SQL"
  log_ok "基础表初始化完成"
else
  log_ok "基础表已存在，跳过 init.sql"
fi

for file in "$MIGRATION_DIR"/*.sql; do
  [[ -e "$file" ]] || continue
  filename="$(basename "$file")"
  version="${filename%%_*}"

  applied="$(docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM schema_migrations WHERE version='${version}'" | tr -d '[:space:]')"
  if [[ "$applied" == "1" ]]; then
    log_ok "跳过 ${filename}（已执行）"
    continue
  fi

  log_info "执行 ${filename}"
  docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 < "$file"
  docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c \
    "INSERT INTO schema_migrations(version) VALUES('${version}');" >/dev/null
  log_ok "完成 ${filename}"
done

log_ok "本地数据库迁移完成"
