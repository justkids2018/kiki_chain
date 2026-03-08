# Hi Kiki - PostgreSQL 数据库设计

> 版本：v1.0 | 日期：2026-01-18 | 数据库：PostgreSQL 14+

---

## 数据库架构图

```
┌─────────────────┐
│     users       │  用户表
└────────┬────────┘
         │
         ├─────────────────────────┐
         │                         │
┌────────▼────────┐       ┌───────▼──────────┐
│ user_learning_  │       │  user_favorites  │
│   records       │       └──────────────────┘
└─────────────────┘
         │
         │
┌────────▼────────┐       ┌──────────────────┐
│     scenes      │◄──────┤ scene_categories │
└────────┬────────┘       └──────────────────┘
         │
         │
┌────────▼────────┐
│  scene_items    │
└─────────────────┘
```

---

## 1. 用户表（users）

```sql
CREATE TABLE users (
  id VARCHAR(32) PRIMARY KEY,                          -- 用户ID (usr_xxx)
  phone VARCHAR(20) NOT NULL UNIQUE,                   -- 手机号（唯一）
  password_hash VARCHAR(255) NOT NULL,                 -- 密码哈希（bcrypt）
  nickname VARCHAR(50) NOT NULL,                       -- 昵称
  avatar VARCHAR(500),                                 -- 头像URL
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,                             -- 最后登录时间
  login_fail_count INT DEFAULT 0,                      -- 登录失败次数
  locked_until TIMESTAMP,                              -- 账号锁定时间（防暴力破解）
  is_deleted BOOLEAN DEFAULT FALSE,                    -- 软删除标记

  -- 索引
  INDEX idx_phone (phone),
  INDEX idx_created_at (created_at)
);

-- 插入示例数据
INSERT INTO users (id, phone, password_hash, nickname) VALUES
('usr_001', '13800138000', '$2b$10$...', '小明'),
('usr_002', '13900139000', '$2b$10$...', '小红');
```

---

## 2. 一级分类表（scene_categories）

```sql
CREATE TABLE scene_categories (
  id VARCHAR(32) PRIMARY KEY,                          -- 分类ID (cat_xxx)
  name VARCHAR(50) NOT NULL,                           -- 分类名（如"春节场景"）
  icon VARCHAR(20),                                    -- 图标emoji
  cover_image VARCHAR(500),                            -- 分类封面图URL
  description VARCHAR(200),                            -- 描述
  display_order INT DEFAULT 0,                         -- 排序权重（越小越靠前）
  is_new BOOLEAN DEFAULT FALSE,                        -- 是否新分类
  is_visible BOOLEAN DEFAULT TRUE,                     -- 是否可见
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 索引
  INDEX idx_display_order (display_order),
  INDEX idx_is_visible (is_visible)
);

-- 插入示例数据
INSERT INTO scene_categories (id, name, icon, cover_image, description, display_order) VALUES
('cat_001', '春节场景', '🎉', 'https://cdn.example.com/categories/spring_festival.jpg', '体验中国传统春节文化', 1),
('cat_002', '24节气', '🌸', 'https://cdn.example.com/categories/solar_terms.jpg', '认识24个传统节气', 2),
('cat_003', '日常生活', '🏠', 'https://cdn.example.com/categories/daily_life.jpg', '贴近生活的日常场景', 3),
('cat_004', '游乐场景', '🎢', 'https://cdn.example.com/categories/amusement.jpg', '探索有趣的游乐世界', 4);
```

---

## 3. 二级场景表（scenes）

