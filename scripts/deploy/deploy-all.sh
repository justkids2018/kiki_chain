#!/bin/bash
# ============================================
# Hi Kiki - 一键全量部署
# 用途：同步代码 + 数据库迁移 + 后端 + 管理后台
# 用法：./scripts/deploy/deploy-all.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# -------- 颜色 --------
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Hi Kiki - 全量部署${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. 同步代码
bash "$SCRIPT_DIR/deploy-sync.sh"
echo ""

# 2. 数据库迁移
bash "$SCRIPT_DIR/deploy-db.sh" --no-sync 2>/dev/null || true
echo ""

# 3. 后端部署
bash "$SCRIPT_DIR/deploy-backend.sh" --no-sync
echo ""

# 4. 管理后台部署
bash "$SCRIPT_DIR/deploy-admin.sh" --no-sync
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  🎉 全量部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  主站:     https://mtrain.xyz"
echo "  管理后台: https://mtrain.xyz/admin"
echo "  API:      https://mtrain.xyz/api"
