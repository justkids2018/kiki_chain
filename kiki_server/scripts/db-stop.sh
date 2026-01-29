#!/bin/bash
# 停止本地数据库

echo "🛑 停止 Hi Kiki 本地数据库..."

cd "$(dirname "$0")/.." || exit
docker-compose -f docker-compose.local.yml down

echo "✅ 数据库已停止"
