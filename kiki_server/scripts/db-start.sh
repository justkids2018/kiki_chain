#!/bin/bash
# 启动本地数据库

echo "🚀 启动 Hi Kiki 本地数据库..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SERVER_DIR/.." && pwd)"
MIGRATE_SCRIPT="$PROJECT_ROOT/scripts/local_dev/migrate.sh"
DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"

if ! command -v docker >/dev/null 2>&1 && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
    export PATH="$DOCKER_DESKTOP_BIN:$PATH"
fi

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 启动数据库
cd "$SERVER_DIR" || exit
docker compose -f docker-compose.local.yml up -d

# 等待数据库就绪
echo "⏳ 等待数据库启动..."
sleep 5

# 检查数据库状态
if docker ps | grep -q hikiki_postgres_local; then
    echo "✅ 数据库启动成功！"
    if [ -x "$MIGRATE_SCRIPT" ]; then
        echo "🔄 自动补齐本地数据库结构..."
        "$MIGRATE_SCRIPT"
    else
        echo "⚠️  未找到可执行迁移脚本: $MIGRATE_SCRIPT"
    fi
    echo ""
    echo "📊 数据库连接信息："
    echo "   Host: localhost"
    echo "   Port: 5432"
    echo "   Database: hikiki_db"
    echo "   User: postgres"
    echo "   Password: postgres"
    echo ""
    echo "🔗 连接字符串："
    echo "   postgresql://postgres:postgres@localhost:5432/hikiki_db"
else
    echo "❌ 数据库启动失败"
    exit 1
fi
