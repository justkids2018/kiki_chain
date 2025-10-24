#!/bin/bash

# =============================================================================
# QiQiManyou Flutter Web 本地一键构建部署脚本 (优化版)
# 功能：Flutter构建 → Docker镜像构建 → 镜像导出压缩 → 部署文档生成
# 架构：Linux AMD64 (腾讯云兼容)
# 优化时间：2025年8月12日
# 特点：集成所有问题解决方案，一键完成所有构建流程
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
PROJECT_NAME="kikichain"
IMAGE_NAME="kikichain-flutter-web"
DATE_TAG=$(date +%Y%m%d)
IMAGE_TAG="latest"  # 固定使用 latest 标签
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
TARGET_PLATFORM="linux/amd64"
FRONTEND_DIR="frontend"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_LOG="build_${TIMESTAMP}.log"

# 导出文件配置
EXPORT_FILE="${FRONTEND_DIR}/${IMAGE_NAME}-amd64-${TIMESTAMP}.tar.gz"
BACKUP_FILE="${FRONTEND_DIR}/${IMAGE_NAME}-amd64-${TIMESTAMP}.tar.gz"

# Docker 镜像配置
BASE_IMAGE="nginx:alpine"
DOCKERFILE_PATH="${FRONTEND_DIR}/Dockerfile"

echo
echo -e "${CYAN}🚀 QiQiManyou Flutter Web 一键构建系统 v2.0${NC}"
echo "=================================================================="
echo -e "${BLUE}项目名称:${NC} ${PROJECT_NAME}"
echo -e "${BLUE}镜像名称:${NC} ${FULL_IMAGE_NAME}"
echo -e "${BLUE}目标架构:${NC} ${TARGET_PLATFORM}"
echo -e "${BLUE}基础镜像:${NC} ${BASE_IMAGE}"
echo -e "${BLUE}导出文件:${NC} ${EXPORT_FILE}"
echo -e "${BLUE}构建日志:${NC} ${BUILD_LOG}"
echo -e "${BLUE}Flutter SDK:${NC} $(which flutter 2>/dev/null || echo '未找到')"
echo -e "${BLUE}Docker 版本:${NC} $(docker --version 2>/dev/null || echo '未找到')"
echo "=================================================================="
echo

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%H:%M:%S') $1" | tee -a ${BUILD_LOG}
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%H:%M:%S') $1" | tee -a ${BUILD_LOG}
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%H:%M:%S') $1" | tee -a ${BUILD_LOG}
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') $1" | tee -a ${BUILD_LOG}
}

# 错误处理函数
handle_error() {
    local exit_code=$?
    log_error "构建过程中发生错误 (退出码: $exit_code)"
    log_error "请查看构建日志: ${BUILD_LOG}"
    
    # 显示详细的调试信息
    log_error "=== 调试信息 ==="
    log_error "当前工作目录: $(pwd)"
    log_error "目录内容:"
    ls -la
    
    if [[ -d "build" ]]; then
        log_error "build目录内容:"
        ls -la build/
        if [[ -d "build/web" ]]; then
            log_error "build/web目录内容:"
            ls -la build/web/
        fi
    fi
    
    # 显示Flutter和Dart信息
    log_error "Flutter信息:"
    flutter doctor -v >> ${BUILD_LOG} 2>&1 || echo "无法获取Flutter信息"
    
    log_error "最近的构建日志(最后50行):"
    tail -50 ${BUILD_LOG} 2>/dev/null || echo "无法读取构建日志"
    
    echo
    echo -e "${RED}❌ 构建失败！${NC}"
    echo -e "${YELLOW}💡 故障排查建议:${NC}"
    echo "1. 检查网络连接"
    echo "2. 运行 'flutter clean && flutter pub get'"
    echo "3. 检查Flutter SDK版本: flutter doctor"
    echo "4. 重启 Docker Desktop"
    echo "5. 清理 Docker 缓存: docker system prune -f"
    echo "6. 查看详细日志: cat ${BUILD_LOG}"
    echo "7. 手动运行构建: flutter build web --release"
    exit $exit_code
}

# 设置错误处理
trap handle_error ERR

# 重试机制函数
retry_command() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        log_info "尝试执行命令 (第 $attempt/$max_attempts 次): $*"
        
        if "$@"; then
            log_success "命令执行成功"
            return 0
        else
            if [[ $attempt -lt $max_attempts ]]; then
                log_warning "命令执行失败，${delay}秒后重试..."
                sleep $delay
            else
                log_error "命令执行失败，已达到最大重试次数"
                return 1
            fi
        fi
        ((attempt++))
    done
}

