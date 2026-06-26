#!/bin/bash
# 连接到数据库 psql 命令行

DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"
if ! command -v docker >/dev/null 2>&1 && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
    export PATH="$DOCKER_DESKTOP_BIN:$PATH"
fi

echo "🔌 连接到数据库..."
docker exec -it hikiki_postgres_local psql -U postgres -d hikiki_db
