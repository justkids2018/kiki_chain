# 本地开发环境脚本

本目录包含 Hi Kiki 本地开发环境的启动和管理脚本。

## 📁 文件说明

- `start.sh` - 启动本地开发环境（PostgreSQL + Rust 后端 + Vue 前端）
- `migrate.sh` - 执行本地数据库增量迁移（读取 `scripts/deploy-release/db/migrations`）
- `stop.sh` - 停止本地开发环境
- `status.sh` - 查看服务运行状态
- `logs.sh` - 查看服务日志

## 🚀 快速开始

### 启动所有服务

```bash
./scripts/local_dev/start.sh
```

脚本会自动：
1. 检测服务是否已运行（避免重复启动）
2. 启动 PostgreSQL 数据库（Docker）
3. 自动执行本地数据库增量迁移（与线上迁移目录一致）
4. 启动 Rust 后端服务（cargo run）
5. 启动 Vue 前端服务（npm run dev）

### 仅执行数据库迁移

```bash
./scripts/local_dev/migrate.sh
```

### 停止所有服务

```bash
./scripts/local_dev/stop.sh
```

### 查看服务状态

```bash
./scripts/local_dev/status.sh
```

### 查看日志

```bash
# 查看所有日志
./scripts/local_dev/logs.sh

# 查看后端日志
./scripts/local_dev/logs.sh backend

# 查看前端日志
./scripts/local_dev/logs.sh frontend
```

## 📊 服务信息

启动成功后，可以访问：

- **PostgreSQL**: `localhost:5432`
  - 数据库: `hikiki_db`
  - 用户名: `postgres`
  - 密码: `postgres`

- **Rust 后端**: http://localhost:8081
  - 健康检查: http://localhost:8081/health
  - API 文档: http://localhost:8081/api/v1

- **Vue 前端**: http://localhost:5173
  - 管理后台: http://localhost:5173/
  - 默认账号: `13900139002`
  - 默认密码: `admin123`

## 📝 日志文件

- 后端日志: `/tmp/kiki_server.log`
- 前端日志: `/tmp/kiki_admin.log`
- 后端 PID: `/tmp/kiki_server.pid`
- 前端 PID: `/tmp/kiki_admin.pid`

## 🔧 故障排查

### 端口被占用

如果提示端口被占用，可以手动检查：

```bash
# 检查 5432 端口（PostgreSQL）
lsof -i :5432

# 检查 8081 端口（后端）
lsof -i :8081

# 检查 5173 端口（前端）
lsof -i :5173
```

### 服务启动失败

查看详细日志：

```bash
# 后端日志
tail -f /tmp/kiki_server.log

# 前端日志
tail -f /tmp/kiki_admin.log
```

### 数据库连接失败

确保 PostgreSQL 容器正在运行：

```bash
docker ps | grep hikiki_postgres_local
```

如果容器未运行，手动启动：

```bash
cd kiki_server
docker-compose -f docker-compose.local.yml up -d postgres
```

## 🎯 Claude 集成

你也可以通过 Claude 对话启动服务：

- "启动本地服务"
- "启动开发环境"
- "start local"

Claude 会自动执行 `start.sh` 脚本。
