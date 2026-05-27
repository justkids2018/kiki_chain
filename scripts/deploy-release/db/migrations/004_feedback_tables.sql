-- Migration 004: 用户反馈表
-- 幂等执行，可重复运行

CREATE TABLE IF NOT EXISTS user_feedback (
  id BIGSERIAL PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  feedback_type VARCHAR(32) NOT NULL DEFAULT 'general',
  content TEXT NOT NULL,
  contact VARCHAR(128),
  page VARCHAR(128),
  status VARCHAR(16) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_feedback_user_id ON user_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_user_feedback_status ON user_feedback(status);
CREATE INDEX IF NOT EXISTS idx_user_feedback_created_at ON user_feedback(created_at DESC);

SELECT '✅ Migration 004 完成：user_feedback 表已就绪' AS status;
