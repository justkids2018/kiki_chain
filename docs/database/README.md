# 数据库文档

> **统一的数据库设计和管理文档**

**最后更新**: 2026-02-11

---

## 📋 目录结构

```
database/
├── README.md              # 本文档 - 数据库文档导航
├── schema/                # 数据库表结构
│   ├── users.md          # 用户表
│   ├── scenes.md         # 场景表
│   ├── categories.md     # 分类表
│   └── ...
├── migrations/            # 数据库迁移记录
│   └── changelog.md      # 迁移历史
└── design/                # 数据库设计文档
    ├── ER_diagram.md     # ER 图
    └── indexes.md        # 索引设计
```

---

## 📊 数据库概览

### 当前数据库

- **类型**: PostgreSQL
- **版本**: 14+
- **字符集**: UTF-8
- **时区**: UTC

### 主要表

| 表名 | 说明 | 文档 |
|------|------|------|
| users | 用户信息 | [schema/users.md](./schema/users.md) |
| scenes | 场景数据 | [schema/scenes.md](./schema/scenes.md) |
| categories | 分类信息 | [schema/categories.md](./schema/categories.md) |
| scene_items | 场景互动项 | [schema/scene_items.md](./schema/scene_items.md) |
| user_progress | 学习进度 | [schema/user_progress.md](./schema/user_progress.md) |

---

## 🔄 迁移管理

### 迁移文件位置

```
kiki_server/migrations/
```

### 查看迁移历史

参见: [migrations/changelog.md](./migrations/changelog.md)

---

## 📐 设计原则

1. **范式化**: 遵循第三范式
2. **索引优化**: 关键字段建立索引
3. **外键约束**: 保证数据一致性
4. **软删除**: 重要数据使用 `deleted_at` 标记
5. **时间戳**: 所有表包含 `created_at` 和 `updated_at`

---

## 🔍 快速查询

### 查看表结构

```sql
-- PostgreSQL
\d+ table_name

-- 或查看文档
cat docs/database/schema/table_name.md
```

### 导出 ER 图

```bash
# 使用工具导出 ER 图
# 保存到 docs/database/design/ER_diagram.md
```

---

## 📝 维护规则

| 操作 | 负责人 | 文档更新 |
|------|--------|----------|
| 新增表 | AI | 创建 schema/xxx.md |
| 修改表结构 | AI | 更新对应 schema 文档 |
| 数据迁移 | AI | 记录到 migrations/changelog.md |
| 索引优化 | AI | 更新 design/indexes.md |

---

**维护者**: AI (Claude) + 后端开发
