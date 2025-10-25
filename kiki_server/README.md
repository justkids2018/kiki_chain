## 项目简介

本项目为基于 **Rust + Tokio (Axum)** 的后端服务，支持高性能异步 Web API，适用于现代云原生部署场景。

主要特性：
- 使用 Rust 语言，安全高效
- Tokio 异步运行时，支持高并发
- Axum 框架，易于扩展
- 支持 PostgreSQL、可选 Redis
- 适配 Docker、docker-compose 部署

## 本地运行

开发环境需安装 Rust 工具链（建议使用 [rustup](https://rustup.rs/) 安装）。

常用命令：

```bash
# 编译并运行（debug 模式）
cargo run

# 编译 release 版本
cargo build --release

# 运行测试
cargo test
```

更多部署与生产环境说明请见 `部署文档`。
