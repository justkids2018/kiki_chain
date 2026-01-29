#!/bin/bash
# 连接到数据库 psql 命令行

echo "🔌 连接到数据库..."
docker exec -it hikiki_postgres_local psql -U postgres -d hikiki_db
