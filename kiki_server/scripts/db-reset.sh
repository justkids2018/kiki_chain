#!/bin/bash
# 重置数据库（删除所有数据并重新初始化）

echo "⚠️  警告：此操作将删除所有数据！"
read -p "确认要重置数据库吗？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ 操作已取消"
    exit 0
fi

echo "🔄 重置数据库..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SERVER_DIR/.." && pwd)"
MIGRATE_SCRIPT="$PROJECT_ROOT/scripts/local_dev/migrate.sh"
DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"

if ! command -v docker >/dev/null 2>&1 && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
    export PATH="$DOCKER_DESKTOP_BIN:$PATH"
fi

cd "$SERVER_DIR" || exit

# 停止并删除容器和数据卷
docker compose -f docker-compose.local.yml down -v

# 重新启动
docker compose -f docker-compose.local.yml up -d

echo "⏳ 等待数据库初始化..."
sleep 8

if [ -x "$MIGRATE_SCRIPT" ]; then
    echo "🔄 自动执行本地数据库迁移..."
    "$MIGRATE_SCRIPT"
else
    echo "⚠️  未找到可执行迁移脚本: $MIGRATE_SCRIPT"
fi

echo "✅ 数据库重置完成！"
