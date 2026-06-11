// 学习进度仓储接口

use async_trait::async_trait;
use crate::core::domain::learning::{SceneProgress, LearningLog, UserScoreSummary, LearnedRegion};

#[async_trait]
pub trait LearningProgressRepository: Send + Sync {
    /// 获取用户场景学习进度
    async fn get_progress(&self, user_id: &str, scene_id: &str) -> anyhow::Result<Option<SceneProgress>>;

    /// 保存或更新学习进度
    async fn upsert_progress(&self, progress: &SceneProgress) -> anyhow::Result<()>;

    /// 批量插入学习日志
    async fn insert_logs(&self, logs: Vec<LearningLog>) -> anyhow::Result<()>;

    /// 获取用户积分汇总
    async fn get_user_summary(&self, user_id: &str) -> anyhow::Result<Option<UserScoreSummary>>;

    /// 更新用户积分汇总
    async fn upsert_user_summary(&self, summary: &UserScoreSummary) -> anyhow::Result<()>;

    /// 计算用户总星星数
    async fn calculate_user_total_stars(&self, user_id: &str) -> anyhow::Result<i32>;

    /// 计算用户完成场景数
    async fn calculate_completed_scenes(&self, user_id: &str) -> anyhow::Result<i32>;

    /// 获取用户的所有场景学习进度列表
    async fn get_user_progress_list(&self, user_id: &str) -> anyhow::Result<Vec<SceneProgress>>;
}
