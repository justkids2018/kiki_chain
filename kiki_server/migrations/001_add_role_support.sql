-- 添加角色支持的数据库迁移
-- 执行方式: psql -U postgres -d hikiki_db -f migrations/001_add_role_support.sql

-- ============================================
-- 1. 确保 role_id 列存在
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'users' AND column_name = 'role_id'
    ) THEN
        ALTER TABLE users ADD COLUMN role_id INTEGER NOT NULL DEFAULT 1;
        RAISE NOTICE '✅ 已添加 role_id 列';
    ELSE
        RAISE NOTICE 'ℹ️  role_id 列已存在';
    END IF;
END $$;

-- ============================================
-- 2. 添加索引以提升角色查询性能
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- ============================================
-- 3. 添加约束确保角色值有效
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'chk_users_role_id'
    ) THEN
        ALTER TABLE users
        ADD CONSTRAINT chk_users_role_id CHECK (role_id IN (1, 2));
        RAISE NOTICE '✅ 已添加角色约束';
    ELSE
        RAISE NOTICE 'ℹ️  角色约束已存在';
    END IF;
END $$;

-- ============================================
-- 4. 更新现有用户的角色（如果为 NULL 或 0）
-- ============================================
UPDATE users
SET role_id = 1
WHERE role_id IS NULL OR role_id = 0 OR role_id NOT IN (1, 2);

-- ============================================
-- 5. 验证迁移结果
-- ============================================
SELECT '✅ 数据库迁移完成！' as status;

-- 显示用户表结构
\d users

-- 显示角色分布
SELECT
    role_id,
    CASE
        WHEN role_id = 1 THEN '普通用户'
        WHEN role_id = 2 THEN '管理员'
        ELSE '未知'
    END as role_name,
    COUNT(*) as user_count
FROM users
GROUP BY role_id
ORDER BY role_id;