```sql
CREATE TABLE scenes (
  id VARCHAR(32) PRIMARY KEY,                          -- 场景ID (scene_xxx)
  category_id VARCHAR(32) NOT NULL,                    -- 所属分类ID
  name VARCHAR(50) NOT NULL,                           -- 场景名（如"除夕"）
  cover_image VARCHAR(500),                            -- 场景封面图URL
  interactive_image VARCHAR(500),                      -- 互动大图URL
  description VARCHAR(200),                            -- 描述
  item_count INT DEFAULT 0,                            -- 物品数量
  display_order INT DEFAULT 0,                         -- 排序权重
  is_new BOOLEAN DEFAULT FALSE,                        -- 是否新场景
  is_visible BOOLEAN DEFAULT TRUE,                     -- 是否可见
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 外键
  FOREIGN KEY (category_id) REFERENCES scene_categories(id) ON DELETE CASCADE,

  -- 索引
  INDEX idx_category_id (category_id),
  INDEX idx_display_order (display_order),
  INDEX idx_is_visible (is_visible),
  INDEX idx_created_at (created_at)
);

-- 插入示例数据（春节场景）
INSERT INTO scenes (id, category_id, name, cover_image, interactive_image, description, item_count, display_order) VALUES
('scene_001', 'cat_001', '回家（春运）', 'https://cdn.example.com/scenes/go_home_cover.jpg', 'https://cdn.example.com/scenes/go_home_main.jpg', '体验春运回家的场景', 15, 1),
('scene_002', 'cat_001', '除夕', 'https://cdn.example.com/scenes/new_year_eve_cover.jpg', 'https://cdn.example.com/scenes/new_year_eve_main.jpg', '团圆的除夕夜', 18, 2),
('scene_003', 'cat_001', '初一拜年', 'https://cdn.example.com/scenes/new_year_visit_cover.jpg', 'https://cdn.example.com/scenes/new_year_visit_main.jpg', '新年拜年', 12, 3),
('scene_004', 'cat_001', '游园（庙会）', 'https://cdn.example.com/scenes/temple_fair_cover.jpg', 'https://cdn.example.com/scenes/temple_fair_main.jpg', '逛庙会', 20, 4),
('scene_005', 'cat_001', '元宵节', 'https://cdn.example.com/scenes/lantern_cover.jpg', 'https://cdn.example.com/scenes/lantern_main.jpg', '元宵节赏灯', 15, 5);

-- 插入日常生活场景
INSERT INTO scenes (id, category_id, name, cover_image, interactive_image, description, item_count, display_order) VALUES
('scene_101', 'cat_003', '上学', 'https://cdn.example.com/scenes/go_to_school_cover.jpg', 'https://cdn.example.com/scenes/go_to_school_main.jpg', '上学路上', 15, 1),
('scene_102', 'cat_003', '吃饭', 'https://cdn.example.com/scenes/dining_cover.jpg', 'https://cdn.example.com/scenes/dining_main.jpg', '吃饭时间', 12, 2),
('scene_103', 'cat_003', '书房一角', 'https://cdn.example.com/scenes/study_room_cover.jpg', 'https://cdn.example.com/scenes/study_room_main.jpg', '学习空间', 10, 3);
```

---

## 4. 场景物品表（scene_items）

```sql
CREATE TABLE scene_items (
  id VARCHAR(32) PRIMARY KEY,                          -- 物品ID (item_xxx)
  scene_id VARCHAR(32) NOT NULL,                       -- 所属场景ID
  item_type VARCHAR(20) DEFAULT 'chinese',             -- 物品类型
  item_index INT,                                      -- 物品序号
  text VARCHAR(50),                                    -- 中文文本
  text_pinyin VARCHAR(100),                            -- 拼音
  text_english VARCHAR(100),                           -- 英文翻译
  coordinates JSONB,                                   -- 热区坐标（JSONB类型）
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- 外键
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,

  -- 索引
  INDEX idx_scene_id (scene_id),
  INDEX idx_item_index (item_index)
);

-- 插入示例数据（除夕场景的物品）
INSERT INTO scene_items (id, scene_id, item_type, item_index, text, text_pinyin, text_english, coordinates) VALUES
('item_001', 'scene_002', 'chinese', 1, '年夜饭', 'nián yè fàn', 'New Year''s Eve Dinner',
  '[{"x": 100, "y": 200}, {"x": 200, "y": 200}, {"x": 200, "y": 300}, {"x": 100, "y": 300}]'::jsonb),
('item_002', 'scene_002', 'chinese', 2, '春联', 'chūn lián', 'Spring Couplets',
  '[{"x": 300, "y": 150}, {"x": 400, "y": 150}, {"x": 400, "y": 250}, {"x": 300, "y": 250}]'::jsonb),
('item_003', 'scene_002', 'chinese', 3, '饺子', 'jiǎo zi', 'Dumplings',
  '[{"x": 150, "y": 350}, {"x": 250, "y": 350}, {"x": 250, "y": 450}, {"x": 150, "y": 450}]'::jsonb);

-- 查询物品坐标示例
-- SELECT id, text, coordinates->0->>'x' as x1, coordinates->0->>'y' as y1 FROM scene_items;
```

