-- 场景相关表迁移脚本
-- 执行方式: psql -U postgres -d hikiki_db -f migrations/002_scene_tables.sql

-- ============================================
-- 1. 场景分类表
-- ============================================
CREATE TABLE IF NOT EXISTS scene_categories (
  id VARCHAR(32) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(20),
  cover_image VARCHAR(500),
  description VARCHAR(200),
  display_order INT DEFAULT 0,
  is_new BOOLEAN DEFAULT FALSE,
  is_visible BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_categories_display_order ON scene_categories(display_order);
CREATE INDEX IF NOT EXISTS idx_categories_visible ON scene_categories(is_visible);

-- ============================================
-- 2. 场景表
-- ============================================
CREATE TABLE IF NOT EXISTS scenes (
  id VARCHAR(32) PRIMARY KEY,
  category_id VARCHAR(32) NOT NULL,
  name VARCHAR(50) NOT NULL,
  cover_image VARCHAR(500),
  interactive_image VARCHAR(500),
  description VARCHAR(200),
  item_count INT DEFAULT 0,
  display_order INT DEFAULT 0,
  is_new BOOLEAN DEFAULT FALSE,
  is_visible BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES scene_categories(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_scenes_category_id ON scenes(category_id);
CREATE INDEX IF NOT EXISTS idx_scenes_display_order ON scenes(display_order);
CREATE INDEX IF NOT EXISTS idx_scenes_visible ON scenes(is_visible);
CREATE INDEX IF NOT EXISTS idx_scenes_created_at ON scenes(created_at);

-- ============================================
-- 3. 场景物品表
-- ============================================
CREATE TABLE IF NOT EXISTS scene_items (
  id VARCHAR(32) PRIMARY KEY,
  scene_id VARCHAR(32) NOT NULL,
  item_type VARCHAR(20) DEFAULT 'chinese',
  item_index INT,
  text VARCHAR(50),
  text_pinyin VARCHAR(100),
  text_english VARCHAR(100),
  coordinates JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_items_scene_id ON scene_items(scene_id);
CREATE INDEX IF NOT EXISTS idx_items_index ON scene_items(item_index);

-- ============================================
-- 4. 用户学习记录表
-- ============================================
CREATE TABLE IF NOT EXISTS user_learning_records (
  id VARCHAR(32) PRIMARY KEY,
  user_id VARCHAR(32) NOT NULL,
  scene_id VARCHAR(32) NOT NULL,
  learned_items JSONB DEFAULT '[]'::jsonb,
  learned_item_count INT DEFAULT 0,
  total_study_time INT DEFAULT 0,
  last_study_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,
  UNIQUE (user_id, scene_id)
);

CREATE INDEX IF NOT EXISTS idx_learning_user_id ON user_learning_records(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_scene_id ON user_learning_records(scene_id);
CREATE INDEX IF NOT EXISTS idx_learning_last_study ON user_learning_records(last_study_at);

-- ============================================
-- 5. 用户收藏表
-- ============================================
CREATE TABLE IF NOT EXISTS user_favorites (
  id VARCHAR(32) PRIMARY KEY,
  user_id VARCHAR(32) NOT NULL,
  scene_id VARCHAR(32) NOT NULL,
  favorited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,
  UNIQUE (user_id, scene_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_scene_id ON user_favorites(scene_id);
CREATE INDEX IF NOT EXISTS idx_favorites_created ON user_favorites(favorited_at);

-- ============================================
-- 6. 示例数据
-- ============================================
INSERT INTO scene_categories (id, name, icon, cover_image, description, display_order) VALUES
('cat_001', '春节场景', '🎉', NULL, '体验中国传统春节文化', 1),
('cat_002', '24节气', '🌸', NULL, '认识24个传统节气', 2),
('cat_003', '日常生活', '🏠', NULL, '贴近生活的日常场景', 3),
('cat_004', '游乐场景', '🎢', NULL, '探索有趣的游乐世界', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO scenes (id, category_id, name, cover_image, interactive_image, description, item_count, display_order) VALUES
('scene_001', 'cat_001', '回家（春运）', NULL, NULL, '体验春运回家的场景', 15, 1),
('scene_002', 'cat_001', '除夕', NULL, NULL, '团圆的除夕夜', 18, 2),
('scene_003', 'cat_001', '初一拜年', NULL, NULL, '新年拜年', 12, 3),
('scene_004', 'cat_001', '游园（庙会）', NULL, NULL, '逛庙会', 20, 4),
('scene_005', 'cat_001', '元宵节', NULL, NULL, '元宵节赏灯', 15, 5),
('scene_101', 'cat_003', '上学', NULL, NULL, '上学路上', 15, 1),
('scene_102', 'cat_003', '吃饭', NULL, NULL, '吃饭时间', 12, 2),
('scene_103', 'cat_003', '书房一角', NULL, NULL, '学习空间', 10, 3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO scene_items (id, scene_id, item_type, item_index, text, text_pinyin, text_english, coordinates) VALUES
('item_001', 'scene_002', 'chinese', 1, '年夜饭', 'nián yè fàn', 'New Year''s Eve Dinner',
  '[{"x": 100, "y": 200}, {"x": 200, "y": 200}, {"x": 200, "y": 300}, {"x": 100, "y": 300}]'::jsonb),
('item_002', 'scene_002', 'chinese', 2, '春联', 'chūn lián', 'Spring Couplets',
  '[{"x": 300, "y": 150}, {"x": 400, "y": 150}, {"x": 400, "y": 250}, {"x": 300, "y": 250}]'::jsonb),
('item_003', 'scene_002', 'chinese', 3, '饺子', 'jiǎo zi', 'Dumplings',
  '[{"x": 150, "y": 350}, {"x": 250, "y": 350}, {"x": 250, "y": 450}, {"x": 150, "y": 450}]'::jsonb)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ 场景表迁移完成！' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
