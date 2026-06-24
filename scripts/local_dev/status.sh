#!/bin/bash

# ============================================
# Hi Kiki 本地开发环境状态查看脚本
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
DOCKER_DESKTOP_BIN="/Applications/Docker.app/Contents/Resources/bin"

configure_docker_cli() {
    if ! command -v docker &> /dev/null && [ -x "$DOCKER_DESKTOP_BIN/docker" ]; then
        export PATH="$DOCKER_DESKTOP_BIN:$PATH"
    fi
}

postgres_container_running() {
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^hikiki_postgres_local$"
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

# 获取进程 PID
get_pid_by_port() {
    local port=$1
    lsof -ti:$port 2>/dev/null || echo ""
}

# 显示服务状态
show_status() {
    echo ""
    echo "=========================================="
    echo "  Hi Kiki 本地开发环境状态"
    echo "=========================================="
    echo ""

    # PostgreSQL
    if postgres_container_running; then
        local pid=$(get_pid_by_port 5432)
        echo -e "✅ PostgreSQL:  ${GREEN}运行中${NC} (http://localhost:5432)"
        echo "   进程 PID:    $pid"
        echo "   数据库:      hikiki_db"
        echo "   用户名:      postgres"
    elif check_port 5432; then
        local pid=$(get_pid_by_port 5432)
        echo -e "⚠️  PostgreSQL:  ${YELLOW}5432 被占用，但项目容器未确认${NC}"
        echo "   进程 PID:    $pid"
        echo "   项目容器:    hikiki_postgres_local 未运行或 Docker CLI 不可用"
    else
        echo -e "❌ PostgreSQL:  ${RED}未运行${NC}"
    fi

    echo ""

    # Rust 后端
    if check_port 8081; then
        local pid=$(get_pid_by_port 8081)
        echo -e "✅ Rust 后端:   ${GREEN}运行中${NC} (http://localhost:8081)"
        echo "   进程 PID:    $pid"
        echo "   健康检查:    http://localhost:8081/health"
        echo "   日志文件:    /tmp/kiki_server.log"

        # 尝试获取版本信息
        local version=$(curl -s http://localhost:8081/health 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$version" ]; then
            echo "   版本:        $version"
        fi
    else
        echo -e "❌ Rust 后端:   ${RED}未运行${NC}"
    fi

    echo ""

    # Vue 前端
    if check_port 5173; then
        local pid=$(get_pid_by_port 5173)
        echo -e "✅ Vue 前端:    ${GREEN}运行中${NC} (http://localhost:5173)"
        echo "   进程 PID:    $pid"
        echo "   管理后台:    http://localhost:5173/"
        echo "   日志文件:    /tmp/kiki_admin.log"
        echo "   默认账号:    13900139002 / admin123"
    else
        echo -e "❌ Vue 前端:    ${RED}未运行${NC}"
    fi

    echo ""
    echo "=========================================="
    echo ""

    # 显示快捷命令
    echo "💡 快捷命令:"
    echo "   启动服务:    ./scripts/local_dev/start.sh"
    echo "   停止服务:    ./scripts/local_dev/stop.sh"
    echo "   查看日志:    ./scripts/local_dev/logs.sh"
    echo ""
}

# 主函数
main() {
    configure_docker_cli
    show_status
}

main
