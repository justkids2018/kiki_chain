-- Migration 006: 修复用户角色类型
-- 将所有 role_type 为 0 或 NULL 的用户更新为 1（普通用户）
-- 来源: kiki_server/migrations/005_fix_user_roles.sql
-- 说明: 旧目录中存在 005 版本冲突；新事实源中使用 006 承接该生产迁移。

-- ============================================
-- 1. 更新所有无效的 role_type 为 1（普通用户）
-- ============================================
UPDATE users
SET role_type = 1
WHERE role_type IS NULL OR role_type = 0 OR role_type NOT IN (1, 2);

-- ============================================
-- 2. 确保 role_type 字段有默认值
-- ============================================
DO $$
BEGIN
    -- 设置默认值为 1
    ALTER TABLE users ALTER COLUMN role_type SET DEFAULT 1;
    RAISE NOTICE '✅ 已设置 role_type 默认值为 1';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ℹ️  role_type 默认值设置失败或已存在';
END $$;

-- ============================================
-- 3. 添加非空约束（如果还没有）
-- ============================================
DO $$
BEGIN
    ALTER TABLE users ALTER COLUMN role_type SET NOT NULL;
    RAISE NOTICE '✅ 已添加 role_type 非空约束';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ℹ️  role_type 非空约束已存在';
END $$;

-- ============================================
-- 4. 添加检查约束（如果还没有）
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'chk_users_role_type'
    ) THEN
        ALTER TABLE users
        ADD CONSTRAINT chk_users_role_type CHECK (role_type IN (1, 2));
        RAISE NOTICE '✅ 已添加角色约束';
    ELSE
        RAISE NOTICE 'ℹ️  角色约束已存在';
    END IF;
END $$;

-- ============================================
-- 5. 验证迁移结果
-- ============================================
SELECT '✅ 数据库迁移完成！' as status;

-- 显示角色分布
SELECT
    role_type,
    CASE
        WHEN role_type = 1 THEN '普通用户'
        WHEN role_type = 2 THEN '管理员'
        ELSE '未知'
    END as role_name,
    COUNT(*) as user_count
FROM users
GROUP BY role_type
ORDER BY role_type;

-- 检查是否还有无效的 role_type
SELECT COUNT(*) as invalid_count
FROM users
WHERE role_type NOT IN (1, 2);