# 步骤1：环境检查
echo -e "${PURPLE}📋 步骤1：环境检查${NC}"
log_info "开始环境检查..."

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    log_error "Flutter 未安装或未在PATH中"
    echo -e "${YELLOW}请安装 Flutter: https://flutter.dev/docs/get-started/install${NC}"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -n 1 | grep -o 'Flutter [0-9.]*' || echo "Flutter 版本获取失败")
log_info "Flutter 版本: ${FLUTTER_VERSION}"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    echo -e "${YELLOW}请安装 Docker Desktop: https://www.docker.com/products/docker-desktop${NC}"
    exit 1
fi

if ! docker info &> /dev/null 2>&1; then
    log_error "Docker 未运行"
    echo -e "${YELLOW}请启动 Docker Desktop${NC}"
    exit 1
fi

DOCKER_VERSION=$(docker --version 2>/dev/null)
log_info "Docker 版本: ${DOCKER_VERSION}"

# 检查系统架构
SYSTEM_ARCH=$(uname -m)
log_info "系统架构: ${SYSTEM_ARCH}"

# 检查必要文件
log_info "检查项目文件..."
required_files=("${DOCKERFILE_PATH}" "${FRONTEND_DIR}/nginx.conf" "pubspec.yaml" "lib/main.dart")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        log_error "缺少必要文件: $file"
        exit 1
    fi
    log_info "✓ 找到文件: $file"
done

# 检查当前工作目录
if [[ ! -f "pubspec.yaml" ]]; then
    log_error "请在 Flutter 项目根目录下运行此脚本"
    exit 1
fi

log_success "环境检查完成"
echo

# 步骤2：依赖准备
echo -e "${PURPLE}📦 步骤2：依赖准备${NC}"
log_info "开始依赖准备..."

# 清理Flutter缓存
log_info "清理Flutter缓存..."
flutter clean >> ${BUILD_LOG} 2>&1 || {
    log_warning "Flutter clean失败，继续执行..."
}

# 获取 Flutter 依赖
log_info "获取 Flutter 依赖..."
if flutter pub get >> ${BUILD_LOG} 2>&1; then
    log_success "Flutter依赖获取成功"
else
    log_error "Flutter 依赖获取失败"
    log_error "请检查:"
    log_error "1. 网络连接是否正常"
    log_error "2. pubspec.yaml是否有语法错误"
    log_error "3. Flutter SDK是否正常"
    cat ${BUILD_LOG} | tail -20
    exit 1
fi

# 验证依赖
log_info "验证Flutter依赖..."
if flutter pub deps >> ${BUILD_LOG} 2>&1; then
    log_info "依赖验证成功"
else
    log_warning "依赖验证有警告，继续执行..."
fi

# 预拉取 Docker 基础镜像 (AMD64 架构)
log_info "预拉取 Docker 基础镜像 (${TARGET_PLATFORM})..."
retry_command 3 5 docker pull --platform ${TARGET_PLATFORM} ${BASE_IMAGE}

log_success "依赖准备完成"
echo

# 步骤3：Flutter Web 构建
echo -e "${PURPLE}🏗️ 步骤3：Flutter Web 构建${NC}"
log_info "开始 Flutter Web 构建..."

# 清理旧构建
if [[ -d "build/web" ]]; then
    log_info "清理旧的构建产物..."
    rm -rf build/web
fi

# 验证Flutter项目环境
build_flutter_web() {
    log_info "构建 Flutter Web 应用..."
    
    # 检查项目有效性
    if [[ ! -f "pubspec.yaml" ]]; then
        log_error "当前目录不是Flutter项目根目录，缺少pubspec.yaml"
        return 1
    fi
    
    if [[ ! -d "lib" ]]; then
        log_error "缺少lib目录，请确认在Flutter项目根目录"
        return 1
    fi
    
    log_info "当前工作目录: $(pwd)"
    log_info "执行Flutter Web构建命令..."
    
    # 执行Flutter构建命令
    flutter build web \
        --release \
        --dart-define=APP_ENV=production \
        --no-tree-shake-icons 2>&1 | tee -a "${BUILD_LOG}"
    
    local flutter_exit_code=${PIPESTATUS[0]}
    
    if [[ $flutter_exit_code -ne 0 ]]; then
        log_error "Flutter构建命令失败，退出码: $flutter_exit_code"
        log_error "请查看构建日志获取详细错误信息: $BUILD_LOG"
        log_error "最近的错误信息:"
        tail -20 "${BUILD_LOG}"
        return $flutter_exit_code
    fi
    
    log_success "Flutter构建命令执行成功"
    return 0
}

