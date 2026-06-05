-- ============================================
-- 学习进度系统数据库表设计
-- 版本：v1.0
-- 创建时间：2026-06-04
-- ============================================

-- 表1：用户场景学习进度表
CREATE TABLE IF NOT EXISTS user_scene_progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID',
    scene_id VARCHAR(128) NOT NULL COMMENT '场景ID（如kiki_zhiwuyuan）',

    -- 学习进度
    total_regions INT NOT NULL COMMENT '该场景总词数',
    learned_regions JSON COMMENT '已学习的区域ID列表（JSON数组）',
    learned_count INT DEFAULT 0 COMMENT '已学习词数',

    -- 星星与积分
    stars_earned INT DEFAULT 0 COMMENT '获得的星星数（0-3）',
    total_score INT DEFAULT 0 COMMENT '总积分（与stars_earned相同，1星=1分）',
    is_completed TINYINT(1) DEFAULT 0 COMMENT '是否完成（0=未完成，1=已完成）',

    -- 时间记录
    first_learned_at DATETIME COMMENT '首次学习时间',
    last_learned_at DATETIME COMMENT '最近学习时间',
    total_study_time INT DEFAULT 0 COMMENT '累计学习时长（秒）',

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- 索引
    UNIQUE KEY uk_user_scene (user_id, scene_id),
    INDEX idx_user_id (user_id),
    INDEX idx_completed (is_completed),
    INDEX idx_last_learned (last_learned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户场景学习进度表';

-- 表2：学习详细日志表
CREATE TABLE IF NOT EXISTS learning_detail_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID',
    scene_id VARCHAR(128) NOT NULL COMMENT '场景ID',

    -- 学习详情
    region_id VARCHAR(128) NOT NULL COMMENT '区域ID（词的唯一标识）',
    region_text VARCHAR(128) COMMENT '中文内容',
    region_text_english VARCHAR(128) COMMENT '英文内容',

    -- 时间
    learned_at DATETIME NOT NULL COMMENT '学习时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 索引
    INDEX idx_user_scene (user_id, scene_id),
    INDEX idx_learned_at (learned_at),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习详细日志表';

-- 表3：用户积分汇总表
CREATE TABLE IF NOT EXISTS user_score_summary (
    user_id VARCHAR(64) PRIMARY KEY COMMENT '用户ID',

    -- 汇总数据
    total_stars INT DEFAULT 0 COMMENT '总星星数',
    total_score INT DEFAULT 0 COMMENT '总积分（与total_stars相同，1星=1分）',
    completed_scenes INT DEFAULT 0 COMMENT '完成场景数',
    total_study_time INT DEFAULT 0 COMMENT '累计学习时长（秒）',

    -- 时间
    last_active_at DATETIME COMMENT '最近活跃时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- 索引
    INDEX idx_total_score (total_score DESC),
    INDEX idx_completed_scenes (completed_scenes DESC),
    INDEX idx_last_active (last_active_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户积分汇总表';

-- 插入测试数据（可选）
INSERT INTO user_scene_progress (
    user_id, scene_id, total_regions, learned_regions,
    learned_count, stars_earned, total_score, is_completed,
    first_learned_at, last_learned_at, total_study_time
) VALUES (
    'test_user_001',
    'kiki_zhiwuyuan',
    8,
    '["大象", "老虎", "猴子"]',
    3,
    1,
    1,
    0,
    NOW(),
    NOW(),
    120
) ON DUPLICATE KEY UPDATE updated_at = NOW();

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
) ON DUPLICATE KEY UPDATE updated_at = NOW();
