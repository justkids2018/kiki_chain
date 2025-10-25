#!/bin/bash
#==========================================================#
#       QiQiManyou Server 自动化构建与部署脚本 (v2.4)
#==========================================================#

set -euo pipefail

# 自动切换到项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# ============= 配置区 =============
SERVER_USER="${1:-ubuntu}"
SERVER_IP="${2:-82.156.34.186}"
SERVER_DEPLOY_PATH="${SERVER_DEPLOY_PATH:-/home/ubuntu/qisd_eda_college}"
LOCAL_BUILD_DIR="backend"
IMAGE_NAME="qiqimanyou-server"
DOCKERFILE_PATH="$LOCAL_BUILD_DIR/Dockerfile"
REMOTE_TEMP_DIR="$SERVER_DEPLOY_PATH/backend"

# 生成带时间戳的文件名，便于管理和回滚
DATE_TAG="$(date +'%Y%m%d_%H%M%S')"
TAR_FILE="qiqimanyou_server_${DATE_TAG}.tar.gz"

# ============= 工具函数 =============
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📜 $*"; }
success() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $*"; }
error_exit() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ❌ 错误: $*" >&2; exit 1; }

# ============= 1. 环境检查 =============
log "🔍 检查环境依赖..."
for cmd in docker git ssh scp; do
  command -v "$cmd" >/dev/null 2>&1 || error_exit "$cmd 未安装，请先安装。"
done

# 检查 rust:slim 或 rust:1.87-bullseye 基础镜像
if ! docker image inspect rust:slim >/dev/null 2>&1 && ! docker image inspect rust:1.87-bullseye >/dev/null 2>&1; then
  error_exit "本地未找到 Rust 镜像，请手动拉取：docker pull --platform linux/amd64 rust:slim "
else
  success "本地存在 Rust 镜像，将用于构建。"
fi

# ============= 2.1 检查并拉取必要的基础镜像 =============
log "🔍 检查必要的基础镜像..."

if ! docker image inspect rust:slim > /dev/null 2>&1; then
  log "本地未找到 rust:slim，正在拉取..."
  docker pull rust:slim || error_exit "拉取 rust:slim 失败"
else
  success "本地已存在 rust:slim 镜像"
fi

if ! docker image inspect debian:bookworm-slim > /dev/null 2>&1; then
  log "本地未找到 debian:bookworm-slim，正在拉取..."
  docker pull --platform linux/amd64 debian:bookworm-slim || error_exit "拉取 debian:bookworm-slim 失败"
else
  success "本地已存在 debian:bookworm-slim 镜像"
fi

# ============= 2. 构建镜像 =============
log "🔨 构建镜像 $IMAGE_NAME:latest ..."
if docker build \
    --platform linux/amd64 \
    -t "$IMAGE_NAME:latest" \
    -f "$DOCKERFILE_PATH" .; then
  success "镜像构建成功: $IMAGE_NAME:latest"
else
  error_exit "镜像构建失败，请检查 Dockerfile 和上下文。"
fi

# ============= 3. 验证镜像架构 =============
log "🔍 验证镜像架构..."
ARCH=$(docker image inspect "$IMAGE_NAME:latest" --format '{{.Architecture}}' 2>/dev/null || echo "unknown")
OS=$(docker image inspect "$IMAGE_NAME:latest" --format '{{.Os}}' 2>/dev/null || echo "unknown")
log "镜像架构: $ARCH, 系统: $OS"

# ============= 4. 导出镜像为 tar 包 =============
log "📦 导出镜像为 tar 包 ($LOCAL_BUILD_DIR/$TAR_FILE)"
docker save "$IMAGE_NAME:latest" | gzip > "$LOCAL_BUILD_DIR/$TAR_FILE"
success "镜像已保存到 $LOCAL_BUILD_DIR/$TAR_FILE"

# ============= 5. 上传到云服务器 =============
log "🚀 上传镜像到云服务器..."
scp "$LOCAL_BUILD_DIR/$TAR_FILE" "$SERVER_USER@$SERVER_IP:$REMOTE_TEMP_DIR/"

# ============= 6. 远程加载镜像并重启后端服务 =============
log "🛠️ 远程加载镜像并重启后端服务..."
ssh "$SERVER_USER@$SERVER_IP" << EOF
cd "$REMOTE_TEMP_DIR"
echo "加载镜像: $TAR_FILE"
docker load -i "$TAR_FILE"

echo "停止后端服务..."
docker compose stop backend || true

echo "删除旧的后端容器..."
docker rm qiqimanyou-backend || true

echo "重启后端服务..."
docker compose up -d backend

echo "等待服务启动..."
sleep 5

echo "检查服务状态..."
docker compose ps

echo "清理镜像文件..."
rm -f "$TAR_FILE"
EOF

success "✅ 部署完成！镜像已更新并重启服务。"