---

## 5. 用户学习记录表（user_learning_records）

```sql
CREATE TABLE user_learning_records (
  id VARCHAR(32) PRIMARY KEY,                          -- 记录ID (ulr_xxx)
  user_id VARCHAR(32) NOT NULL,                        -- 用户ID
  scene_id VARCHAR(32) NOT NULL,                       -- 场景ID
  learned_items JSONB DEFAULT '[]'::jsonb,             -- 已学习物品ID数组
  learned_item_count INT DEFAULT 0,                    -- 已学习物品数（冗余字段，便于查询）
  total_study_time INT DEFAULT 0,                      -- 总学习时长（秒）
  last_study_at TIMESTAMP,                             -- 最后学习时间
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 外键
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,

  -- 唯一约束（一个用户一个场景只有一条记录）
  UNIQUE (user_id, scene_id),

  -- 索引
  INDEX idx_user_id (user_id),
  INDEX idx_scene_id (scene_id),
  INDEX idx_last_study_at (last_study_at)
);

-- 插入示例数据
INSERT INTO user_learning_records (id, user_id, scene_id, learned_items, learned_item_count, total_study_time, last_study_at) VALUES
('ulr_001', 'usr_001', 'scene_002', '["item_001", "item_002", "item_003"]'::jsonb, 3, 600, '2026-01-18 10:00:00'),
('ulr_002', 'usr_001', 'scene_101', '["item_101", "item_102"]'::jsonb, 2, 300, '2026-01-17 14:00:00');

-- 查询学习进度
-- SELECT
--   ulr.scene_id,
--   s.name as scene_name,
--   ulr.learned_item_count,
--   s.item_count as total_items,
--   ROUND(ulr.learned_item_count::numeric / s.item_count, 2) as progress
-- FROM user_learning_records ulr
-- JOIN scenes s ON ulr.scene_id = s.id
-- WHERE ulr.user_id = 'usr_001';
```

---

## 6. 用户收藏表（user_favorites）

```sql
CREATE TABLE user_favorites (
  id VARCHAR(32) PRIMARY KEY,                          -- 收藏ID (ufv_xxx)
  user_id VARCHAR(32) NOT NULL,                        -- 用户ID
  scene_id VARCHAR(32) NOT NULL,                       -- 场景ID
  favorited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- 外键
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,

  -- 唯一约束
  UNIQUE (user_id, scene_id),

  -- 索引
  INDEX idx_user_id (user_id),
  INDEX idx_scene_id (scene_id),
  INDEX idx_favorited_at (favorited_at)
);

-- 插入示例数据
INSERT INTO user_favorites (id, user_id, scene_id, favorited_at) VALUES
('ufv_001', 'usr_001', 'scene_002', '2026-01-16 10:00:00'),
('ufv_002', 'usr_001', 'scene_101', '2026-01-15 14:00:00');
```

---

## 7. 学习日历视图（用于统计）

```sql
-- 创建视图：每日学习统计
CREATE VIEW user_daily_study_stats AS
SELECT
  user_id,
  DATE(last_study_at) as study_date,
  COUNT(DISTINCT scene_id) as scenes_count,
  SUM(total_study_time) as total_time
FROM user_learning_records
WHERE last_study_at IS NOT NULL
GROUP BY user_id, DATE(last_study_at);

-- 查询某用户的学习日历
-- SELECT * FROM user_daily_study_stats WHERE user_id = 'usr_001' ORDER BY study_date DESC;
```

---

## 8. 常用查询SQL

### 8.1 获取一级分类及其场景数量
```sql
SELECT
  c.id,
  c.name,
  c.icon,
  COUNT(s.id) as scene_count,
  SUM(s.item_count) as total_item_count
FROM scene_categories c
LEFT JOIN scenes s ON c.id = s.category_id AND s.is_visible = TRUE
WHERE c.is_visible = TRUE
GROUP BY c.id
ORDER BY c.display_order;
```

