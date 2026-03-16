# 开发环境配置

> 环境搭建、启动脚本、配置说明

---

## 📚 文档列表

### 核心文档

- **[开发环境快速启动](./DEV_SETUP.md)** ⭐ **必读**
  - 数据库连接信息
  - kiki_server 配置和启动
  - kiki_web API 地址配置
  - 启动检查清单
  - 常见问题解决

---

## 🔧 自动化脚本

**路径**: `../../scripts/`

### dev-start.sh - 智能启动脚本

```bash
# 检查环境状态（不启动任何服务）
./scripts/dev-start.sh

# 启动缺失的服务
./scripts/dev-start.sh --start
```

**功能**:
- 自动检查 Docker、PostgreSQL、kiki_server 状态
- 仅启动未运行的服务
- 验证服务健康状态

### dev-stop.sh - 优雅停止脚本

```bash
./scripts/dev-stop.sh
```

**功能**:
- 停止 kiki_server
- 停止 PostgreSQL（保留容器和数据）

---

## 🚀 快速开始

### 首次启动

1. 确保 Docker Desktop 运行中
2. 执行启动脚本：
   ```bash
   ./scripts/dev-start.sh --start
   ```
3. 验证服务：
   ```bash
   curl http://127.0.0.1:8081/health
   ```

### 日常开发

```bash
# 每次开发前检查
./scripts/dev-start.sh

# 如有服务未运行，启动它们
./scripts/dev-start.sh --start

# 开发完成后停止
./scripts/dev-stop.sh
```

---

**维护者**: Development Team
**最后更新**: 2026-03-12
