#!/bin/bash

# Hi Kiki 开发环境状态检查 + 按需启动脚本
# 用法:
#   ./dev-start.sh          — 仅检查状态（不启动任何服务）
#   ./dev-start.sh --start  — 检查状态，缺失的服务才启动

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KIKI_SERVER_DIR="$SCRIPT_DIR/../kiki_server"
START_MODE=false

if [ "$1" = "--start" ]; then
    START_MODE=true
fi

# ─── 检查函数 ────────────────────────────────────────────

check_docker() {
    if docker info > /dev/null 2>&1; then
        echo "✅ Docker Desktop 运行中"
        return 0
    else
        echo "❌ Docker Desktop 未运行"
        return 1
    fi
}

check_postgres() {
    local status
    status=$(docker inspect --format='{{.State.Status}}' hikiki_postgres_local 2>/dev/null)
    if [ "$status" = "running" ]; then
        # 进一步验证数据库可连接
        if docker exec hikiki_postgres_local psql -U postgres -d hikiki_db -c "SELECT 1" > /dev/null 2>&1; then
            echo "✅ PostgreSQL 运行中（localhost:5433 / hikiki_db）"
            return 0
        else
            echo "⚠️  PostgreSQL 容器运行中，但数据库连接失败"
            return 1
        fi
    else
        echo "❌ PostgreSQL 未运行（容器状态: ${status:-不存在}）"
        return 1
    fi
}

check_server() {
    if curl -s --max-time 2 http://127.0.0.1:8081/health > /dev/null 2>&1; then
        local pid
        pid=$(lsof -ti :8081 2>/dev/null)
        echo "✅ kiki_server 运行中（http://127.0.0.1:8081，PID: $pid）"
        return 0
    else
        echo "❌ kiki_server 未运行"
        return 1
    fi
}

# ─── 启动函数 ────────────────────────────────────────────

start_postgres() {
    echo "   → 启动 PostgreSQL..."
    cd "$KIKI_SERVER_DIR"
    docker compose -f docker-compose.local.yml up -d postgres > /dev/null 2>&1
    sleep 3
    if check_postgres > /dev/null 2>&1; then
        echo "   ✅ PostgreSQL 启动成功"
    else
        echo "   ❌ PostgreSQL 启动失败"
        exit 1
    fi
}

start_server() {
    echo "   → 启动 kiki_server..."
    cd "$KIKI_SERVER_DIR"
    if [ ! -f "target/release/qiqimanyou_server" ]; then
        echo "   ⚠️  二进制不存在，需要先编译: cd kiki_server && cargo build --release"
        exit 1
    fi
    RUST_ENV=development nohup ./target/release/qiqimanyou_server > /tmp/kiki_server.log 2>&1 &
    sleep 3
    if check_server > /dev/null 2>&1; then
        echo "   ✅ kiki_server 启动成功"
    else
        echo "   ❌ kiki_server 启动失败，查看日志: tail -f /tmp/kiki_server.log"
        exit 1
    fi
}

# ─── 主流程 ──────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Hi Kiki 开发环境状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DOCKER_OK=true
POSTGRES_OK=true
SERVER_OK=true

check_docker   || DOCKER_OK=false
check_postgres || POSTGRES_OK=false
check_server   || SERVER_OK=false

echo ""

# 如果全部正常，直接退出
if $DOCKER_OK && $POSTGRES_OK && $SERVER_OK; then
    echo "✨ 所有服务正常运行，无需操作"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# 有服务未运行
if ! $START_MODE; then
    echo "⚠️  部分服务未运行。如需启动，执行："
    echo "   ./scripts/dev-start.sh --start"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# --start 模式：只启动缺失的服务
echo "🚀 启动缺失的服务..."
echo ""

if ! $DOCKER_OK; then
    echo "❌ 请手动启动 Docker Desktop 后重试"
    exit 1
fi

$POSTGRES_OK || start_postgres
$SERVER_OK   || start_server

echo ""
echo "✨ 完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
