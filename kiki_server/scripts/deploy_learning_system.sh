#!/bin/bash

# 星星奖励系统 - 数据库迁移脚本
# 使用方法: ./deploy_learning_system.sh

set -e

echo "🚀 开始部署星星奖励系统..."

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 读取.env文件
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✓${NC} 加载环境变量"
else
    echo -e "${RED}✗${NC} 未找到.env文件"
    exit 1
fi

# 数据库连接信息
DB_HOST=${DATABASE_HOST:-localhost}
DB_PORT=${DATABASE_PORT:-5432}
DB_NAME=${DATABASE_NAME:-qiqimanyou}
DB_USER=${DATABASE_USER:-postgres}

echo "📊 数据库信息:"
echo "  主机: $DB_HOST:$DB_PORT"
echo "  数据库: $DB_NAME"
echo "  用户: $DB_USER"
echo ""

# 确认执行
read -p "是否继续执行数据库迁移? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消部署"
    exit 1
fi

# 执行迁移
echo ""
echo "🔧 执行数据库迁移..."
PGPASSWORD=$DATABASE_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f migrations/001_create_learning_tables.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 数据库迁移成功"
else
    echo -e "${RED}✗${NC} 数据库迁移失败"
    exit 1
fi

# 验证表是否创建
echo ""
echo "🔍 验证表结构..."
PGPASSWORD=$DATABASE_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt user_scene_progress" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} user_scene_progress 表已创建"
else
    echo -e "${RED}✗${NC} user_scene_progress 表创建失败"
fi

PGPASSWORD=$DATABASE_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt learning_detail_logs" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} learning_detail_logs 表已创建"
else
    echo -e "${RED}✗${NC} learning_detail_logs 表创建失败"
fi

PGPASSWORD=$DATABASE_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt user_score_summary" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} user_score_summary 表已创建"
else
    echo -e "${RED}✗${NC} user_score_summary 表创建失败"
fi

echo ""
echo -e "${GREEN}✅ 部署完成！${NC}"
echo ""
echo "📝 下一步:"
echo "  1. 启动后端服务器: cd kiki_server && cargo run"
echo "  2. 启动前端应用: cd kiki_web && flutter run"
echo "  3. 测试API: ./scripts/test_learning_api.sh"
