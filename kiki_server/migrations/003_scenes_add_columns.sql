-- Migration 003: scenes 表添加 items_data, name_en, context 列
-- 幂等执行，列已存在时自动跳过

ALTER TABLE scenes ADD COLUMN IF NOT EXISTS items_data jsonb DEFAULT '[]'::jsonb;
ALTER TABLE scenes ADD COLUMN IF NOT EXISTS name_en varchar(100);
ALTER TABLE scenes ADD COLUMN IF NOT EXISTS context text;

SELECT '✅ Migration 003 完成：scenes 列更新' as status;
