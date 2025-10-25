# ==============================================
# Rust + Tokio 后端服务生产环境多阶段构建 Dockerfile
# 项目：qiqimanyou_server
# 用途：编译 Rust 项目并生成精简的生产镜像
# ==============================================

# ===================== 构建阶段 =====================
FROM --platform=linux/amd64 rust:slim AS builder
WORKDIR /app

# 安装构建依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        pkg-config \
        libssl-dev \
        libpq-dev \
        ca-certificates \
        build-essential \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/* \
    && echo "✅ 构建依赖安装完成"

# 复制依赖文件，利用缓存
COPY Cargo.toml Cargo.lock ./

# 复制源代码和配置
COPY src ./src
COPY config ./config

# 编译 release 版本
RUN cargo build --release

# ===================== 运行时阶段 =====================
FROM --platform=linux/amd64 debian:bookworm-slim
WORKDIR /app

# 安装运行时依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3 \
        libpq5 \
        tzdata \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && echo "✅ 运行时依赖安装完成"

# 设置时区
ENV TZ=Asia/Shanghai

# 创建非 root 用户
RUN useradd -m -u 1001 appuser

# 复制编译产物
COPY --from=builder /app/target/release/qiqimanyou_server /app/qiqimanyou_server
COPY --from=builder /app/config /app/config

# 设置权限
RUN chown -R appuser:appuser /app && chmod +x /app/qiqimanyou_server

USER appuser
EXPOSE 8001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# 启动服务
CMD ["./qiqimanyou_server"]