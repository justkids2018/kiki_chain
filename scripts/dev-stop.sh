#!/bin/bash

# Hi Kiki 开发环境停止脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KIKI_SERVER_DIR="$SCRIPT_DIR/../kiki_server"

echo "🛑 停止 Hi Kiki 开发环境..."
echo ""

# 停止 kiki_server
if lsof -i :8081 > /dev/null 2>&1; then
    PID=$(lsof -ti :8081)
    kill $PID 2>/dev/null
    sleep 1
    if lsof -i :8081 > /dev/null 2>&1; then
        echo "⚠️  kiki_server 未响应，强制终止..."
        kill -9 $PID 2>/dev/null
    fi
    echo "✅ kiki_server 已停止"
else
    echo "ℹ️  kiki_server 未运行"
fi

# 停止 PostgreSQL（保持容器，只停止）
cd "$KIKI_SERVER_DIR"
if docker ps --format '{{.Names}}' | grep -q hikiki_postgres_local; then
    docker compose -f docker-compose.local.yml stop postgres > /dev/null 2>&1
    echo "✅ PostgreSQL 已停止（容器保留，数据不丢失）"
else
    echo "ℹ️  PostgreSQL 未运行"
fi

echo ""
echo "✨ 完成"
