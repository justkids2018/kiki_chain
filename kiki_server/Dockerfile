# ================================
# Stage 1: Build
# ================================
FROM rust:1.82-slim-bookworm AS builder

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 先复制依赖文件，利用 Docker 层缓存
COPY Cargo.toml Cargo.lock ./

# 创建空的 src/main.rs 占位，提前编译依赖
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release 2>/dev/null || true
RUN rm -rf src target/release/qiqimanyou_server* target/release/deps/qiqimanyou_server*

# 复制实际源代码
COPY src ./src
COPY config ./config
COPY app.toml ./

# 构建应用
RUN cargo build --release

# ================================
# Stage 2: Runtime
# ================================
FROM rust:1.82-slim-bookworm

WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/target/release/qiqimanyou_server .
# 复制配置文件
COPY --from=builder /app/config ./config
COPY --from=builder /app/app.toml ./

# 暴露端口
EXPOSE 8081

# 设置时区
ENV TZ=Asia/Shanghai

# 启动命令
CMD ["./qiqimanyou_server"]
