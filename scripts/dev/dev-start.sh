#!/bin/bash
# ============================================
# Hi Kiki - 本地开发环境启动
# 用途：一键启动本地 DB + 后端 + Admin
# 用法：./scripts/dev/dev-start.sh
# ============================================

set -e

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
echo -e "${CYAN}  Hi Kiki - 本地开发环境${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# -------- 检查是否已经在运行 --------
if [ -f "$PID_FILE" ]; then
    echo -e "${YELLOW}⚠️  检测到已有进程在运行，请先执行 dev-stop.sh${NC}"
    echo "   或删除 $PID_FILE 后重试"
    exit 1
fi

# -------- 1. 检查 Docker --------
echo -e "${YELLOW}[1/4] 检查 Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}  ❌ Docker 未运行，请先启动 Docker Desktop${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ Docker 已运行${NC}"
echo ""

# -------- 2. 启动 PostgreSQL（仅 DB，不启动 App 容器）--------
echo -e "${YELLOW}[2/4] 启动本地数据库 (PostgreSQL)...${NC}"
cd "$ROOT_DIR/kiki_server"
docker compose -f docker-compose.local.yml up -d postgres

# 等待 DB 健康检查通过
echo "  ⏳ 等待数据库就绪..."
for i in $(seq 1 20); do
    if docker exec hikiki_postgres_local pg_isready -U postgres -q 2>/dev/null; then
        break
    fi
    sleep 2
done

if ! docker exec hikiki_postgres_local pg_isready -U postgres -q 2>/dev/null; then
    echo -e "${RED}  ❌ 数据库启动超时${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ 数据库已就绪 (localhost:5432)${NC}"
echo ""

# -------- 3. 启动 Rust 后端 --------
echo -e "${YELLOW}[3/4] 启动 Rust 后端...${NC}"
LOG_BACKEND="/tmp/kiki_server.log"
cd "$ROOT_DIR/kiki_server"
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/hikiki_db" \
ENVIRONMENT=development \
cargo run > "$LOG_BACKEND" 2>&1 &
BACKEND_PID=$!
echo "  ⏳ 等待后端启动 (日志: $LOG_BACKEND)..."

# 最多等 30 秒
for i in $(seq 1 15); do
    sleep 2
    if curl -s http://localhost:8081/health > /dev/null 2>&1; then
        break
    fi
    # 检查进程是否意外退出
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${RED}  ❌ 后端进程异常退出，查看日志：${NC}"
        tail -20 "$LOG_BACKEND"
        exit 1
    fi
done

if ! curl -s http://localhost:8081/health > /dev/null 2>&1; then
    echo -e "${YELLOW}  ⚠️  后端可能还在编译中，可查看日志：$LOG_BACKEND${NC}"
else
    echo -e "${GREEN}  ✅ 后端已就绪 (http://localhost:8081)${NC}"
fi
echo ""

# -------- 4. 启动 Admin 前端 --------
echo -e "${YELLOW}[4/4] 启动 Admin 前端...${NC}"
LOG_ADMIN="/tmp/kiki_admin.log"
cd "$ROOT_DIR/kiki_admin"
npm run dev > "$LOG_ADMIN" 2>&1 &
ADMIN_PID=$!

# 等待 Vite 输出端口信息
sleep 3
ADMIN_PORT=$(grep -oP 'localhost:\K[0-9]+' "$LOG_ADMIN" 2>/dev/null | head -1 || echo "5173")
echo -e "${GREEN}  ✅ Admin 已就绪 (http://localhost:$ADMIN_PORT)${NC}"
echo ""

# -------- 保存 PID --------
echo "BACKEND_PID=$BACKEND_PID" > "$PID_FILE"
echo "ADMIN_PID=$ADMIN_PID" >> "$PID_FILE"

# -------- 汇总 --------
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  🚀 本地开发环境已启动！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  后端 API:   http://localhost:8081"
echo "  Admin:      http://localhost:$ADMIN_PORT"
echo "  DB:         postgresql://postgres:postgres@localhost:5432/hikiki_db"
echo ""
echo "  后端日志:   tail -f $LOG_BACKEND"
echo "  Admin 日志: tail -f $LOG_ADMIN"
echo ""
echo -e "  停止服务:   ${CYAN}bash scripts/dev/dev-stop.sh${NC}"
echo ""
