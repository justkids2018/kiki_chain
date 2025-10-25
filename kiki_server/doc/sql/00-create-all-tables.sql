-- 完整的数据库表结构创建脚本
-- 基于 doc/sql/sql.md 中的设计

-- 1. 权限与用户管理
-- users 表 (如果不存在则创建)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uid character varying(50) UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    pwd VARCHAR(255) NOT NULL,
    email VARCHAR(255) ,
    phone character varying(20) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    role_id integer NOT NULL
);

-- roles 表
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_id integer
);


-- 2. 核心业务逻辑
-- teacher_students 表
CREATE TABLE IF NOT EXISTS teacher_students (
    teacher_id character varying(50) NOT NULL,
    student_id character varying(50) NOT NULL,
    PRIMARY KEY (teacher_id, student_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_teacher_id FOREIGN KEY (teacher_id) REFERENCES users(uid) ON DELETE CASCADE,
    CONSTRAINT fk_student_id FOREIGN KEY (student_id) REFERENCES users(uid) ON DELETE CASCADE
);

-- assignments 表
CREATE TABLE IF NOT EXISTS assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id character varying(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    knowledge_points TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_teacher FOREIGN KEY (teacher_id) REFERENCES users(uid) ON DELETE CASCADE
);

-- student_assignments 表
CREATE TABLE IF NOT EXISTS student_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL,
    student_id character varying(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'not_started',
    dialog_rounds INT NOT NULL DEFAULT 0,
    avg_thinking_time_ms BIGINT DEFAULT 0,
    knowledge_mastery_score DECIMAL(5, 2) DEFAULT 0.0,
    thinking_depth_score DECIMAL(5, 2) DEFAULT 0.0,
    evaluation_metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
    conversation_id  character varying(255) ,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_assignment FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES users(uid) ON DELETE CASCADE
);

-- 确保 evaluation_metrics 字段存在并保持 JSON 结构
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'student_assignments'
          AND column_name = 'evaluation_metrics'
    ) THEN
        ALTER TABLE student_assignments
        ADD COLUMN evaluation_metrics JSONB NOT NULL DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- api_keys 表
CREATE TABLE IF NOT EXISTS api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "type" VARCHAR(50) NOT NULL,
    "key" TEXT NOT NULL,
    info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_api_keys_type_key ON api_keys ("type", "key");

-- dialog_logs 表
CREATE TABLE IF NOT EXISTS dialog_logs (
    id BIGSERIAL PRIMARY KEY,
    student_assignment_id UUID NOT NULL,
    speaker VARCHAR(10) NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    response_time_ms BIGINT DEFAULT 0,
    CONSTRAINT fk_student_assignment FOREIGN KEY (student_assignment_id) REFERENCES student_assignments(id) ON DELETE CASCADE
);

-- 创建索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_student_assignment ON student_assignments (assignment_id, student_id);
CREATE INDEX IF NOT EXISTS idx_dialog_logs_student_assignment_id ON dialog_logs (student_assignment_id);

-- 添加 is_default 字段到 teacher_students 表
DO $$ 
BEGIN
    -- 检查并添加is_default字段
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='teacher_students' AND column_name='is_default'
    ) THEN
        ALTER TABLE teacher_students 
        ADD COLUMN is_default BOOLEAN DEFAULT FALSE;
        
        -- 添加约束：每个学生只能有一个默认老师
        -- 使用部分唯一索引，只对is_default=true的记录生效
        CREATE UNIQUE INDEX idx_student_default_teacher 
        ON teacher_students (student_id) 
        WHERE is_default = TRUE;
    END IF;
END $$;

-- 插入默认角色
INSERT INTO roles (role_name) VALUES 
    ('system_admin'),
    ('teacher'),
    ('student')
ON CONFLICT (role_name) DO NOTHING;
