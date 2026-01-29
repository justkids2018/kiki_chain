#!/bin/bash
# 重置数据库（删除所有数据并重新初始化）

echo "⚠️  警告：此操作将删除所有数据！"
read -p "确认要重置数据库吗？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ 操作已取消"
    exit 0
fi

echo "🔄 重置数据库..."

cd "$(dirname "$0")/.." || exit

# 停止并删除容器和数据卷
docker-compose -f docker-compose.local.yml down -v

# 重新启动
docker-compose -f docker-compose.local.yml up -d

echo "⏳ 等待数据库初始化..."
sleep 8

echo "✅ 数据库重置完成！"
