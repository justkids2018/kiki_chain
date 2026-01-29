# Hi Kiki 本地数据库部署指南

## 概述

本项目使用 Docker 部署 PostgreSQL 15 数据库，用于 Hi Kiki 应用的本地开发环境。

## 前置要求

- Docker Desktop for Mac (已安装并运行)
- 端口 5432 未被占用

## 快速开始

### 1. 启动数据库

```bash
./scripts/db-start.sh
```

启动成功后，你将看到数据库连接信息。

### 2. 停止数据库

```bash
./scripts/db-stop.sh
```

### 3. 查看数据库日志

```bash
./scripts/db-logs.sh
```

### 4. 连接到数据库

```bash
./scripts/db-connect.sh
```

这将打开 psql 命令行界面。

### 5. 重置数据库

⚠️ **警告：此操作将删除所有数据！**

```bash
./scripts/db-reset.sh
```

## 数据库连接信息

- **Host**: localhost
- **Port**: 5432
- **Database**: hikiki_db
- **User**: postgres
- **Password**: postgres
- **连接字符串**: `postgresql://postgres:postgres@localhost:5432/hikiki_db`

## 数据库架构

数据库包含以下表：

1. **users** - 用户表
2. **scene_categories** - 一级分类表（春节场景、24节气、日常生活、游乐场景）
3. **scenes** - 二级场景表
4. **scene_items** - 场景物品表
5. **user_learning_records** - 用户学习记录表
6. **user_favorites** - 用户收藏表

详细的数据库架构请参考：`../kiki_web/doc/sql/schema.md`

## 初始化数据

数据库启动时会自动执行 `../kiki_web/doc/sql/init.sql` 脚本，包含：

- 创建所有表结构
- 创建索引
- 插入示例数据（分类、场景、测试用户等）

### 测试用户

- 手机号: 13800138000
- 密码: test123
- 昵称: 测试用户1

## 常用 SQL 命令

### 查看所有表

```sql
\dt
```

### 查看表结构

```sql
\d users
\d scene_categories
```

### 查询分类数据

```sql
SELECT * FROM scene_categories ORDER BY display_order;
```

### 查询场景数据

```sql
SELECT s.id, s.name, c.name as category_name
FROM scenes s
JOIN scene_categories c ON s.category_id = c.id
ORDER BY c.display_order, s.display_order;
```

## 数据持久化

数据存储在 Docker volume `kiki_server_hikiki_pgdata` 中，即使停止容器，数据也不会丢失。

只有执行 `db-reset.sh` 或手动删除 volume 才会清除数据：

```bash
docker volume rm kiki_server_hikiki_pgdata
```

## 故障排查

### 端口被占用

如果端口 5432 已被占用，可以修改 `docker-compose.local.yml` 中的端口映射：

```yaml
ports:
  - "5433:5432"  # 使用 5433 端口
```

### 数据库无法启动

1. 检查 Docker 是否运行：`docker info`
2. 查看日志：`./scripts/db-logs.sh`
3. 重置数据库：`./scripts/db-reset.sh`

### 连接被拒绝

确保数据库容器正在运行：

```bash
docker ps | grep hikiki_postgres
```

## 配置后端连接

在后端配置文件中使用以下连接字符串：

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/hikiki_db
```

## 生产环境部署

生产环境部署请参考 `backend/docker-compose.yml`，包含：

- 前端 (Flutter Web + Nginx)
- 后端 (Rust API)
- 数据库 (PostgreSQL)
- HTTPS 证书 (Certbot)
