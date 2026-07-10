-- Migration 008: 支持一张学习卡片关联多个主题
-- 保留 scenes.category_id 作为主主题，新增关联表表达多主题归属。

CREATE TABLE IF NOT EXISTS scene_category_relations (
  scene_id VARCHAR(32) NOT NULL,
  category_id VARCHAR(32) NOT NULL,
  display_order INT DEFAULT 0,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (scene_id, category_id),
  FOREIGN KEY (scene_id) REFERENCES scenes(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES scene_categories(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_scene_category_relations_category
  ON scene_category_relations(category_id, display_order);

CREATE INDEX IF NOT EXISTS idx_scene_category_relations_scene
  ON scene_category_relations(scene_id);

INSERT INTO scene_category_relations (
  scene_id,
  category_id,
  display_order,
  is_primary,
  created_at,
  updated_at
)
SELECT
  id,
  category_id,
  display_order,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM scenes
WHERE category_id IS NOT NULL
ON CONFLICT (scene_id, category_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  is_primary = TRUE,
  updated_at = CURRENT_TIMESTAMP;

SELECT '✅ Migration 008 完成：学习卡片支持多主题关联' as status;
