# 数据库设置指南

> **注意**: 数据库执行事实源已统一到 `kiki_server/database/`。
> 本文档仅保留本地开发的快速参考。

---

## 🚀 快速开始

### 本地开发环境

**使用 Docker Compose**:
```bash
# 启动数据库
docker compose -f docker-compose.local.yml up -d postgres

# 补齐本地数据库结构并执行增量迁移
../scripts/local_dev/migrate.sh

# 查看状态
docker ps | grep postgres

# 查看日志
docker logs hikiki_postgres

# 停止
docker compose -f docker-compose.local.yml down
```

### 连接信息

**本地开发**:
```
Host: localhost
Port: 5432
Database: hikiki_db
Username: postgres
Password: postgres
Connection String: postgresql://postgres:postgres@localhost:5432/hikiki_db
```

**生产环境**:
```
Host: 82.156.34.186
Port: 15432
Database: hikiki_db
Username: postgres
Password: postgres
```

---

## 📚 完整文档

详细的数据库文档请查看：

- **[数据库体系](../docs/engineering/database-system.md)** - 数据库事实源、初始化、迁移规则
- **[数据库事实源](./database/README.md)** - 当前可执行 SQL 目录说明
- **[最新结构](./database/snapshots/schema_latest.sql)** - 完整 DDL 快照

---

## 🔧 常用命令

### psql 连接
```bash
# 本地
psql -h localhost -p 5432 -U postgres -d hikiki_db

# 生产（需要 SSH 密钥）
psql -h 82.156.34.186 -p 15432 -U postgres -d hikiki_db
```

### 数据库操作
```sql
-- 查看所有表
\dt

-- 查看表结构
\d users
\d scenes

-- 查看数据统计
SELECT 
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM scenes) as scenes,
    (SELECT COUNT(*) FROM scene_categories) as categories;
```

### 备份与恢复
```bash
# 备份
pg_dump -h localhost -U postgres hikiki_db > backup.sql

# 恢复
psql -h localhost -U postgres hikiki_db < backup.sql
```

---

## ⚠️ 故障排查

### 端口冲突
如果 5432 端口被占用：
```yaml
# 修改 docker-compose.local.yml
ports:
  - "5433:5432"  # 使用其他端口
```

### 连接失败
1. 检查 Docker 是否运行：`docker ps`
2. 检查容器日志：`docker logs hikiki_postgres`
3. 验证端口：`netstat -an | grep 5432`

### 数据丢失
数据存储在 Docker volume 中：
```bash
# 查看 volumes
docker volume ls | grep hikiki

# 删除 volume（会丢失所有数据）
docker volume rm kiki_server_hikiki_pgdata
```

---

## 📖 相关文档

- [部署文档](../DEPLOY.md)
- [服务器状态报告](../docs/SERVER_STATUS_REPORT_20260613.md)
- [数据库体系](../docs/engineering/database-system.md)
