#!/bin/bash
# 查看数据库日志

cd "$(dirname "$0")/.." || exit
docker-compose -f docker-compose.local.yml logs -f postgres