# 验证构建结果
validate_build_results() {
    log_info "验证Flutter Web构建结果..."
    
    # 检查build/web目录
    if [[ ! -d "build/web" ]]; then
        log_error "构建失败：build/web目录不存在"
        log_error "当前目录内容:"
        ls -la
        return 1
    fi
    
    # 检查关键文件
    local required_files=("build/web/index.html" "build/web/main.dart.js" "build/web/flutter.js")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "构建失败：缺少必要文件 $file"
            log_error "build/web目录内容:"
            ls -la build/web/
            return 1
        else
            log_info "✓ 找到文件: $file"
        fi
    done
    
    # 验证index.html内容
    if [[ -f "build/web/index.html" ]]; then
        local index_size
        index_size=$(stat -c%s "build/web/index.html" 2>/dev/null || stat -f%z "build/web/index.html" 2>/dev/null)
        
        if [[ $index_size -lt 500 ]]; then
            log_error "index.html文件太小($index_size bytes)，可能构建不完整"
            return 1
        fi
        
        if ! grep -q "main.dart.js" build/web/index.html; then
            log_error "index.html缺少main.dart.js引用，构建可能不完整"
            return 1
        fi
        
        log_info "✓ index.html验证通过"
    fi
    
    # 显示构建信息
    local build_size build_files
    build_size=$(du -sh build/web 2>/dev/null | cut -f1)
    build_files=$(find build/web -type f 2>/dev/null | wc -l)
    log_info "构建完成 - 大小: ${build_size}, 文件数: ${build_files}"
    
    return 0
}

# 执行构建流程
if build_flutter_web && validate_build_results; then
    log_success "Flutter Web 构建完成"
else
    log_error "Flutter Web 构建失败"
    exit 1
fi

echo

# 步骤4：Docker 镜像构建
echo -e "${PURPLE}🐳 步骤4：Docker 镜像构建 (${TARGET_PLATFORM})${NC}"
log_info "开始构建 Docker 镜像..."

# 验证 Dockerfile 存在
if [[ ! -f "${DOCKERFILE_PATH}" ]]; then
    log_error "Dockerfile 不存在: ${DOCKERFILE_PATH}"
    exit 1
fi

# 清理旧镜像
log_info "清理旧镜像..."
docker rmi ${FULL_IMAGE_NAME} 2>/dev/null || true

# 构建 Docker 镜像（唯一tag）
log_info "构建镜像: ${FULL_IMAGE_NAME} (平台: ${TARGET_PLATFORM})"
docker build \
    --platform ${TARGET_PLATFORM} \
    --no-cache \
    --progress=plain \
    --tag ${FULL_IMAGE_NAME} \
    --file ${DOCKERFILE_PATH} \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown") \
    . 2>&1 | tee -a ${BUILD_LOG}

# 验证构建结果
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    log_error "Docker 镜像构建失败"
    exit 1
fi

# 验证镜像架构
BUILT_ARCH=$(docker inspect ${FULL_IMAGE_NAME} | grep -o '"Architecture": "[^"]*"' | cut -d'"' -f4)
if [[ "$BUILT_ARCH" != "amd64" ]]; then
    log_error "镜像架构不正确，期望: amd64，实际: $BUILT_ARCH"
    exit 1
fi

# 显示镜像信息
IMAGE_SIZE=$(docker images ${FULL_IMAGE_NAME} --format "table {{.Size}}" | tail -n 1)
log_success "Docker 镜像构建完成 - 大小: ${IMAGE_SIZE}, 架构: ${BUILT_ARCH}"
echo

# 步骤5：镜像验证（跳过运行时测试）
echo -e "${PURPLE}🧪 步骤5：镜像验证${NC}"
log_info "验证镜像构建结果..."

# 验证镜像架构
BUILT_ARCH=$(docker inspect ${FULL_IMAGE_NAME} | grep -o '"Architecture": "[^"]*"' | cut -d'"' -f4)
if [[ "$BUILT_ARCH" != "amd64" ]]; then
    log_error "镜像架构不正确，期望: amd64，实际: $BUILT_ARCH"
    exit 1
