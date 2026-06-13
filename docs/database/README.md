# Hi Kiki 数据库文档

> **最后更新**: 2026-06-13  
> **数据库版本**: PostgreSQL 15.14  
> **生成自**: 生产环境 (82.156.34.186)

---

## 📋 数据库连接信息

### 生产环境（腾讯云）
```
Host: 82.156.34.186
Port: 15432
Database: hikiki_db
Username: postgres
Password: postgres
```

### 本地开发
```
Host: localhost
Port: 5432 (或 Docker 映射端口)
Database: hikiki_db
Username: postgres
Password: postgres
```

---

## 📊 数据库概览

| 表名 | 字段数 | 说明 | 状态 |
|------|--------|------|------|
| **users** | 13 | 用户信息（手机号登录） | ✅ 使用中 |
| **scene_categories** | 10 | 场景分类（校园、思维、日常、游戏） | ✅ 使用中 |
| **scenes** | 15 | 场景详情（含互动数据 JSON） | ✅ 使用中 |
| **scene_items** | 9 | 场景互动项（独立表，当前未使用） | ⚠️ 空表 |
| **user_learning_records** | 9 | 用户学习记录 | ⚠️ 空表 |
| **user_scene_progress** | 14 | 场景学习进度 | ✅ 使用中 |
| **user_favorites** | 4 | 用户收藏 | ✅ 使用中 |
| **user_feedback** | 9 | 用户反馈 | ✅ 使用中 |
| **user_score_summary** | 8 | 用户积分统计 | ✅ 使用中 |
| **learning_detail_logs** | 8 | 学习详情日志 | ✅ 使用中 |
| **schema_migrations** | 2 | 数据库迁移记录 | ✅ 系统表 |

**总计**: 11 张表

---

## 🔑 核心表结构

### 1. users - 用户表
存储用户基本信息和登录凭证。

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | VARCHAR(255) | 用户ID | PRIMARY KEY |
| phone | VARCHAR(20) | 手机号 | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | 密码哈希 | NOT NULL |
| nickname | VARCHAR(50) | 昵称 | NOT NULL |
| avatar | VARCHAR(500) | 头像URL | - |
| created_at | TIMESTAMP | 注册时间 | NOT NULL, DEFAULT NOW |
| last_login_at | TIMESTAMP | 最后登录时间 | - |
| login_fail_count | INTEGER | 登录失败次数 | DEFAULT 0 |
| locked_until | TIMESTAMP | 账号锁定至 | - |
| is_deleted | BOOLEAN | 是否删除 | DEFAULT false |
| role_type | INTEGER | 角色类型 | - |
| is_vip | BOOLEAN | 是否VIP | DEFAULT false |
| vip_expire_at | TIMESTAMP | VIP过期时间 | - |

**索引**:
- `users_pkey`: PRIMARY KEY (id)
- `users_phone_key`: UNIQUE (phone)
- `idx_users_phone`: btree (phone)
- `idx_users_created_at`: btree (created_at)

---

### 2. scene_categories - 场景分类
场景的一级分类。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | VARCHAR(32) | 分类ID |
| name | VARCHAR(50) | 分类名称（中文） |
| name_en | VARCHAR(50) | 分类名称（英文） |
| icon | VARCHAR(50) | 图标（emoji或文字） |
| cover_image | VARCHAR(500) | 封面图URL |
| description | VARCHAR(200) | 分类描述 |
| order | INTEGER | 显示顺序 |
| is_new | BOOLEAN | 是否新分类 |
| is_visible | BOOLEAN | 是否可见 |
| created_at | TIMESTAMP | 创建时间 |

**当前分类**:
- `cat_fdb7d74766a8`: 校园生活 (6个场景)
- `cat_002`: 思维学习 (6个场景)
- `cat_003`: 日常生活 (6个场景)
- `cat_004`: 游戏乐园 (6个场景)

---

### 3. scenes - 场景表
场景详细信息，包含互动点位数据。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | VARCHAR(32) | 场景ID |
| category_id | VARCHAR(32) | 所属分类ID |
| name | VARCHAR(50) | 场景名称 |
| cover_image | VARCHAR(500) | 封面图URL |
| interactive_image | VARCHAR(500) | 互动图URL |
| description | VARCHAR(200) | 场景描述 |
| item_count | INTEGER | 互动点数量 |
| display_order | INTEGER | 显示顺序 |
| is_new | BOOLEAN | 是否新场景 |
| is_visible | BOOLEAN | 是否可见 |
| created_at | TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | 更新时间 |
| items_data | JSONB | 互动点数据（JSON数组） |
| name_en | VARCHAR(100) | 场景名称（英文） |
| context | TEXT | 场景上下文 |

**items_data 结构**:
```json
[
  {
    "id": "item_001",
    "type": "chinese",
    "text": "黑板",
    "text_pinyin": "hēi bǎn",
    "text_english": "blackboard",
    "coordinates": {"x": 100, "y": 200}
  }
]
```

**外键**:
- `category_id` → `scene_categories(id)` ON DELETE CASCADE

---

### 4. user_learning_records - 学习记录
用户学习场景的记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGSERIAL | 记录ID |
| user_id | VARCHAR(64) | 用户ID |
| scene_id | VARCHAR(128) | 场景ID |
| completed_at | TIMESTAMP | 完成时间 |
| score | INTEGER | 得分 |
| stars_earned | INTEGER | 获得星星数 |
| time_spent_seconds | INTEGER | 学习时长（秒） |
| correct_count | INTEGER | 正确次数 |
| incorrect_count | INTEGER | 错误次数 |

