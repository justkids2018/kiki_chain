#!/bin/bash

# ============================================
# Hi Kiki 本地开发环境启动脚本
# ============================================
# 功能：
# 1. 检测并启动 PostgreSQL (Docker)
# 2. 检测并启动 kiki_server (Rust 后端)
# 3. 检测并启动 kiki_admin (Vue 前端)
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$PROJECT_ROOT/kiki_server"
ADMIN_DIR="$PROJECT_ROOT/kiki_admin"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 未安装，请先安装 $1"
        return 1
    fi
    return 0
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # 端口被占用
    else
        return 1  # 端口空闲
    fi
}

# 检查并启动 PostgreSQL
start_postgres() {
    log_info "检查 PostgreSQL 数据库..."

    if check_port 5432; then
        log_success "PostgreSQL 已在运行 (端口 5432)"
        return 0
    fi

    log_warning "PostgreSQL 未运行，正在启动..."

    if ! check_command docker; then
        log_error "Docker 未安装，无法启动 PostgreSQL"
        return 1
    fi

    cd "$SERVER_DIR"

    # 检查容器是否存在但未运行
    if docker ps -a --format '{{.Names}}' | grep -q "hikiki_postgres_local"; then
        log_info "启动已存在的 PostgreSQL 容器..."
        docker start hikiki_postgres_local
    else
        log_info "创建并启动 PostgreSQL 容器..."
        docker-compose -f docker-compose.local.yml up -d postgres
    fi

    # 等待数据库就绪
    log_info "等待 PostgreSQL 就绪..."
    for i in {1..30}; do
        if check_port 5432; then
            log_success "PostgreSQL 启动成功！"
            return 0
        fi
        sleep 1
    done

    log_error "PostgreSQL 启动超时"
    return 1
}

# 检查并启动 Rust 后端
start_backend() {
    log_info "检查 Rust 后端服务..."

    if check_port 8081; then
        # 验证是否是我们的服务
        if curl -s http://localhost:8081/health | grep -q "qiqimanyou_server"; then
            log_success "Rust 后端已在运行 (端口 8081)"
            return 0
        else
            log_warning "端口 8081 被其他服务占用"
            return 1
        fi
    fi

    log_warning "Rust 后端未运行，正在启动..."

    if ! check_command cargo; then
        log_error "Rust/Cargo 未安装，无法启动后端"
        return 1
    fi

    cd "$SERVER_DIR"

    # 检查 .env 文件
    if [ ! -f ".env" ]; then
        log_error ".env 文件不存在，请先配置环境变量"
        return 1
    fi

    log_info "启动 Rust 后端 (cargo run)..."
    nohup cargo run > /tmp/kiki_server.log 2>&1 &
    local backend_pid=$!

    # 等待服务就绪
    log_info "等待后端服务就绪..."
    for i in {1..30}; do
        if curl -s http://localhost:8081/health > /dev/null 2>&1; then
            log_success "Rust 后端启动成功！(PID: $backend_pid)"
            echo $backend_pid > /tmp/kiki_server.pid
            return 0
        fi
        sleep 1
    done

    log_error "Rust 后端启动超时，查看日志: tail -f /tmp/kiki_server.log"
    return 1
}

# 检查并启动 Vue 前端
start_frontend() {
    log_info "检查 Vue 前端服务..."

    if check_port 5173; then
        log_success "Vue 前端已在运行 (端口 5173)"
        return 0
    fi

    log_warning "Vue 前端未运行，正在启动..."

    if ! check_command npm; then
        log_error "npm 未安装，无法启动前端"
        return 1
    fi

    cd "$ADMIN_DIR"

    # 检查 node_modules
    if [ ! -d "node_modules" ]; then
        log_info "首次运行，正在安装依赖..."
        npm install
    fi

    log_info "启动 Vue 前端 (npm run dev)..."
    nohup npm run dev > /tmp/kiki_admin.log 2>&1 &
    local frontend_pid=$!

    # 等待服务就绪
    log_info "等待前端服务就绪..."
    for i in {1..30}; do
        if check_port 5173; then
            log_success "Vue 前端启动成功！(PID: $frontend_pid)"
            echo $frontend_pid > /tmp/kiki_admin.pid
            return 0
        fi
        sleep 1
    done

    log_error "Vue 前端启动超时，查看日志: tail -f /tmp/kiki_admin.log"
    return 1
}

# 显示服务状态
show_status() {
    echo ""
    echo "=========================================="
    echo "  Hi Kiki 本地开发环境状态"
    echo "=========================================="
    echo ""

    # PostgreSQL
    if check_port 5432; then
        echo -e "✅ PostgreSQL:  ${GREEN}运行中${NC} (http://localhost:5432)"
    else
        echo -e "❌ PostgreSQL:  ${RED}未运行${NC}"
    fi

    # Rust 后端
    if check_port 8081; then
        echo -e "✅ Rust 后端:   ${GREEN}运行中${NC} (http://localhost:8081)"
        echo "   健康检查:    http://localhost:8081/health"
    else
        echo -e "❌ Rust 后端:   ${RED}未运行${NC}"
    fi

    # Vue 前端
    if check_port 5173; then
        echo -e "✅ Vue 前端:    ${GREEN}运行中${NC} (http://localhost:5173)"
        echo "   管理后台:    http://localhost:5173/"
        echo "   默认账号:    13900139002 / admin123"
    else
        echo -e "❌ Vue 前端:    ${RED}未运行${NC}"
    fi

    echo ""
    echo "=========================================="
    echo ""
}

# 主函数
main() {
    echo ""
    echo "🚀 启动 Hi Kiki 本地开发环境..."
    echo ""

    # 启动各个服务
    start_postgres || log_warning "PostgreSQL 启动失败，继续尝试启动其他服务..."
    start_backend || log_warning "Rust 后端启动失败，继续尝试启动其他服务..."
    start_frontend || log_warning "Vue 前端启动失败"

    # 显示最终状态
    show_status

    # 检查是否所有服务都启动成功
    if check_port 5432 && check_port 8081 && check_port 5173; then
        log_success "所有服务启动成功！🎉"
        echo ""
        echo "📝 日志文件:"
        echo "   - 后端日志: tail -f /tmp/kiki_server.log"
        echo "   - 前端日志: tail -f /tmp/kiki_admin.log"
        echo ""
        return 0
    else
        log_warning "部分服务启动失败，请检查日志"
        return 1
    fi
}

# 执行主函数
main