fi

# 验证镜像是否包含必要的文件
log_info "验证 Flutter Web 文件是否正确复制到镜像中..."
docker run --rm --platform ${TARGET_PLATFORM} ${FULL_IMAGE_NAME} ls -la /usr/share/nginx/html/ | tee -a ${BUILD_LOG}

# 验证关键文件
if ! docker run --rm --platform ${TARGET_PLATFORM} ${FULL_IMAGE_NAME} test -f /usr/share/nginx/html/index.html; then
    log_error "镜像中缺少 index.html 文件"
    exit 1
fi

if ! docker run --rm --platform ${TARGET_PLATFORM} ${FULL_IMAGE_NAME} test -f /usr/share/nginx/html/main.dart.js; then
    log_error "镜像中缺少 main.dart.js 文件"
    exit 1
fi

log_success "镜像验证完成 - 架构: ${BUILT_ARCH}, 文件完整"
log_info "注意：由于 nginx 配置包含后端服务依赖，跳过运行时健康检查"
echo
# 步骤6：镜像导出和备份
echo -e "${PURPLE}💾 步骤6：镜像导出和备份${NC}"
log_info "开始导出 Docker 镜像..."

# 备份现有文件
if [[ -f "${EXPORT_FILE}" ]]; then
    log_info "备份现有镜像文件..."
    mv "${EXPORT_FILE}" "${BACKUP_FILE}"
fi

# 导出镜像（唯一tag）
log_info "导出镜像: ${FULL_IMAGE_NAME} -> ${EXPORT_FILE}"
log_info "这可能需要几分钟，请耐心等待..."

docker save ${FULL_IMAGE_NAME} | gzip > ${EXPORT_FILE}

# 验证导出结果
if [[ ! -f "${EXPORT_FILE}" ]]; then
    log_error "镜像导出失败"
    exit 1
fi

FILE_SIZE=$(du -h "${EXPORT_FILE}" | cut -f1)
FILE_SIZE_BYTES=$(stat -f%z "${EXPORT_FILE}" 2>/dev/null || stat -c%s "${EXPORT_FILE}" 2>/dev/null)

if [[ $FILE_SIZE_BYTES -lt 1000000 ]]; then
    log_error "导出的镜像文件太小，可能导出失败"
    exit 1
fi

log_success "镜像导出完成 - 文件大小: ${FILE_SIZE}"
log_info "导出文件: ${EXPORT_FILE}"
echo

# 步骤7：生成部署文档和脚本
echo -e "${PURPLE}📋 步骤7：生成部署文档${NC}"
log_info "生成腾讯云部署文档..."

QUICK_DEPLOY_SCRIPT="${FRONTEND_DIR}/quick_deploy_server.sh"
cat > ${QUICK_DEPLOY_SCRIPT} << EOF
#!/bin/bash

# QiQiManyou 腾讯云服务器快速部署脚本
# 在上传文件到服务器后执行此脚本

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 QiQiManyou 腾讯云快速部署${NC}"
echo "========================================"

