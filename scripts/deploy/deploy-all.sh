#!/bin/bash
# ============================================
# Hi Kiki - 一键全量部署
# 规则：
#   1. 同步代码（不删除远程文件，保留 certbot/backups）
#   2. 检测数据库是否存在：
#      - 不存在 → 创建 DB + 运行迁移
#      - 已存在 → 跳过，不动数据库
#   3. 重新构建并重启后端 Docker
#   4. 重新构建并重启前端 Docker
# ============================================

set -e

SERVER="root@39.102.74.171"
REMOTE_DIR="/root/kiki_chain"
COMPOSE_FILE="docker-compose.prod.yml"
LOCAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LOCAL_MIGRATIONS="$LOCAL_DIR/kiki_server/migrations"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================"
echo -e "  Hi Kiki - 全量部署"
echo -e "========================================${NC}"
echo ""

# ── 1. 同步代码 ──────────────────────────────────────────
echo -e "${YELLOW}[1/4] 同步代码...${NC}"
rsync -az \
    --exclude 'target/' \
    --exclude 'node_modules/' \
    --exclude '.git/' \
    --exclude 'kiki_web/' \
    --exclude '.DS_Store' \
    --exclude '*.swp' \
    --exclude 'kiki_server/target/' \
    --exclude 'kiki_admin/node_modules/' \
    --exclude 'kiki_admin/dist/' \
    --exclude 'certbot/' \
    --exclude 'backups/' \
    "$LOCAL_DIR/" "$SERVER:$REMOTE_DIR/"
echo -e "${GREEN}  ✅ 代码同步完成${NC}"
echo ""

# ── 2. 检测数据库 ─────────────────────────────────────────
echo -e "${YELLOW}[2/4] 检测数据库...${NC}"
DB_EXISTS=$(ssh $SERVER "docker exec hikiki_postgres psql -U postgres -tAc \"SELECT 1 FROM pg_database WHERE datname='hikiki_db'\" 2>/dev/null || echo '0'")

if [ "$DB_EXISTS" = "1" ]; then
    echo -e "${GREEN}  ✅ 数据库 hikiki_db 已存在，跳过初始化${NC}"
else
    echo -e "${YELLOW}  ⚠️  数据库不存在，正在创建...${NC}"

    # 创建数据库
    ssh $SERVER "docker exec hikiki_postgres psql -U postgres -c 'CREATE DATABASE hikiki_db;'"

    # 运行 init.sql
    ssh $SERVER "docker exec hikiki_postgres psql -U postgres -d hikiki_db \
        -f /docker-entrypoint-initdb.d/01_init.sql \
        -f /docker-entrypoint-initdb.d/02_scene_tables.sql"

    # 运行所有迁移文件
    for f in $(ls "$LOCAL_MIGRATIONS"/*.sql 2>/dev/null | sort); do
        FNAME=$(basename "$f")
        echo -e "${YELLOW}    迁移: $FNAME${NC}"
        scp "$f" "$SERVER:/tmp/$FNAME" 2>/dev/null
        ssh $SERVER "docker cp /tmp/$FNAME hikiki_postgres:/tmp/ && \
            docker exec hikiki_postgres psql -U postgres -d hikiki_db -f /tmp/$FNAME && \
            rm /tmp/$FNAME"
        echo -e "${GREEN}    ✅ $FNAME 完成${NC}"
    done

    echo -e "${GREEN}  ✅ 数据库初始化完成${NC}"
fi
echo ""

# ── 3. 重建后端 ───────────────────────────────────────────
echo -e "${YELLOW}[3/4] 重建后端（Rust 编译中...）${NC}"
ssh $SERVER "chmod +x $REMOTE_DIR/scripts/backup.sh 2>/dev/null || true && \
    $REMOTE_DIR/scripts/backup.sh"
ssh $SERVER "cd $REMOTE_DIR && \
    docker compose -f $COMPOSE_FILE build backend --no-cache && \
    docker compose -f $COMPOSE_FILE stop backend 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE rm -f backend 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE up -d backend"
echo -e "${GREEN}  ✅ 后端已更新${NC}"
echo ""

# ── 4. 重建前端 ───────────────────────────────────────────
echo -e "${YELLOW}[4/4] 重建管理后台...${NC}"
ssh $SERVER "cd $REMOTE_DIR && \
    docker compose -f $COMPOSE_FILE build admin --no-cache && \
    docker compose -f $COMPOSE_FILE stop admin 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE rm -f admin 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE up -d admin nginx"
echo -e "${GREEN}  ✅ 管理后台已更新${NC}"
echo ""

# ── 验证 ──────────────────────────────────────────────────
echo -e "${YELLOW}验证服务...${NC}"
sleep 8
API=$(ssh $SERVER "curl -s -o /dev/null -w '%{http_code}' https://mtrain.xyz/api/v1/mobile/scene/categories 2>/dev/null || echo '000'")
if [ "$API" = "200" ]; then
    echo -e "${GREEN}  ✅ API 正常 (HTTP $API)${NC}"
else
    echo -e "${RED}  ⚠️  API 响应: HTTP $API（可能还在启动）${NC}"
fi

echo ""
echo -e "${GREEN}========================================"
echo -e "  ✅ 部署完成"
echo -e "========================================${NC}"
echo "  主站:     https://mtrain.xyz"
echo "  管理后台: https://mtrain.xyz/admin"
echo "  API:      https://mtrain.xyz/api"
