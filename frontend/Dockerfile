# 使用本地 nginx:alpine 镜像作为基础镜像
# Alpine Linux 是一个轻量级的 Linux 发行版，镜像大小约 5-10MB
# 支持 linux/amd64 架构，适用于腾讯云等云服务商
# 使用 nginx:alpine 作为基础镜像 - 强制 linux/amd64 架构
# Alpine Linux 是一个轻量级的 Linux 发行版，镜像大小约 5-10MB
# 明确指定 linux/amd64 架构以确保在腾讯云等 AMD64 服务器上运行
FROM --platform=linux/amd64 nginx:alpine

# 维护者信息和镜像元数据
LABEL maintainer="kikichain-team"
LABEL description="奇奇漫游记 Flutter Web 应用 - 生产环境镜像"
LABEL version="1.0.1"
LABEL project="kikichain"
LABEL architecture="linux/amd64"

# 设置时区为中国标准时间
ENV TZ=Asia/Shanghai

# 更新包管理器并安装必要的工具
# 使用阿里云镜像源加速下载（针对中国大陆用户）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        tzdata \
        curl \
        gzip \
        tini && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /var/cache/apk/*

# 复制自定义 nginx 配置文件
# 这个配置文件包含了针对 Flutter Web 应用的优化设置
COPY frontend/nginx.conf /etc/nginx/nginx.conf

# 复制 Flutter Web 构建产物到 nginx 静态文件目录
# build/web/ 是 Flutter Web 构建后的输出目录（本地已构建）
COPY build/web/ /usr/share/nginx/html/

# 设置 Web 文件的正确权限
# 确保 nginx 用户可以读取所有 Web 文件
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    test -f /usr/share/nginx/html/index.html || (echo "❌ 错误：index.html 文件不存在！请先运行 flutter build web" && exit 1) && \
    test -f /usr/share/nginx/html/main.dart.js || (echo "❌ 错误：main.dart.js 文件不存在！Flutter 构建可能失败" && exit 1) && \
    echo "📁 Web 文件结构：" && \
    ls -la /usr/share/nginx/html/ && \
    echo "✅ Flutter Web 文件部署完成"

# 创建 nginx 缓存目录
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx

# 健康检查配置
# 每30秒检查一次，超时10秒，启动5秒后开始检查，连续失败3次认为不健康
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露 HTTP 端口
EXPOSE 80

# 切换到非特权用户运行（安全最佳实践）
USER nginx

# 使用 tini 作为初始化系统，确保正确处理信号和僵尸进程
ENTRYPOINT ["/sbin/tini", "--"]

# 启动 Nginx
# daemon off 确保 Nginx 在前台运行，这是 Docker 容器的要求
CMD ["nginx", "-g", "daemon off;"]
