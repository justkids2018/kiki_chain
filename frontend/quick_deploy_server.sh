#!/bin/bash

# QiQiManyou 腾讯云服务器快速部署脚本
# 在上传文件到服务器后执行此脚本

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\033[0;34m🚀 QiQiManyou 腾讯云快速部署\033[0m"
echo "========================================"

# 检查必要文件
echo -e "\033[0;34m📋 检查部署文件...\033[0m"
required_files=("qiqimanyou-flutter-web-amd64.tar.gz" "docker-compose.yml" "nginx.conf")
for file in "frontend/Dockerfile frontend/nginx.conf pubspec.yaml lib/main.dart"; do
    if [[ ! -f "build/web/flutter.js" ]]; then
        echo -e "\033[0;31m❌ 缺少文件: build/web/flutter.js\033[0m"
        exit 1
    fi
    echo -e "\033[0;32m✓ 找到文件: build/web/flutter.js\033[0m"
done

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "\033[1;33m⚠️  Docker 未安装，正在安装...\033[0m"
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
fi

# 停止现有容器
echo -e "\033[0;34m🛑 停止现有容器...\033[0m"
docker compose down 2>/dev/null || true


# 导入镜像
echo -e "\033[0;34m📦 导入 Docker 镜像...\033[0m"
docker load < qiqimanyou-flutter-web-amd64-20251020_002622.tar.gz

# 验证镜像
echo -e "\033[0;34m� 验证镜像...\033[0m"
docker inspect qiqimanyou-flutter-web:latest | grep -A 2 "Architecture"

# 启动服务（需在docker-compose.yml中指定对应tag）
echo -e "\033[0;34m🚀 启动服务...\033[0m"
docker compose up -d

# 健康检查
echo -e "\033[0;34m🧪 健康检查...\033[0m"
sleep 10
if curl -f http://localhost > /dev/null 2>&1; then
    echo -e "\033[0;32m✅ 部署成功！应用已启动\033[0m"
    echo -e "\033[0;32m🌐 访问地址: http://keepthinking.me\033[0m"
else
    echo -e "\033[0;31m❌ 健康检查失败\033[0m"
    docker compose logs
fi

echo "========================================"
echo -e "\033[0;32m🎉 部署完成！\033[0m"
