# 数据库管理指南

## 📋 目录

- [设计原则](#设计原则)
- [数据库生命周期](#数据库生命周期)
- [迁移文件管理](#迁移文件管理)
- [部署场景](#部署场景)
- [常见操作](#常见操作)
- [故障排查](#故障排查)

---

## 🎯 设计原则

### 1. 数据库独立性
- PostgreSQL 容器独立运行，数据通过 Docker Volume 持久化
- 数据库生命周期独立于应用容器
- 即使删除应用容器，数据库数据仍然保留

### 2. 只初始化一次
- 首次部署时执行 `init.sql` 创建基础表结构
- 后续部署自动检测数据库状态，跳过初始化
- 通过检查 `users` 表是否存在来判断是否已初始化

### 3. 增量迁移
- 所有 schema 变更通过迁移文件管理
- `schema_migrations` 表跟踪已执行的迁移
- 每次部署只执行未应用的迁移

### 4. 自动备份
- 每次部署前自动备份数据库
- 备份文件保存在 `~/kiki_chain/backups/` 目录
- 备份文件名格式：`{database_name}_{timestamp}.sql.gz`

---

## 🔄 数据库生命周期

### 首次部署

```
┌─────────────────────────────────────────────────────────┐
│ 1. 启动 PostgreSQL 容器                                  │
│    - 创建 Docker Volume: postgres_data                  │
│    - 容器端口: 127.0.0.1:15432 → 5432                   │
├─────────────────────────────────────────────────────────┤
│ 2. 创建数据库                                            │
│    - 数据库名: kiki_db (或配置的名称)                    │
│    - 用户: kiki_user                                    │
│    - 状态: DB_IS_NEW=true                               │
├─────────────────────────────────────────────────────────┤
│ 3. 创建迁移跟踪表                                        │
│    - 表名: schema_migrations                            │
│    - 字段: version (主键), applied_at                   │
├─────────────────────────────────────────────────────────┤
│ 4. 执行初始化脚本                                        │
│    - 文件: scripts/deploy-release/db/init.sql          │
│    - 创建基础表: users, cards, scenes, etc.             │
│    - 插入初始数据（如果有）                              │
├─────────────────────────────────────────────────────────┤
│ 5. 执行增量迁移                                          │
│    - 目录: scripts/deploy-release/db/migrations/       │
│    - 按版本号顺序执行所有迁移文件                        │
│    - 记录到 schema_migrations 表                        │
└─────────────────────────────────────────────────────────┘
```

### 后续部署

```
┌─────────────────────────────────────────────────────────┐
│ 1. 启动 PostgreSQL 容器                                  │
│    - 使用已有的 Docker Volume                           │
│    - 数据保持不变                                        │
├─────────────────────────────────────────────────────────┤
│ 2. 备份数据库                                            │
│    - 执行 pg_dump                                       │
│    - 压缩保存到 backups/ 目录                           │
├─────────────────────────────────────────────────────────┤
│ 3. 检查数据库状态                                        │
│    - 检查 users 表是否存在                              │
│    - 存在 → 跳过 init.sql ✅                            │
│    - 不存在 → 执行 init.sql（异常情况）                 │
├─────────────────────────────────────────────────────────┤
│ 4. 执行增量迁移                                          │
│    - 查询 schema_migrations 表                          │
│    - 只执行未应用的迁移文件                              │
│    - 记录新的迁移到 schema_migrations                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 迁移文件管理

### 目录结构

```
scripts/deploy-release/db/
├── init.sql                          # 初始化脚本（只执行一次）
└── migrations/                       # 增量迁移目录
    ├── 001_add_user_profile.sql      # 迁移文件
    ├── 002_add_card_table.sql
    ├── 003_add_scene_audio.sql
    └── ...
```

### 命名规范

**格式**：`{version}_{description}.sql`

- **version**：3位数字，从 001 开始递增
- **description**：简短的英文描述，使用下划线分隔
- **扩展名**：`.sql`

**示例**：
```
001_add_user_profile.sql
002_add_card_table.sql
003_add_scene_audio.sql
010_modify_user_email.sql
```

### 迁移文件内容

**模板**：
```sql
-- Migration: {description}
-- Version: {version}
-- Date: {YYYY-MM-DD}

BEGIN;

-- 你的 SQL 语句
ALTER TABLE users ADD COLUMN profile_image VARCHAR(255);
CREATE INDEX idx_users_email ON users(email);

COMMIT;
```

**最佳实践**：
- ✅ 使用事务（BEGIN/COMMIT）
- ✅ 添加注释说明变更内容
- ✅ 使用 `IF NOT EXISTS` 避免重复创建
- ✅ 先测试再提交
- ❌ 不要修改已执行的迁移文件
- ❌ 不要在迁移中删除数据（除非确认）

---

## 🚀 部署场景

### 场景 1：正常部署（推荐）

**适用**：日常开发部署，有新的迁移文件

```bash
# 自动部署（GitHub Actions）
git push origin main

# 或手动部署
./scripts/deploy-release/step1-prepare.sh tencent
./scripts/deploy-release/step2-deploy.sh tencent
```

**执行流程**：
1. ✅ 备份数据库
2. ✅ 检查数据库状态（已初始化 → 跳过 init.sql）
3. ✅ 执行新的迁移文件
4. ✅ 重启应用容器

---

### 场景 2：跳过数据库迁移

**适用**：
- 只更新应用代码，没有数据库变更
- 数据库已经是最新状态
- 快速回滚应用版本

```bash
# 设置环境变量跳过数据库迁移
export SKIP_DB_MIGRATION=true
./scripts/deploy-release/step2-deploy.sh tencent
```

**执行流程**：
1. ⏭️ 跳过数据库迁移
2. ✅ 拉取新的应用镜像
3. ✅ 重启应用容器

---

### 场景 3：强制重新初始化（危险）

**适用**：
- 开发/测试环境重置
- 数据损坏需要重建

**⚠️ 警告**：此操作会删除所有数据！

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186

# 停止所有容器
cd ~/kiki_chain
docker compose down

# 删除数据库 Volume
docker volume rm kiki_chain_postgres_data

# 重新部署（会重新初始化）
# 在本地执行
./scripts/deploy-release/step2-deploy.sh tencent
```

---

### 场景 4：回滚数据库

**适用**：迁移失败或数据错误

```bash
# 1. SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain

# 2. 查看备份文件
ls -lh backups/
# 输出示例：
# kiki_db_20260115_120000.sql.gz
# kiki_db_20260115_150000.sql.gz

# 3. 停止应用容器（保留数据库容器）
docker compose stop backend admin

# 4. 恢复数据库
gunzip -c backups/kiki_db_20260115_120000.sql.gz | \
  docker compose exec -T postgres psql -U kiki_user -d kiki_db

# 5. 重启应用
docker compose up -d backend admin
```

---

## 🛠️ 常见操作

### 查看迁移历史

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain

# 查看已执行的迁移
docker compose exec postgres psql -U kiki_user -d kiki_db -c \
  "SELECT * FROM schema_migrations ORDER BY applied_at DESC;"
```

**输出示例**：
```
 version |         applied_at
---------+----------------------------
 003     | 2026-01-15 15:30:00+00
 002     | 2026-01-15 12:00:00+00
 001     | 2026-01-10 10:00:00+00
```

---

### 手动执行迁移

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain

# 执行单个迁移文件
cat scripts/deploy-release/db/migrations/004_add_new_feature.sql | \
  docker compose exec -T postgres psql -U kiki_user -d kiki_db

# 记录到迁移表
docker compose exec postgres psql -U kiki_user -d kiki_db -c \
  "INSERT INTO schema_migrations(version) VALUES('004');"
```

---

### 连接数据库

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain

# 进入 psql 交互式终端
docker compose exec postgres psql -U kiki_user -d kiki_db

# 或执行单条 SQL
docker compose exec postgres psql -U kiki_user -d kiki_db -c "SELECT COUNT(*) FROM users;"
```

---

### 手动备份数据库

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain

# 创建备份
docker compose exec postgres pg_dump -U kiki_user kiki_db | \
  gzip > backups/manual_backup_$(date +%Y%m%d_%H%M%S).sql.gz

# 查看备份大小
ls -lh backups/
```

---

### 清理旧备份

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186
cd ~/kiki_chain/backups

# 查看备份文件（按时间排序）
ls -lt

# 删除 30 天前的备份
find . -name "*.sql.gz" -mtime +30 -delete

# 或只保留最近 10 个备份
ls -t *.sql.gz | tail -n +11 | xargs rm -f
```

---

## 🔍 故障排查

### 问题 1：迁移执行失败

**症状**：
```
ERROR: relation "xxx" already exists
```

**原因**：迁移文件中的对象已存在

**解决方案**：
```sql
-- 使用 IF NOT EXISTS
CREATE TABLE IF NOT EXISTS users (...);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
```

---

### 问题 2：数据库连接失败

**症状**：
```
could not connect to server: Connection refused
```

**排查步骤**：
```bash
# 1. 检查容器状态
docker compose ps postgres

# 2. 检查容器日志
docker compose logs postgres

# 3. 检查端口监听
docker compose exec postgres pg_isready -h 127.0.0.1 -U kiki_user

# 4. 重启数据库容器
docker compose restart postgres
```

---

### 问题 3：迁移表损坏

**症状**：
```
ERROR: relation "schema_migrations" does not exist
```

**解决方案**：
```bash
# 重新创建迁移表
docker compose exec postgres psql -U kiki_user -d kiki_db -c \
  "CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(32) PRIMARY KEY,
    applied_at TIMESTAMPTZ DEFAULT NOW()
  );"

# 手动记录已执行的迁移（根据实际情况）
docker compose exec postgres psql -U kiki_user -d kiki_db -c \
  "INSERT INTO schema_migrations(version) VALUES('001'), ('002'), ('003');"
```

---

### 问题 4：数据库磁盘空间不足

**症状**：
```
ERROR: could not extend file: No space left on device
```

**排查步骤**：
```bash
# 1. 检查磁盘使用
df -h

# 2. 检查数据库大小
docker compose exec postgres psql -U kiki_user -d kiki_db -c \
  "SELECT pg_size_pretty(pg_database_size('kiki_db'));"

# 3. 清理旧备份
cd ~/kiki_chain/backups
ls -lh
rm old_backup_*.sql.gz

# 4. 清理 Docker 资源
docker system prune -a
```

---

## 📊 监控与维护

### 数据库大小监控

```sql
-- 查看数据库大小
SELECT pg_size_pretty(pg_database_size('kiki_db'));

-- 查看各表大小
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### 连接数监控

```sql
-- 查看当前连接数
SELECT count(*) FROM pg_stat_activity;

-- 查看各数据库连接数
SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;
```

### 慢查询监控

```sql
-- 查看慢查询（执行时间 > 1秒）
SELECT
  pid,
  now() - query_start AS duration,
  query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '1 second'
ORDER BY duration DESC;
```

---

## 🔐 安全建议

1. **定期备份**：
   - 自动备份：每次部署前自动备份
   - 手动备份：重要操作前手动备份
   - 异地备份：定期下载备份到本地

2. **访问控制**：
   - 数据库端口仅绑定到 `127.0.0.1`
   - 不对外暴露数据库端口
   - 使用强密码

3. **迁移审查**：
   - 迁移文件需要 Code Review
   - 测试环境先验证
   - 避免在迁移中删除数据

4. **监控告警**：
   - 监控数据库磁盘使用
   - 监控连接数
   - 监控慢查询

---

## 📝 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|---------|
| 2026-01-15 | 1.0.0 | 初始版本，完整的数据库管理指南 |

---

## 🔗 相关文档

- [部署架构文档](./DEPLOYMENT_ARCHITECTURE.md)
- [GitHub Actions 配置](.github/workflows/docker-release.yml)
- [部署脚本](../scripts/deploy-release/)
