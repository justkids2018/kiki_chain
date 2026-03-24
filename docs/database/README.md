# 数据库文档

## 文件说明

| 文件 | 用途 |
|------|------|
| `init.sql` | 完整数据库初始化脚本（建表 + 初始数据） |
| `schema.md` | 数据库表结构设计文档（ER 图 + 字段说明） |
| `migrations/` | 增量迁移 SQL 文件 |

## 数据库信息

- **类型**: PostgreSQL 15
- **本地开发**: `localhost:5433`, 用户 `postgres/postgres`, 库名 `hikiki_db`
- **生产环境**: `39.102.74.171:5432`, 用户 `postgres/postgres`, 库名 `hikiki_db`

## 主要表

| 表名 | 说明 |
|------|------|
| users | 用户信息 |
| scene_categories | 场景分类 |
| scenes | 场景数据（含 JSON 互动项） |
| scene_items | 场景互动项（独立表） |
| user_learning_records | 学习记录 |
| user_favorites | 用户收藏 |

## 迁移管理

生产环境迁移使用部署脚本：

```bash
# 执行所有迁移
./scripts/deploy/deploy-db.sh

# 执行指定 SQL
./scripts/deploy/deploy-db.sh --file docs/database/migrations/xxx.sql
```
