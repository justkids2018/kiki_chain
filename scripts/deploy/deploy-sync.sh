#!/bin/bash
# ============================================
# Hi Kiki - 代码同步到服务器
# 用途：将本地代码同步到生产服务器
# 用法：./scripts/deploy/deploy-sync.sh
# ============================================

set -e

# -------- 配置 --------
SERVER="root@39.102.74.171"
REMOTE_DIR="/root/kiki_chain"
LOCAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# -------- 颜色 --------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 代码同步${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 检查 SSH 连接
echo -e "${YELLOW}[1/3] 检查服务器连接...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER "echo ok" > /dev/null 2>&1; then
    echo "❌ 无法连接服务器 $SERVER"
    exit 1
fi
echo -e "${GREEN}  ✅ 服务器连接正常${NC}"

# 同��代码
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

# 显示同步结果
echo -e "${YELLOW}[3/3] 验证同步...${NC}"
ssh $SERVER "ls -la $REMOTE_DIR/ | head -15"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 代码同步完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "后续操作："
echo "  更新后端：  ./scripts/deploy/deploy-backend.sh"
echo "  更新管理台：./scripts/deploy/deploy-admin.sh"
echo "  更新数据库：./scripts/deploy/deploy-db.sh"
