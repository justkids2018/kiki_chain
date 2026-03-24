#!/bin/bash
# ============================================
# Hi Kiki - 数据库自动备份
# 用途：备份 hikiki_db，保留最近 7 天
# 用法：./scripts/backup.sh
# ============================================

DB_CONTAINER="hikiki_postgres"
DB_NAME="hikiki_db"
DB_USER="postgres"
BACKUP_DIR="/root/kiki_chain/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

# 只保留最近 7 天的备份
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "✅ 备份完成: $BACKUP_FILE"
