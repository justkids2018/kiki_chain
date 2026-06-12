// 学习进度领域模型

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// 用户场景学习进度
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct SceneProgress {
    pub id: i64,
    pub user_id: String,
    pub scene_id: String,

    // 学习进度
    pub total_regions: i32,
    pub learned_regions: sqlx::types::Json<Vec<String>>,
    pub learned_count: i32,

    // 星星与积分
    pub stars_earned: i32,
    pub total_score: i32,
    pub is_completed: bool,

    // 时间
    pub first_learned_at: Option<DateTime<Utc>>,
    pub last_learned_at: Option<DateTime<Utc>>,
    pub total_study_time: i32,

    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// 学习详细日志
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct LearningLog {
    pub id: i64,
    pub user_id: String,
    pub scene_id: String,
    pub region_id: String,
    pub region_text: Option<String>,
    pub region_text_english: Option<String>,
    pub learned_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}

/// 用户积分汇总
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct UserScoreSummary {
    pub user_id: String,
    pub total_stars: i32,
    pub total_score: i32,
    pub completed_scenes: i32,
    pub total_study_time: i32,
    pub last_active_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// 学习区域记录
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LearnedRegion {
    pub region_id: String,
    pub region_text: String,
    pub region_text_english: String,
    pub learned_at: String,
}
