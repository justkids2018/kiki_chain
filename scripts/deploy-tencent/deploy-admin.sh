#!/bin/bash
# ============================================
# Hi Kiki - 管理后台部署（腾讯云）
# 用途：重新构建并部署 Vue 管理后台
# 用法：./scripts/deploy-tencent/deploy-admin.sh [--no-sync]
#   --no-sync  跳过代码同步
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
echo -e "${CYAN}  Hi Kiki - 管理后台部署（腾讯云）${NC}"
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

# 2. 重新构建管理后台
echo -e "${YELLOW}[2/4] 构建管理后台镜像...${NC}"
ssh $SERVER "cd $REMOTE_DIR && docker compose -f $COMPOSE_FILE build admin --no-cache" 2>&1
echo -e "${GREEN}  ✅ 管理后台构建完成${NC}"

# 3. 重启服务
echo -e "${YELLOW}[3/4] 重启管理后台和 Nginx...${NC}"
ssh $SERVER "cd $REMOTE_DIR && \
    docker compose -f $COMPOSE_FILE stop admin 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE rm -f admin 2>/dev/null || true && \
    docker compose -f $COMPOSE_FILE up -d admin && \
    docker compose -f $COMPOSE_FILE restart nginx"
echo -e "${GREEN}  ✅ 服务已重启${NC}"

# 4. 验证
echo -e "${YELLOW}[4/4] 验证...${NC}"
sleep 5
ADMIN_STATUS=$(ssh $SERVER "docker inspect -f '{{.State.Running}}' hikiki_admin 2>/dev/null" || echo "false")
if [ "$ADMIN_STATUS" = "true" ]; then
    echo -e "${GREEN}  ✅ 管理后台容器运行正常${NC}"
else
    echo -e "${RED}  ❌ 管理后台未正常运行${NC}"
    ssh $SERVER "docker logs hikiki_admin --tail 20"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 管理后台部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo "  管理后台: https://kiki.keepthinking.me/admin"
