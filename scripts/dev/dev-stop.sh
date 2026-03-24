#!/bin/bash
# ============================================
# Hi Kiki - 本地开发环境停止
# 用途：停止本地 DB + 后端 + Admin
# 用法：./scripts/dev/dev-stop.sh
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PID_FILE="$SCRIPT_DIR/.dev-pids"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 停止本地开发环境${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# -------- 停止后端 & Admin 进程 --------
if [ -f "$PID_FILE" ]; then
    source "$PID_FILE"

    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo -e "${YELLOW}  停止后端 (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null && echo -e "${GREEN}  ✅ 后端已停止${NC}"
    else
        echo "  后端进程不存在或已停止"
    fi

    if [ -n "$ADMIN_PID" ] && kill -0 "$ADMIN_PID" 2>/dev/null; then
        echo -e "${YELLOW}  停止 Admin (PID: $ADMIN_PID)...${NC}"
        kill "$ADMIN_PID" 2>/dev/null && echo -e "${GREEN}  ✅ Admin 已停止${NC}"
    else
        echo "  Admin 进程不存在或已停止"
    fi

    rm -f "$PID_FILE"
else
    echo "  未找到 PID 文件，尝试兜底清理..."
    # 兜底：端口占用就 kill
    lsof -ti :8081 | xargs kill -9 2>/dev/null && echo "  已清理端口 8081" || true
    lsof -ti :5173 | xargs kill -9 2>/dev/null && echo "  已清理端口 5173" || true
    lsof -ti :5176 | xargs kill -9 2>/dev/null && echo "  已清理端口 5176" || true
fi

echo ""

# -------- 停止 PostgreSQL 容器 --------
echo -e "${YELLOW}  停止数据库容器...${NC}"
cd "$ROOT_DIR/kiki_server"
if docker ps | grep -q hikiki_postgres_local; then
    docker compose -f docker-compose.local.yml stop postgres
    echo -e "${GREEN}  ✅ 数据库已停止${NC}"
else
    echo "  数据库容器未运行"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 本地开发环境已全部停止${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
