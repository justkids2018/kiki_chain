#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATION_DIR="$ROOT_DIR/kiki_server/database/migrations"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

err() { echo -e "${RED}[ERR]${NC} $1" >&2; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

if [[ ! -d "$MIGRATION_DIR" ]]; then
  err "迁移目录不存在: kiki_server/database/migrations"
  exit 1
fi

bad=0

versions_file="$(mktemp)"
trap 'rm -f "$versions_file"' EXIT

for file in "$MIGRATION_DIR"/*.sql; do
  [[ -e "$file" ]] || continue
  filename="$(basename "$file")"

  if [[ ! "$filename" =~ ^[0-9]{3}_[a-z0-9_]+\.sql$ ]]; then
    err "迁移文件命名不符合 NNN_short_description.sql: $filename"
    bad=1
    continue
  fi

  version="${filename%%_*}"
  existing="$(awk -v version="$version" '$1 == version { print $2; exit }' "$versions_file")"
  if [[ -n "$existing" ]]; then
    err "迁移版本号重复: $version (${existing}, $filename)"
    bad=1
  else
    printf '%s %s\n' "$version" "$filename" >> "$versions_file"
  fi

  if grep -Eiq 'AUTO_INCREMENT|TINYINT\(1\)|ON DUPLICATE KEY UPDATE|ENGINE=InnoDB|CHARSET=|COLLATE=' "$file"; then
    err "发现 MySQL 方言，请改为 PostgreSQL 写法: $filename"
    bad=1
  fi
done

changed_files=""
if [[ "${GITHUB_ACTIONS:-false}" != "true" ]]; then
  changed_files="$(git -C "$ROOT_DIR" diff --name-only)"
elif [[ -n "${GITHUB_BASE_REF:-}" ]]; then
  git -C "$ROOT_DIR" fetch --no-tags --depth=100 origin "$GITHUB_BASE_REF" >/dev/null 2>&1 || true
  if git -C "$ROOT_DIR" rev-parse --verify "origin/$GITHUB_BASE_REF" >/dev/null 2>&1; then
    changed_files="$(git -C "$ROOT_DIR" diff --name-only "origin/$GITHUB_BASE_REF"...HEAD)"
  fi
fi

if [[ -z "$changed_files" && "${GITHUB_ACTIONS:-false}" == "true" ]] && git -C "$ROOT_DIR" rev-parse --verify HEAD~1 >/dev/null 2>&1; then
  changed_files="$(git -C "$ROOT_DIR" diff --name-only HEAD~1...HEAD)"
fi

if [[ -z "$changed_files" && "${GITHUB_ACTIONS:-false}" != "true" ]]; then
  changed_files="$(git -C "$ROOT_DIR" diff --name-only)"
fi

legacy_sql_changes="$(printf '%s\n' "$changed_files" | grep -E '^(docs/database/|kiki_server/migrations/|scripts/deploy-release/db/).+\.sql$' || true)"
if [[ -n "$legacy_sql_changes" && "${ALLOW_LEGACY_DB_SQL_CHANGES:-false}" != "true" ]]; then
  err "检测到旧数据库 SQL 路径变更。请改到 kiki_server/database/。"
  echo "$legacy_sql_changes" >&2
  bad=1
elif [[ -n "$legacy_sql_changes" ]]; then
  warn "允许旧数据库 SQL 路径变更（ALLOW_LEGACY_DB_SQL_CHANGES=true）"
fi

if (( bad != 0 )); then
  exit 1
fi

ok "数据库迁移检查通过"
