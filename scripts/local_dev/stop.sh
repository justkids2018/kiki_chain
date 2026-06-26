#!/bin/bash

# ============================================
# Hi Kiki 本地开发环境停止脚本
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

configure_docker_cli() {
    if ! command -v docker &> /dev/null && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
        export PATH="$DOCKER_DESKTOP_BIN:$PATH"
    fi
}

# 停止后端
stop_backend() {
    log_info "停止 Rust 后端..."

    if [ -f /tmp/kiki_server.pid ]; then
        local pid=$(cat /tmp/kiki_server.pid)
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            rm /tmp/kiki_server.pid
            log_success "Rust 后端已停止"
        else
            log_warning "后端进程不存在"
            rm /tmp/kiki_server.pid
        fi
    else
        # 尝试通过端口查找进程
        local pid=$(lsof -ti:8081)
        if [ -n "$pid" ]; then
            kill $pid
            log_success "Rust 后端已停止"
        else
            log_info "Rust 后端未运行"
        fi
    fi
}

# 停止前端
stop_frontend() {
    log_info "停止 Vue 前端..."

    if [ -f /tmp/kiki_admin.pid ]; then
        local pid=$(cat /tmp/kiki_admin.pid)
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            rm /tmp/kiki_admin.pid
            log_success "Vue 前端已停止"
        else
            log_warning "前端进程不存在"
            rm /tmp/kiki_admin.pid
        fi
    else
        # 尝试通过端口查找进程
        local pid=$(lsof -ti:5173)
        if [ -n "$pid" ]; then
            kill $pid
            log_success "Vue 前端已停止"
        else
            log_info "Vue 前端未运行"
        fi
    fi
}

# 停止 PostgreSQL (可选)
stop_postgres() {
    log_info "停止 PostgreSQL..."

    if ! command -v docker &> /dev/null; then
        log_warning "Docker CLI 不可用，无法停止 PostgreSQL 容器"
        return 1
    fi

    if docker ps --format '{{.Names}}' | grep -q "hikiki_postgres_local"; then
        docker stop hikiki_postgres_local
        log_success "PostgreSQL 已停止"
    else
        log_info "PostgreSQL 未运行"
    fi
}

main() {
    echo ""
    echo "🛑 停止 Hi Kiki 本地开发环境..."
    echo ""

    configure_docker_cli

    stop_backend
    stop_frontend

    # 询问是否停止数据库
    read -p "是否停止 PostgreSQL 数据库? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stop_postgres
    else
        log_info "保持 PostgreSQL 运行"
    fi

    echo ""
    log_success "服务已停止！"
    echo ""
}

main
