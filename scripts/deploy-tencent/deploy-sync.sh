#!/bin/bash
# ============================================
# Hi Kiki - 代码同步到腾讯云服务器
# 用途：将本地代码同步到腾讯云生产服务器
# 用法：./scripts/deploy-tencent/deploy-sync.sh
# ============================================

set -e

# -------- 配置 --------
SERVER="ubuntu@82.156.34.186"
REMOTE_DIR="~/kiki_chain"
LOCAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 代码同步（腾讯云）${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 检查 SSH 连接
echo -e "${YELLOW}[1/3] 检查服务器连接...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER "echo ok" > /dev/null 2>&1; then
    echo -e "${RED}❌ 无法连接服务器 $SERVER${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ 服务器连接正常${NC}"

# 确保远端目录存在
ssh $SERVER "mkdir -p ~/kiki_chain"

# 同步代码（不删除服务器上的 certbot/backups 目录）
echo -e "${YELLOW}[2/3] 同步代码到服务器...${NC}"
rsync -avz \
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

# 验证
echo -e "${YELLOW}[3/3] 验证同步...${NC}"
ssh $SERVER "ls -la ~/kiki_chain/ | head -15"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 代码同步完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "后续操作："
echo "  首次部署：  ./scripts/deploy-tencent/setup-server.sh"
echo "  更新后端：  ./scripts/deploy-tencent/deploy-backend.sh"
echo "  更新管理台：./scripts/deploy-tencent/deploy-admin.sh"
echo "  数据库管理：./scripts/deploy-tencent/deploy-db.sh"
