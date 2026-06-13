# Hi Kiki 数据库文档索引

> **文档位置**: `docs/database/`  
> **最后更新**: 2026-06-13

---

## 📚 文档结构

```
docs/database/
├── README.md                  # 主文档（数据库概览、表结构、连接信息）
├── schema_latest.sql          # 最新完整数据库结构（自动生成）
├── init.sql                   # 初始化脚本（建表+种子数据）
├── .gitignore                 # Git 忽略规则
├── migrations/                # 数据库迁移文件
│   └── add_items_data_to_scenes.sql
├── remote-sync/               # 生产环境备份（不提交到 Git）
│   └── hikiki_db_YYYYMMDD_HHMMSS.sql
└── archive/                   # 归档的旧文档
    └── schema_old.md
```

---

## 🔍 快速导航

### 核心文档
- **[README.md](./README.md)** - 从这里开始！包含：
  - 数据库连接信息
  - 表结构说明
  - 常用查询
  - 迁移管理

### 技术文档
- **[schema_latest.sql](./schema_latest.sql)** - 完整的 PostgreSQL DDL
  - 所有表定义
  - 索引和约束
  - 外键关系
  - 自动生成，请勿手动编辑

- **[init.sql](./init.sql)** - 数据库初始化
  - 建表语句
  - 初始分类数据
  - 初始场景数据

### 迁移文件
位于 `migrations/` 目录，按编号顺序执行：

1. `001_add_role_support.sql` - 用户角色
2. `002_scene_tables.sql` - 场景表
3. `003_scenes_add_columns.sql` - 场景扩展
4. `004_feedback_tables.sql` - 反馈功能
5. `005_fix_user_roles.sql` - 角色修复

---

## 🎯 常见任务

### 查看数据库结构
```bash
# 在线查看
psql -h 82.156.34.186 -p 15432 -U postgres -d hikiki_db

# 导出最新结构
docker exec kiki_chain-postgres-1 pg_dump -U postgres -d hikiki_db --schema-only > schema_latest.sql
```

### 执行迁移
```bash
# 生产环境
ssh -i ~/.ssh/kiki_tencent_deploy ubuntu@82.156.34.186
docker exec kiki_chain-postgres-1 psql -U postgres -d hikiki_db -f /path/to/migration.sql

# 本地
psql -U postgres -d hikiki_db -f migrations/xxx.sql
```

### 备份数据库
```bash
# 完整备份
docker exec kiki_chain-postgres-1 pg_dump -U postgres -d hikiki_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 仅数据
docker exec kiki_chain-postgres-1 pg_dump -U postgres -d hikiki_db --data-only > data_backup.sql
```

---

## 📊 数据库信息

### 生产环境
- **服务器**: 82.156.34.186:15432
- **数据库**: hikiki_db
- **版本**: PostgreSQL 15.14
- **表数量**: 11 张
- **用户数**: 5
- **场景数**: 24 (4个分类)

### 核心表
| 表名 | 记录数 | 说明 |
|------|--------|------|
| users | 5 | 用户 |
| scene_categories | 4 | 分类 |
| scenes | 24 | 场景 |
| user_score_summary | - | 积分统计 |

---

## 🔗 相关文档

- [服务器状态报告](../SERVER_STATUS_REPORT_20260613.md)
- [部署文档](../../DEPLOY.md)
- [API 文档](../api/)

---

## ⚠️ 重要说明

1. **不要手动编辑 `schema_latest.sql`**  
   这个文件是从生产数据库自动导出的，任何手动修改都会在下次导出时丢失。

2. **所有结构变更必须通过迁移文件**  
   在 `migrations/` 目录创建新的 SQL 文件，按编号命名。

3. **生产数据库备份不提交到 Git**  
   `remote-sync/` 目录下的 `.sql` 文件已添加到 `.gitignore`。

4. **两个生产数据库**  
   - 端口 5432: 旧版 (edadb, 用户 qisd)
   - 端口 15432: 新版 (hikiki_db, 用户 postgres) ✅ 推荐

---

## 📝 维护清单

### 定期任务
- [ ] 每周备份生产数据库到 `remote-sync/`
- [ ] 每月检查并清理归档目录
- [ ] 每季度优化数据库性能（VACUUM, ANALYZE）

### 文档更新
- [ ] 数据库结构变更后更新 `README.md`
- [ ] 重大变更后导出新的 `schema_latest.sql`
- [ ] 迁移文件需要在 README 中记录

---

## 🆘 问题排查

### 连接失败
1. 检查 IP 和端口是否正确
2. 检查防火墙规则
3. 验证用户名密码

### 迁移失败
1. 检查迁移文件 SQL 语法
2. 查看 PostgreSQL 日志
3. 确认依赖的表或字段是否存在

### 性能问题
1. 检查是否缺少索引
2. 使用 EXPLAIN ANALYZE 分析查询
3. 考虑增加缓存或优化查询

---

**维护者**: 开发团队  
**联系方式**: GitHub Issues
