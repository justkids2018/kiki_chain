#!/bin/bash

# ============================================
# Hi Kiki 本地开发环境日志查看脚本
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKEND_LOG="/tmp/kiki_server.log"
FRONTEND_LOG="/tmp/kiki_admin.log"

show_usage() {
    echo "用法: $0 [backend|frontend|all]"
    echo ""
    echo "选项:"
    echo "  backend   - 查看后端日志"
    echo "  frontend  - 查看前端日志"
    echo "  all       - 同时查看所有日志（默认）"
    echo ""
    echo "示例:"
    echo "  $0              # 查看所有日志"
    echo "  $0 backend      # 只查看后端日志"
    echo "  $0 frontend     # 只查看前端日志"
}

show_backend_log() {
    if [ -f "$BACKEND_LOG" ]; then
        echo -e "${BLUE}=== Rust 后端日志 ===${NC}"
        echo -e "${YELLOW}文件: $BACKEND_LOG${NC}"
        echo ""
        tail -f "$BACKEND_LOG"
    else
        echo -e "${RED}后端日志文件不存在: $BACKEND_LOG${NC}"
        echo "提示: 后端可能未启动或日志路径不正确"
    fi
}

show_frontend_log() {
    if [ -f "$FRONTEND_LOG" ]; then
        echo -e "${BLUE}=== Vue 前端日志 ===${NC}"
        echo -e "${YELLOW}文件: $FRONTEND_LOG${NC}"
        echo ""
        tail -f "$FRONTEND_LOG"
    else
        echo -e "${RED}前端日志文件不存在: $FRONTEND_LOG${NC}"
        echo "提示: 前端可能未启动或日志路径不正确"
    fi
}

show_all_logs() {
    echo -e "${BLUE}=== 查看所有日志（按 Ctrl+C 退出）===${NC}"
    echo ""

    if [ -f "$BACKEND_LOG" ] && [ -f "$FRONTEND_LOG" ]; then
        # 使用 multitail 或 tail 同时查看多个日志
        if command -v multitail &> /dev/null; then
            multitail -l "tail -f $BACKEND_LOG" -l "tail -f $FRONTEND_LOG"
        else
            echo -e "${YELLOW}提示: 安装 multitail 可以更好地查看多个日志${NC}"
            echo -e "${YELLOW}      brew install multitail${NC}"
            echo ""
            echo -e "${BLUE}=== 后端日志 ===${NC}"
            tail -n 20 "$BACKEND_LOG"
            echo ""
            echo -e "${BLUE}=== 前端日志 ===${NC}"
            tail -n 20 "$FRONTEND_LOG"
            echo ""
            echo -e "${YELLOW}使用以下命令分别查看实时日志:${NC}"
            echo "  后端: tail -f $BACKEND_LOG"
            echo "  前端: tail -f $FRONTEND_LOG"
        fi
    elif [ -f "$BACKEND_LOG" ]; then
        show_backend_log
    elif [ -f "$FRONTEND_LOG" ]; then
        show_frontend_log
    else
        echo -e "${RED}没有找到任何日志文件${NC}"
        echo "提示: 请先启动服务"
    fi
}

main() {
    local target="${1:-all}"

    case "$target" in
        backend)
            show_backend_log
            ;;
        frontend)
            show_frontend_log
            ;;
        all)
            show_all_logs
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo -e "${RED}错误: 未知选项 '$target'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