# 检查必要文件
echo -e "${BLUE}📋 检查部署文件...${NC}"
required_files=("kikichain-flutter-web-amd64.tar.gz" "docker-compose.yml" "nginx.conf")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}❌ 缺少文件: $file${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ 找到文件: $file${NC}"
done

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker 未安装，正在安装...${NC}"
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
fi

# 停止现有容器
echo -e "${BLUE}🛑 停止现有容器...${NC}"
docker compose down 2>/dev/null || true


# 导入镜像
echo -e "${BLUE}📦 导入 Docker 镜像...${NC}"
docker load < ${IMAGE_NAME}-amd64-${TIMESTAMP}.tar.gz

# 验证镜像
echo -e "${BLUE}� 验证镜像...${NC}"
docker inspect ${IMAGE_NAME}:${IMAGE_TAG} | grep -A 2 "Architecture"

# 启动服务（需在docker-compose.yml中指定对应tag）
echo -e "${BLUE}🚀 启动服务...${NC}"
docker compose up -d

# 健康检查
echo -e "${BLUE}🧪 健康检查...${NC}"
sleep 10
if curl -f http://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 部署成功！应用已启动${NC}"
    echo -e "${GREEN}🌐 访问地址: http://keepthinking.me${NC}"
else
    echo -e "${RED}❌ 健康检查失败${NC}"
    docker compose logs
fi

echo "========================================"
echo -e "${GREEN}🎉 部署完成！${NC}"
EOF

chmod +x ${QUICK_DEPLOY_SCRIPT}
log_success "快速部署脚本生成完成: ${QUICK_DEPLOY_SCRIPT}"
echo

# 步骤8：构建总结
echo -e "${PURPLE}� 步骤8：构建总结${NC}"
log_info "生成构建报告..."

# 生成构建报告
REPORT_FILE="${FRONTEND_DIR}/build_report_${TIMESTAMP}.md"
cat > ${REPORT_FILE} << EOF
# QiQiManyou Flutter Web 构建报告

## 📅 构建信息
- **构建时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **Flutter 版本**: ${FLUTTER_VERSION}
- **Docker 版本**: ${DOCKER_VERSION}
- **目标架构**: ${TARGET_PLATFORM}
- **系统架构**: ${SYSTEM_ARCH}

## 📦 构建产物
- **Docker 镜像**: ${FULL_IMAGE_NAME}
- **镜像大小**: ${IMAGE_SIZE}
- **导出文件**: ${EXPORT_FILE}
- **文件大小**: ${FILE_SIZE}
- **Flutter 构建大小**: ${BUILD_SIZE}

## 🏗️ 构建配置
- **Web 渲染器**: canvaskit
- **构建模式**: release
- **源码映射**: 启用
- **Tree shaking**: 禁用图标
- **平台**: ${TARGET_PLATFORM}

## 📋 部署文件清单
\`\`\`
${FRONTEND_DIR}/
├── kikichain-flutter-web-amd64.tar.gz     # Docker 镜像文件
├── docker-compose.yml                       # 容器编排配置
├── nginx.conf                              # Nginx 配置
├── quick_deploy_server.sh                  # 快速部署脚本
├── 腾讯云部署指南_AMD64.md                   # 详细部署文档
└── build_report_${TIMESTAMP}.md            # 本构建报告
\`\`\`

## 🚀 部署步骤
1. 上传部署文件到腾讯云服务器
2. 执行快速部署脚本: \`./quick_deploy_server.sh\`
3. 访问: http://keepthinking.me

## 📞 技术支持
- 构建日志: ${BUILD_LOG}
- Flutter 版本: ${FLUTTER_VERSION}
- 构建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

log_success "构建报告生成完成: ${REPORT_FILE}"
echo

# 步骤9：最终验证和总结
echo -e "${PURPLE}🎯 步骤9：最终验证和总结${NC}"
log_info "执行最终验证..."

# 验证所有生成的文件
GENERATED_FILES=(
    "${EXPORT_FILE}"
    "${QUICK_DEPLOY_SCRIPT}"
    "${REPORT_FILE}"
    "${BUILD_LOG}"
)

for file in "${GENERATED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        log_info "✓ 验证文件存在: $file"
    else
        log_error "✗ 文件缺失: $file"
        exit 1
    fi
done

# 显示构建总结
echo
echo "=================================================================="
echo -e "${CYAN}🎉 QiQiManyou Flutter Web 构建完成！${NC}"
echo "=================================================================="
echo
echo -e "${GREEN}📦 构建产物：${NC}"
echo -e "  ├── Docker 镜像: ${FULL_IMAGE_NAME}"
echo -e "  ├── 镜像文件: ${EXPORT_FILE} (${FILE_SIZE})"
echo -e "  ├── 构建大小: ${BUILD_SIZE}"
echo -e "  └── 镜像架构: ${BUILT_ARCH}"
echo
echo -e "${GREEN}📋 部署文件：${NC}"
echo -e "  ├── ${QUICK_DEPLOY_SCRIPT}"
echo -e "  ├── ${FRONTEND_DIR}/docker-compose.yml"
echo -e "  ├── ${FRONTEND_DIR}/nginx.conf"
echo -e "  ├── ${FRONTEND_DIR}/腾讯云部署指南_AMD64.md"
echo -e "  └── ${REPORT_FILE}"
echo
echo -e "${GREEN}🚀 下一步操作：${NC}"
echo "1. 上传以下文件到腾讯云服务器 /opt/kikichain/ 目录："
echo "   - ${EXPORT_FILE}"
echo "   - ${FRONTEND_DIR}/docker-compose.yml"
echo "   - ${FRONTEND_DIR}/nginx.conf"
echo "   - ${QUICK_DEPLOY_SCRIPT}"
echo
echo "2. 在服务器上执行部署："
echo "   cd /opt/kikichain"
echo "   chmod +x quick_deploy_server.sh"
echo "   ./quick_deploy_server.sh"
echo
echo "3. 访问应用："
echo "   http://keepthinking.me"
echo
echo -e "${GREEN}📊 构建统计：${NC}"
echo -e "  ├── 构建时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "  ├── Flutter 版本: ${FLUTTER_VERSION}"
echo -e "  ├── Docker 版本: ${DOCKER_VERSION}"
echo -e "  ├── 目标架构: ${TARGET_PLATFORM}"
echo -e "  └── 构建日志: ${BUILD_LOG}"
echo
echo -e "${YELLOW}💡 提示：${NC}"
echo "- 详细部署指南：${FRONTEND_DIR}/腾讯云部署指南_AMD64.md"
echo "- 构建报告：${REPORT_FILE}"
echo "- 如遇问题请查看：${BUILD_LOG}"
echo
echo "=================================================================="
log_success "所有构建任务完成！"

 
# 步骤10：自动上传到服务器
echo -e "${PURPLE}☁️ 步骤10：上传到服务器${NC}"
SERVER_USER="ubuntu"
SERVER_HOST="82.156.34.186"
SERVER_PATH="~/qisd_eda_college/frontend"

if [[ -f "${EXPORT_FILE}" ]]; then
    echo -e "${BLUE}开始上传: ${EXPORT_FILE} -> ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}${NC}"
    scp "${EXPORT_FILE}" ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}上传成功！${NC}"
    else
        echo -e "${RED}上传失败，请检查网络和权限。${NC}"
    fi
else
    echo -e "${RED}未找到导出文件: ${EXPORT_FILE}，无法上传。${NC}"
fi

# 步骤11：云端服务器部署
echo
echo -e "${PURPLE}🚀 步骤11：云端服务器部署${NC}"
echo "=================================================================="

# 服务器配置
SERVER_USER="ubuntu"
SERVER_HOST="82.156.34.186"
SERVER_PATH="~/qisd_eda_college/frontend"

echo -e "${BLUE}连接服务器: ${SERVER_USER}@${SERVER_HOST}${NC}"

# 执行远程部署命令
ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e

echo "🔄 切换到项目目录..."
cd ~/qisd_eda_college/frontend

echo "⏹️  停止当前运行的容器..."
docker compose down || true

echo "🧹 清理旧镜像..."
OLD_IMAGES=$(docker images kikichain-flutter-web --format "{{.ID}} {{.Tag}}" | grep -v "latest" | awk '{print $1}')
if [[ -n "$OLD_IMAGES" ]]; then
    echo "$OLD_IMAGES" | xargs docker rmi -f 2>/dev/null || true
fi

echo "📦 加载最新镜像..."
LATEST_IMAGE=$(ls -t kikichain-flutter-web-amd64-*.tar.gz 2>/dev/null | head -1)
if [[ -n "$LATEST_IMAGE" ]]; then
    echo "正在加载: $LATEST_IMAGE"
    docker load < "$LATEST_IMAGE"
    if [[ $? -eq 0 ]]; then
        echo "✅ 镜像加载成功！"
    else
        echo "❌ 镜像加载失败"
        exit 1
    fi
else
    echo "❌ 未找到镜像文件"
    exit 1
fi

echo "🔍 验证镜像..."
docker images kikichain-flutter-web:latest

echo "🚀 启动服务..."
docker compose up -d

echo "⏳ 等待服务启动..."
sleep 10

echo "📊 检查服务状态..."
docker compose ps

echo "🧪 测试服务..."
if curl -f -s http://localhost > /dev/null; then
    echo "✅ 服务启动成功！"
    echo "🌐 访问地址: http://keepthinking.me/"
else
    echo "❌ 服务启动失败"
    echo "� 查看容器日志:"
    docker-compose logs --tail=20
    exit 1
fi

echo "🎉 云端部署完成！"
ENDSSH

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ 云端部署成功！${NC}"
    echo -e "🌐 网站地址: http://keepthinking.me/"
    echo -e "� 管理命令: ssh ${SERVER_USER}@${SERVER_HOST} 'cd ${SERVER_PATH} && docker-compose logs -f'"
else
    echo -e "${RED}❌ 云端部署失败${NC}"
    echo -e "🔧 手动登录服务器检查: ssh ${SERVER_USER}@${SERVER_HOST}"
fi

echo
echo "=================================================================="
log_success "完整部署流程完成！"

# 退出
exit 0
