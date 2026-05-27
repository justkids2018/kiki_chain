#!/bin/bash

set -euo pipefail

# ============================================
# Hi Kiki 本地数据库迁移脚本
# ============================================
# 说明:
# - 使用与线上一致的迁移目录: scripts/deploy-release/db/migrations
# - 通过 schema_migrations 记录已执行版本，避免重复执行
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MIGRATION_DIR="$PROJECT_ROOT/scripts/deploy-release/db/migrations"
CONTAINER="hikiki_postgres_local"
DB_USER="postgres"
DB_NAME="hikiki_db"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err() { echo -e "${RED}[ERR]${NC} $1"; }

if ! command -v docker >/dev/null 2>&1; then
  log_err "docker 未安装"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  log_err "数据库容器未运行: ${CONTAINER}"
  exit 1
fi

log_info "等待数据库就绪..."
for _ in {1..20}; do
  if docker exec -i "$CONTAINER" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

docker exec -i "$CONTAINER" psql -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c \
  "CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(32) PRIMARY KEY, applied_at TIMESTAMPTZ DEFAULT NOW());" >/dev/null

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
