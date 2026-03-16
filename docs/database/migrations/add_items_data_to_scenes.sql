-- 添加 items_data 字段到 scenes 表
-- 用于存储场景物品的 JSON 数据，替代 scene_items 表

-- 1. 添加 items_data 字段（JSONB 类型，支持索引和查询）
ALTER TABLE scenes ADD COLUMN IF NOT EXISTS items_data JSONB DEFAULT '[]'::jsonb;

-- 2. 添加注释
COMMENT ON COLUMN scenes.items_data IS '场景物品数据（JSON 数组），包含 type, id, index, text, text_pinyin, text_english, coordinate';

-- 3. 可选：如果需要对 items_data 进行查询，可以添加 GIN 索引
-- CREATE INDEX IF NOT EXISTS idx_scenes_items_data ON scenes USING GIN (items_data);

-- 4. 更新现有数据（如果 scene_items 表有数据，可以迁移）
-- 这里暂时不执行迁移，保留 scene_items 表以防需要

-- 注意：scene_items 表暂时保留，不删除
-- 如果确认不再需要，可以执行：DROP TABLE scene_items;