**外键**:
- `user_id` → `users(id)` ON DELETE CASCADE
- `scene_id` → `scenes(id)` ON DELETE CASCADE

---

### 5. user_scene_progress - 场景进度
用户在每个场景的详细进度。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGSERIAL | 进度ID |
| user_id | VARCHAR(64) | 用户ID |
| scene_id | VARCHAR(128) | 场景ID |
| progress | INTEGER | 进度百分比 (0-100) |
| last_learned_at | TIMESTAMP | 最后学习时间 |
| total_time_spent | INTEGER | 累计时长（秒） |
| learned_items | JSONB | 已学习的项目ID列表 |
| total_stars | INTEGER | 累计星星 |
| best_score | INTEGER | 最高分数 |
| total_attempts | INTEGER | 尝试次数 |
| completed_count | INTEGER | 完成次数 |
| created_at | TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | 更新时间 |
| last_position | JSONB | 最后位置信息 |

---

### 6. user_favorites - 用户收藏
用户收藏的场景。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGSERIAL | 收藏ID |
| user_id | VARCHAR(64) | 用户ID |
| scene_id | VARCHAR(128) | 场景ID |
| created_at | TIMESTAMP | 收藏时间 |

**外键**:
- `user_id` → `users(id)` ON DELETE CASCADE
- `scene_id` → `scenes(id)` ON DELETE CASCADE

---

### 7. user_feedback - 用户反馈
用户提交的反馈信息。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGSERIAL | 反馈ID |
| user_id | VARCHAR(64) | 用户ID |
| feedback_type | VARCHAR(20) | 反馈类型 |
| content | TEXT | 反馈内容 |
| contact | VARCHAR(100) | 联���方式 |
| images | JSONB | 图片URL数组 |
| status | VARCHAR(20) | 处理状态 |
| admin_reply | TEXT | 管理员回复 |
| created_at | TIMESTAMP | 创建时间 |

---

### 8. user_score_summary - 积分统计
用户积分和星星统计。

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | VARCHAR(64) | 用户ID (PRIMARY KEY) |
| total_stars | INTEGER | 总星星数 |
| total_score | INTEGER | 总积分 |
| completed_scenes | INTEGER | 完成场景数 |
| total_learning_time | INTEGER | 总学习时长（秒） |
| last_updated_at | TIMESTAMP | 最后更新时间 |
| streak_days | INTEGER | 连续学习天数 |
| last_learn_date | DATE | 最后学习日期 |

---

## 🔄 数据库迁移

### 迁移文件列表

| 文件 | 说明 | 状态 |
|------|------|------|
| `001_add_role_support.sql` | 添加用户角色支持 | ✅ 已应用 |
| `002_scene_tables.sql` | 创建场景相关表 | ✅ 已应用 |
| `003_scenes_add_columns.sql` | 场景表添加字段 | ✅ 已应用 |
| `004_feedback_tables.sql` | 创建反馈表 | ✅ 已应用 |
| `005_fix_user_roles.sql` | 修复用户角色 | ✅ 已应用 |

### 执行迁移

**生产环境**:
```bash
# 通过 SSH 执行
ssh -i ~/.ssh/kiki_tencent_deploy ubuntu@82.156.34.186
docker exec kiki_chain-postgres-1 psql -U postgres -d hikiki_db -f /path/to/migration.sql
```

**本地开发**:
```bash
psql -U postgres -d hikiki_db -f migrations/xxx.sql
```

---

## 📁 文件说明

| 文件/目录 | 说明 |
|----------|------|
| `README.md` | 本文档 |
| `schema_latest.sql` | 最新的完整数据库结构（自动生成） |
| `init.sql` | 数据库初始化脚本（建表+初始数据） |
| `migrations/` | 增量迁移SQL文件 |
| `remote-sync/` | 生产环境数据库备份 |
| `archive/` | 归档的旧文档 |

---

## 🚀 快速操作

### 连接数据库
```bash
# pgAdmin
Host: 82.156.34.186
Port: 15432
Database: hikiki_db
Username: postgres
Password: postgres

# psql 命令行
psql -h 82.156.34.186 -p 15432 -U postgres -d hikiki_db
```

### 常用查询
```sql
-- 查看所有表
\dt

-- 查看表结构
\d users

-- 查看用户数量
SELECT COUNT(*) FROM users;

-- 查看场景分类和数量
SELECT 
    c.name, 
    COUNT(s.id) as scene_count 
FROM scene_categories c 
LEFT JOIN scenes s ON c.id = s.category_id 
GROUP BY c.id, c.name 
ORDER BY c."order";

-- 查看用户学习统计
SELECT 
    u.nickname,
    s.total_stars,
    s.completed_scenes,
    s.total_learning_time
FROM users u
LEFT JOIN user_score_summary s ON u.id = s.user_id
ORDER BY s.total_stars DESC;
```

---

## 📌 注意事项

1. **生产数据库**: 现在有两个端口
   - 端口 5432: 旧版本数据库 (edadb)
   - 端口 15432: 新版本数据库 (hikiki_db) - **推荐使用**

2. **备份**: 定期备份数据库到 `remote-sync/` 目录

3. **迁移**: 所有数据库结构变更必须通过迁移文件管理

4. **性能**: 已创建必要的索引，大表查询注意使用索引字段

---

## 📝 更新日志

### 2026-06-13
- ✅ 导出最新生产环境数据库结构
- ✅ 更新连接信息（新增端口 15432）
- ✅ 整理文档结构
- ✅ 添加表统计信息

### 2026-05-27
- ✅ 添加用户反馈表
- ✅ 修复用户角色字段

### 2026-01-30
- ✅ 初始化数据库结构
- ✅ 创建核心表
