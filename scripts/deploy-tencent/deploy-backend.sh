#!/bin/bash
# ============================================
# Hi Kiki - 后端部署（腾讯云）
# 用途：重新构建并部署 Rust 后端服务
# 用法：./scripts/deploy-tencent/deploy-backend.sh [--no-sync]
#   --no-sync  跳过代码同步（已手动同步过）
# ============================================

set -e

# -------- 配置 --------
SERVER="ubuntu@82.156.34.186"
REMOTE_DIR="~/kiki_chain"
COMPOSE_FILE="docker-compose.prod.yml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# -------- 参数解析 --------
SKIP_SYNC=false
for arg in "$@"; do
    case $arg in
        --no-sync) SKIP_SYNC=true ;;
    esac
done

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 后端部署（腾讯云）${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. 同步代码
if [ "$SKIP_SYNC" = false ]; then
    echo -e "${YELLOW}[1/4] 同步代码...${NC}"
    bash "$SCRIPT_DIR/deploy-sync.sh"
    echo ""
else
    echo -e "${YELLOW}[1/4] 跳过代码同步 (--no-sync)${NC}"
fi

# 2. 重新构建后端
echo -e "${YELLOW}[2/4] 构建后端镜像（Rust 编译，约 5-10 分钟）...${NC}"
ssh $SERVER "cd $REMOTE_DIR && docker compose -f $COMPOSE_FILE build backend --no-cache" 2>&1
echo -e "${GREEN}  ✅ 后端构建完成${NC}"

# 3. 重启服务
echo -e "${YELLOW}[3/4] 重启后端服务...${NC}"
ssh $SERVER "cd $REMOTE_DIR && \
    docker compose -f $COMPOSE_FILE stop backend 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE rm -f backend 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE up -d backend"
echo -e "${GREEN}  ✅ 后端已重启${NC}"

# 4. 验证
echo -e "${YELLOW}[4/4] 等待服务启动并验证...${NC}"
sleep 10

BACKEND_STATUS=$(ssh $SERVER "docker inspect -f '{{.State.Running}}' hikiki_backend 2>/dev/null" || echo "false")
if [ "$BACKEND_STATUS" = "true" ]; then
    echo -e "${GREEN}  ✅ 后端容器运行正常${NC}"
else
    echo -e "${RED}  ❌ 后端容器未正常运行${NC}"
    echo "查看日志："
    ssh $SERVER "docker logs hikiki_backend --tail 20"
    exit 1
fi

API_TEST=$(ssh $SERVER "docker exec hikiki_nginx curl -s -o /dev/null -w '%{http_code}' http://backend:8001/health 2>/dev/null || echo '000'")
if [ "$API_TEST" = "200" ]; then
    echo -e "${GREEN}  ✅ API 响应正常 (HTTP $API_TEST)${NC}"
else
    echo -e "${YELLOW}  ⚠️  API 响应: HTTP $API_TEST（可能还在启动中）${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 后端部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo "  后端地址: https://kiki.keepthinking.me/api"