### 8.2 获取某分类下的场景及用户进度
```sql
SELECT
  s.id,
  s.name,
  s.cover_image,
  s.item_count,
  ulr.learned_item_count,
  COALESCE(ROUND(ulr.learned_item_count::numeric / s.item_count, 2), 0) as progress,
  CASE
    WHEN ulr.learned_item_count >= s.item_count * 0.9 THEN 3
    WHEN ulr.learned_item_count >= s.item_count * 0.6 THEN 2
    WHEN ulr.learned_item_count >= s.item_count * 0.3 THEN 1
    ELSE 0
  END as star_count,
  EXISTS(SELECT 1 FROM user_favorites WHERE user_id = 'usr_001' AND scene_id = s.id) as is_favorited
FROM scenes s
LEFT JOIN user_learning_records ulr ON s.id = ulr.scene_id AND ulr.user_id = 'usr_001'
WHERE s.category_id = 'cat_001' AND s.is_visible = TRUE
ORDER BY s.display_order;
```

### 8.3 批量获取用户进度（重要！）
```sql
-- 用于 GET /user/learning-progress?sceneIds=scene_001,scene_002
SELECT
  ulr.scene_id,
  ulr.learned_item_count,
  s.item_count as total_items,
  ROUND(ulr.learned_item_count::numeric / s.item_count, 2) as progress,
  CASE
    WHEN ulr.learned_item_count >= s.item_count * 0.9 THEN 3
    WHEN ulr.learned_item_count >= s.item_count * 0.6 THEN 2
    WHEN ulr.learned_item_count >= s.item_count * 0.3 THEN 1
    ELSE 0
  END as star_count,
  EXISTS(SELECT 1 FROM user_favorites WHERE user_id = 'usr_001' AND scene_id = ulr.scene_id) as is_favorited
FROM user_learning_records ulr
JOIN scenes s ON ulr.scene_id = s.id
WHERE ulr.user_id = 'usr_001'
  AND ulr.scene_id IN ('scene_001', 'scene_002', 'scene_003');
```

### 8.4 更新学习记录（增量更新）
```sql
-- 用于 POST /user/learning-records
INSERT INTO user_learning_records (id, user_id, scene_id, learned_items, learned_item_count, total_study_time, last_study_at)
VALUES (
  'ulr_003',
  'usr_001',
  'scene_003',
  '["item_301", "item_302"]'::jsonb,
  2,
  120,
  CURRENT_TIMESTAMP
)
ON CONFLICT (user_id, scene_id)
DO UPDATE SET
  learned_items = user_learning_records.learned_items || EXCLUDED.learned_items,  -- 合并数组
  learned_item_count = (SELECT COUNT(DISTINCT elem) FROM jsonb_array_elements_text(user_learning_records.learned_items || EXCLUDED.learned_items) elem),
  total_study_time = user_learning_records.total_study_time + EXCLUDED.total_study_time,
  last_study_at = EXCLUDED.last_study_at,
  updated_at = CURRENT_TIMESTAMP;
```

---

## 9. 性能优化建议

### 9.1 索引优化
```sql
-- 为高频查询字段添加复合索引
CREATE INDEX idx_scenes_category_visible ON scenes(category_id, is_visible, display_order);
CREATE INDEX idx_learning_records_user_scene ON user_learning_records(user_id, scene_id);
```

### 9.2 分区表（场景数据量大时）
```sql
-- 按分类ID分区（如果场景数量超过10000）
CREATE TABLE scenes_partitioned (
  -- 同 scenes 表结构
) PARTITION BY LIST (category_id);

CREATE TABLE scenes_cat_001 PARTITION OF scenes_partitioned FOR VALUES IN ('cat_001');
CREATE TABLE scenes_cat_002 PARTITION OF scenes_partitioned FOR VALUES IN ('cat_002');
```

---

## 10. 数据备份与恢复

### 备份
```bash
# 备份整个数据库
pg_dump -U postgres -d hikiki_db > backup_$(date +%Y%m%d).sql

# 仅备份结构
pg_dump -U postgres -d hikiki_db --schema-only > schema.sql

# 仅备份数据
pg_dump -U postgres -d hikiki_db --data-only > data.sql
```

### 恢复
```bash
# 恢复数据库
psql -U postgres -d hikiki_db < backup_20260118.sql
```

---

## 完整建表脚本

保存为 `init.sql`，可直接执行：

```bash
psql -U postgres -d hikiki_db -f doc/database/init.sql
```

---

**数据库设计完成！** 现在前后端都有完整的文档可以参考了。
