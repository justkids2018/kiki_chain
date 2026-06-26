#!/bin/bash
# 停止本地数据库

echo "🛑 停止 Hi Kiki 本地数据库..."

DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"
if ! command -v docker >/dev/null 2>&1 && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
    export PATH="$DOCKER_DESKTOP_BIN:$PATH"
fi

cd "$(dirname "$0")/.." || exit
docker compose -f docker-compose.local.yml down

echo "✅ 数据库已停止"
