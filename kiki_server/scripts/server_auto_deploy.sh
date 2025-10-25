#!/bin/bash

# ==========================================
# 奇奇漫游记自动化部署脚本
# 从本地重建镜像到服务器启动验证的完整流程
# ==========================================

set -e  # 遇到错误立即退出

# 配置变量
SERVER_IP="82.156.34.186"
SERVER_USER="ubuntu"
SERVER_PATH="~/qisd_eda_college"
LOCAL_BACKEND_DIR="backend"
DOCKER_IMAGE_NAME="qiqimanyou-server"
DOCKER_TAG="linux-amd64"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查前置条件
check_prerequisites() {
    log_info "检查前置条件..."
    
    # 检查Docker是否安装
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    # 检查SSH连接
    if ! ssh -o ConnectTimeout=5 ${SERVER_USER}@${SERVER_IP} "echo 'SSH连接正常'" &> /dev/null; then
        log_error "无法连接到服务器 ${SERVER_IP}，请检查SSH配置"
        exit 1
    fi
    
    # 检查Dockerfile是否存在
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile不存在，请确保在项目根目录运行脚本"
        exit 1
    fi
    
    log_success "前置条件检查通过"
}

# 清理旧镜像和文件
cleanup_old_files() {
    log_info "清理旧的镜像文件..."
    
    # 清理本地旧镜像文件
    if [ -f "${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz" ]; then
        rm -f "${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz"
        log_info "删除旧的本地镜像文件"
    fi
    
    # 清理Docker中的旧镜像
    if docker images | grep -q "${DOCKER_IMAGE_NAME}.*${DOCKER_TAG}"; then
        docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} 2>/dev/null || true
        log_info "删除旧的Docker镜像"
    fi
}

# 重建Docker镜像
rebuild_docker_image() {
    log_info "重建Docker镜像 (linux/amd64架构)..."
    
    # 构建镜像
    docker build --platform=linux/amd64 -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .
    
    # 验证镜像架构
    ARCH=$(docker inspect ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} --format='{{.Architecture}}')
    OS=$(docker inspect ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} --format='{{.Os}}')
    
    if [ "$ARCH" != "amd64" ] || [ "$OS" != "linux" ]; then
        log_error "镜像架构不正确: ${OS}/${ARCH}，期望: linux/amd64"
        exit 1
    fi
    
    log_success "Docker镜像构建成功 (${OS}/${ARCH})"
}

# 导出并压缩镜像
export_and_compress_image() {
    log_info "导出并压缩Docker镜像..."
    
    # 确保backend目录存在
    mkdir -p ${LOCAL_BACKEND_DIR}
    
    # 导出镜像
    docker save ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} -o ${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar
    
    # 压缩镜像
    gzip ${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar
    
    # 检查文件大小
    FILE_SIZE=$(du -h ${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz | cut -f1)
    log_success "镜像压缩完成，大小: ${FILE_SIZE}"
}

# 上传文件到服务器
upload_to_server() {
    log_info "上传文件到服务器..."
    
    # 上传压缩的镜像文件
    scp ${LOCAL_BACKEND_DIR}/${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/backend/
    log_success "镜像文件上传完成"
    
    # 上传docker-compose和nginx配置（如果需要更新）
    if [ -f "${LOCAL_BACKEND_DIR}/docker-compose.yml" ]; then
        scp ${LOCAL_BACKEND_DIR}/docker-compose.yml ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/
        log_info "docker-compose.yml已更新"
    fi
    
    if [ -f "nginx.conf" ]; then
        scp nginx.conf ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/
        log_info "nginx.conf已更新"
    fi
}

# 在服务器上部署服务
deploy_on_server() {
    log_info "在服务器上部署服务..."
    
    # 执行服务器端部署脚本
    ssh ${SERVER_USER}@${SERVER_IP} << EOF
        set -e
        cd ${SERVER_PATH}
        
        # 停止旧服务
        echo "停止旧服务..."
        docker compose down 2>/dev/null || true
        
        # 解压并加载新镜像
        echo "加载新镜像..."
        cd backend
        gunzip -f ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz
        docker load -i ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar
        
        # 重新标记镜像为latest
        docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE_NAME}:latest
        
        # 返回项目根目录并启动服务
        cd ..
        echo "启动服务..."
        docker compose up -d
        
        # 等待服务启动
        echo "等待服务启动..."
        sleep 10
EOF
    
    log_success "服务器端部署完成"
}

# 验证服务状态
verify_deployment() {
    log_info "验证部署状态..."
    
    # 检查容器状态
    log_info "检查容器状态..."
    ssh ${SERVER_USER}@${SERVER_IP} "cd ${SERVER_PATH} && docker compose ps"
    
    # 等待服务完全启动
    log_info "等待服务完全启动..."
    sleep 15
    
    # 检查健康检查端点
    log_info "测试健康检查端点..."
    
    # 重试机制
    for i in {1..5}; do
        if curl -f -s http://${SERVER_IP}/health > /dev/null; then
            HEALTH_RESPONSE=$(curl -s http://${SERVER_IP}/health)
            log_success "健康检查通过!"
            echo "响应: ${HEALTH_RESPONSE}"
            break
        else
            if [ $i -eq 5 ]; then
                log_error "健康检查失败，请检查服务日志"
                ssh ${SERVER_USER}@${SERVER_IP} "cd ${SERVER_PATH} && docker compose logs --tail=20"
                exit 1
            else
                log_warning "健康检查失败，重试中... ($i/5)"
                sleep 10
            fi
        fi
    done
    
    # 测试nginx代理
    log_info "测试nginx代理..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${SERVER_IP}/)
    if [ "$HTTP_STATUS" = "404" ]; then
        log_success "nginx代理工作正常 (HTTP $HTTP_STATUS)"
    else
        log_warning "nginx响应状态: HTTP $HTTP_STATUS"
    fi
}

# 显示部署结果
show_deployment_result() {
    log_success "🎉 部署完成!"
    echo ""
    echo "服务访问地址:"
    echo "  健康检查: http://${SERVER_IP}/health"
    echo "  API基础URL: http://${SERVER_IP}/api/"
    echo "  直接后端访问: http://${SERVER_IP}:8001/"
    echo ""
    echo "常用管理命令:"
    echo "  查看服务状态: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${SERVER_PATH} && docker compose ps'"
    echo "  查看服务日志: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${SERVER_PATH} && docker compose logs -f'"
    echo "  重启服务: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${SERVER_PATH} && docker compose restart'"
    echo "  停止服务: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${SERVER_PATH} && docker compose down'"
}

# 主函数
main() {
    echo "============================================"
    echo "  奇奇漫游记自动化部署脚本"
    echo "  目标服务器: ${SERVER_IP}"
    echo "============================================"
    echo ""
    
    check_prerequisites
    cleanup_old_files
    rebuild_docker_image
    export_and_compress_image
    upload_to_server
    deploy_on_server
    verify_deployment
    show_deployment_result
    
    log_success "✨ 自动化部署流程全部完成!"
}

# 错误处理
trap 'log_error "部署过程中发生错误，退出"; exit 1' ERR

# 运行主函数
main "$@"
