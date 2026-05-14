#!/bin/bash
# ============================================
# Hi Kiki - 数据库管理（腾讯云）
# 用途：执行数据库迁移、备份、恢复
# 用法：
#   ./scripts/deploy-tencent/deploy-db.sh                    # 执行所有迁移
#   ./scripts/deploy-tencent/deploy-db.sh --file xxx.sql     # 执行指定迁移文件
#   ./scripts/deploy-tencent/deploy-db.sh --sql "SQL语句"    # 直接执行 SQL
#   ./scripts/deploy-tencent/deploy-db.sh --backup           # 仅备份数据库
#   ./scripts/deploy-tencent/deploy-db.sh --restore latest   # 恢复最新备份
#   ./scripts/deploy-tencent/deploy-db.sh --status           # 查看数据库状态
# ============================================

set -e

# -------- 配置 --------
SERVER="ubuntu@82.156.34.186"
REMOTE_DIR="~/kiki_chain"
LOCAL_MIGRATIONS="$(cd "$(dirname "$0")/../.." && pwd)/kiki_server/migrations"
DB_CONTAINER="hikiki_postgres"
DB_NAME="hikiki_db"
DB_USER="postgres"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    echo "用法: ./deploy-db.sh [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)              执行所有本地迁移文件"
    echo "  --file <file.sql>    执行指定的 SQL 迁移文件"
    echo "  --sql \"<SQL>\"        直接执行 SQL 语句"
    echo "  --backup             仅备份数据库"
    echo "  --restore latest     恢复最新备份"
    echo "  --status             显示数据库状态"
    echo "  --help               显示此帮助"
}

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 数据库管理（腾讯云）${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# -------- 参数解析 --------
ACTION="migrate"
SQL_FILE=""
SQL_CMD=""

case "${1:-}" in
    --file)
        ACTION="file"
        SQL_FILE="$2"
        if [ -z "$SQL_FILE" ]; then
            echo -e "${RED}❌ 请指定 SQL 文件路径${NC}"
            exit 1
        fi
        ;;
    --sql)
        ACTION="sql"
        SQL_CMD="$2"
        if [ -z "$SQL_CMD" ]; then
            echo -e "${RED}❌ 请输入 SQL 语句${NC}"
            exit 1
        fi
        ;;
    --backup)
        ACTION="backup"
        ;;
    --restore)
        ACTION="restore"
        ;;
    --status)
        ACTION="status"
        ;;
    --help)
        show_help
        exit 0
        ;;
esac

# -------- 备份 --------
do_backup() {
    echo -e "${YELLOW}备份数据库...${NC}"
    ssh $SERVER "$REMOTE_DIR/scripts/backup.sh"
    echo -e "${GREEN}  ✅ 备份完成${NC}"
}

# -------- 执行 --------
case $ACTION in
    backup)
        do_backup
        echo ""
        echo "备份文件位于服务器: ~/kiki_chain/backups/"
        ssh $SERVER "ls -lh $REMOTE_DIR/backups/*.gz 2>/dev/null | tail -5"
        ;;

    status)
        echo -e "${YELLOW}数据库状态...${NC}"
        ssh $SERVER "docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\dt'" 2>/dev/null || echo "数据库未就绪"
        ;;

    sql)
        echo -e "${YELLOW}执行 SQL: $SQL_CMD${NC}"
        do_backup
        ssh $SERVER "docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"$SQL_CMD\""
        echo -e "${GREEN}  ✅ SQL 执行完成${NC}"
        ;;

    file)
        echo -e "${YELLOW}执行迁移文件: $SQL_FILE${NC}"
        if [ ! -f "$SQL_FILE" ]; then
            echo -e "${RED}❌ 文件不存在: $SQL_FILE${NC}"
            exit 1
        fi
        do_backup
        FNAME=$(basename "$SQL_FILE")
        scp "$SQL_FILE" "$SERVER:/tmp/$FNAME"
        ssh $SERVER "docker cp /tmp/$FNAME $DB_CONTAINER:/tmp/ && \
            docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -f /tmp/$FNAME && \
            rm /tmp/$FNAME"
        echo -e "${GREEN}  ✅ $FNAME 执行完成${NC}"
        ;;

    migrate)
        FILES=$(ls "$LOCAL_MIGRATIONS"/*.sql 2>/dev/null | sort)
        if [ -z "$FILES" ]; then
            echo -e "${YELLOW}  没有找到迁移文件${NC}"
            exit 0
        fi

        do_backup
        echo ""

        for f in $FILES; do
            FILENAME=$(basename "$f")
            echo -e "${YELLOW}  执行: $FILENAME${NC}"
            scp "$f" "$SERVER:/tmp/$FILENAME"
            ssh $SERVER "docker cp /tmp/$FILENAME $DB_CONTAINER:/tmp/ && \
                docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -f /tmp/$FILENAME && \
                rm /tmp/$FILENAME" 2>&1
            echo -e "${GREEN}    ✅ $FILENAME 完成${NC}"
        done

        echo ""
        echo -e "${GREEN}  ✅ 所有迁移执行完成${NC}"
        ;;

    restore)
        echo -e "${RED}⚠️  即将恢复数据库，当前数据将被覆盖！${NC}"
        read -p "确认恢复？(y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "已取消"
            exit 0
        fi
        LATEST=$(ssh $SERVER "ls -t $REMOTE_DIR/backups/*.gz 2>/dev/null | head -1")
        if [ -z "$LATEST" ]; then
            echo -e "${RED}❌ 没有找到备份文件${NC}"
            exit 1
        fi
        echo "恢复备份: $LATEST"
        ssh $SERVER "gunzip -c $LATEST | docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME"
        echo -e "${GREEN}  ✅ 数据库已恢复${NC}"
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 数据库操作完成！${NC}"
echo -e "${GREEN}========================================${NC}"
