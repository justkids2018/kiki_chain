-- ============================================
-- 学习进度系统数据库表设计 (PostgreSQL 版)
-- 版本：v1.0
-- 创建时间：2026-06-11
-- ============================================

-- 表1：用户场景学习进度表
CREATE TABLE IF NOT EXISTS user_scene_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    scene_id VARCHAR(128) NOT NULL,

    -- 学习进度
    total_regions INT NOT NULL,
    learned_regions JSONB,
    learned_count INT DEFAULT 0,

    -- 星星与积分
    stars_earned INT DEFAULT 0,
    total_score INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,

    -- 时间记录
    first_learned_at TIMESTAMPTZ,
    last_learned_at TIMESTAMPTZ,
    total_study_time INT DEFAULT 0,

    -- 时间戳
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    -- 约束与索引
    CONSTRAINT uk_user_scene UNIQUE (user_id, scene_id)
);

CREATE INDEX IF NOT EXISTS idx_user_scene_progress_user_id ON user_scene_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_scene_progress_completed ON user_scene_progress(is_completed);
CREATE INDEX IF NOT EXISTS idx_user_scene_progress_last_learned ON user_scene_progress(last_learned_at);

-- 表2：学习详细日志表
CREATE TABLE IF NOT EXISTS learning_detail_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    scene_id VARCHAR(128) NOT NULL,

    -- 学习详情
    region_id VARCHAR(128) NOT NULL,
    region_text VARCHAR(128),
    region_text_english VARCHAR(128),

    -- 时间
    learned_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_learning_detail_logs_user_scene ON learning_detail_logs(user_id, scene_id);
CREATE INDEX IF NOT EXISTS idx_learning_detail_logs_learned_at ON learning_detail_logs(learned_at);
CREATE INDEX IF NOT EXISTS idx_learning_detail_logs_user_id ON learning_detail_logs(user_id);

-- 表3：用户积分汇总表
CREATE TABLE IF NOT EXISTS user_score_summary (
    user_id VARCHAR(64) PRIMARY KEY,

    -- 汇总数据
    total_stars INT DEFAULT 0,
    total_score INT DEFAULT 0,
    completed_scenes INT DEFAULT 0,
    total_study_time INT DEFAULT 0,

    -- 时间
    last_active_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_score_summary_total_score ON user_score_summary(total_score DESC);
CREATE INDEX IF NOT EXISTS idx_user_score_summary_completed_scenes ON user_score_summary(completed_scenes DESC);
CREATE INDEX IF NOT EXISTS idx_user_score_summary_last_active ON user_score_summary(last_active_at DESC);

-- 插入测试数据
INSERT INTO user_scene_progress (
    user_id, scene_id, total_regions, learned_regions,
    learned_count, stars_earned, total_score, is_completed,
    first_learned_at, last_learned_at, total_study_time
) VALUES (
    'test_user_001',
    'kiki_zhiwuyuan',
    8,
    '["大象", "老虎", "猴子"]'::jsonb,
    3,
    1,
    1,
    false,
    NOW(),
    NOW(),
    120
) ON CONFLICT (user_id, scene_id) DO UPDATE SET updated_at = NOW();

INSERT INTO user_score_summary (
    user_id, total_stars, total_score, completed_scenes,
    total_study_time, last_active_at
) VALUES (
    'test_user_001',
    1,
    1,
    0,
    120,
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET updated_at = NOW();
