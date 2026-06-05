// 学习进度用例

use chrono::{DateTime, Utc};
use std::sync::Arc;
use tracing::{error, info};

use crate::core::domain::learning::{SceneProgress, LearningLog, UserScoreSummary, LearnedRegion};
use crate::core::repositories::learning::LearningProgressRepository;

/// 获取学习进度用例
pub struct GetProgressUseCase {
    repository: Arc<dyn LearningProgressRepository>,
}

impl GetProgressUseCase {
    pub fn new(repository: Arc<dyn LearningProgressRepository>) -> Self {
        Self { repository }
    }

    pub async fn execute(&self, user_id: &str, scene_id: &str) -> anyhow::Result<Option<SceneProgress>> {
        info!("📚 获取学习进度: user={}, scene={}", user_id, scene_id);
        self.repository.get_progress(user_id, scene_id).await
    }
}

/// 批量提交进度命令
pub struct SubmitProgressCommand {
    pub user_id: String,
    pub scene_id: String,
    pub learned_regions: Vec<LearnedRegion>,
    pub stars_earned: i32,
    pub is_completed: bool,
    pub study_time: i32,
}

/// 批量提交进度用例
pub struct SubmitProgressUseCase {
    repository: Arc<dyn LearningProgressRepository>,
}

impl SubmitProgressUseCase {
    pub fn new(repository: Arc<dyn LearningProgressRepository>) -> Self {
        Self { repository }
    }

    pub async fn execute(&self, cmd: SubmitProgressCommand) -> anyhow::Result<SubmitProgressResult> {
        info!("💾 提交学习进度: user={}, scene={}, stars={}",
              cmd.user_id, cmd.scene_id, cmd.stars_earned);

        // 1. 获取或创建进度记录
        let mut progress = self.repository
            .get_progress(&cmd.user_id, &cmd.scene_id)
            .await?
            .unwrap_or_else(|| {
                // 创建新记录
                SceneProgress {
                    id: 0,
                    user_id: cmd.user_id.clone(),
                    scene_id: cmd.scene_id.clone(),
                    total_regions: 0,
                    learned_regions: sqlx::types::Json(vec![]),
                    learned_count: 0,
                    stars_earned: 0,
                    total_score: 0,
                    is_completed: false,
                    first_learned_at: Some(Utc::now()),
                    last_learned_at: None,
                    total_study_time: 0,
                    created_at: Utc::now(),
                    updated_at: Utc::now(),
                }
            });

        // 2. 合并已学习区域（去重）
        let new_region_ids: Vec<String> = cmd.learned_regions
            .iter()
            .map(|r| r.region_id.clone())
            .collect();

        let mut merged: Vec<String> = progress.learned_regions.0.clone();
        for region_id in new_region_ids {
            if !merged.contains(&region_id) {
                merged.push(region_id);
            }
        }

        // 3. 更新进度
        progress.learned_regions = sqlx::types::Json(merged.clone());
        progress.learned_count = merged.len() as i32;
        progress.stars_earned = cmd.stars_earned;
        progress.total_score = cmd.stars_earned; // 1星=1分
        progress.is_completed = cmd.is_completed;
        progress.last_learned_at = Some(Utc::now());
        progress.total_study_time += cmd.study_time;

        // 4. 保存进度
        self.repository.upsert_progress(&progress).await?;

        // 5. 插入学习日志
        let logs: Vec<LearningLog> = cmd.learned_regions
            .into_iter()
            .map(|r| LearningLog {
                id: 0,
                user_id: cmd.user_id.clone(),
                scene_id: cmd.scene_id.clone(),
                region_id: r.region_id,
                region_text: Some(r.region_text),
                region_text_english: Some(r.region_text_english),
                learned_at: DateTime::parse_from_rfc3339(&r.learned_at)
                    .ok()
                    .map(|dt| dt.with_timezone(&Utc))
                    .unwrap_or_else(Utc::now),
                created_at: Utc::now(),
            })
            .collect();

        self.repository.insert_logs(logs).await?;

        // 6. 更新用户总积分
        let total_stars = self.repository.calculate_user_total_stars(&cmd.user_id).await?;
        let completed_scenes = self.repository.calculate_completed_scenes(&cmd.user_id).await?;

        let summary = UserScoreSummary {
            user_id: cmd.user_id.clone(),
            total_stars,
            total_score: total_stars, // 1星=1分
            completed_scenes,
            total_study_time: 0, // TODO: 汇总所有场景的学习时间
            last_active_at: Some(Utc::now()),
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };

        self.repository.upsert_user_summary(&summary).await?;

        info!("✅ 提交成功: 场景星星={}, 用户总星星={}", cmd.stars_earned, total_stars);

        Ok(SubmitProgressResult {
            total_stars: cmd.stars_earned,
            total_score: cmd.stars_earned,
            user_total_stars: total_stars,
            user_total_score: total_stars,
        })
    }
}

/// 提交进度结果
pub struct SubmitProgressResult {
    pub total_stars: i32,
    pub total_score: i32,
    pub user_total_stars: i32,
    pub user_total_score: i32,
}

/// 获取用户汇总用例
pub struct GetUserSummaryUseCase {
    repository: Arc<dyn LearningProgressRepository>,
}

impl GetUserSummaryUseCase {
    pub fn new(repository: Arc<dyn LearningProgressRepository>) -> Self {
        Self { repository }
    }

    pub async fn execute(&self, user_id: &str) -> anyhow::Result<Option<UserScoreSummary>> {
        info!("📊 获取用户汇总: user={}", user_id);
        self.repository.get_user_summary(user_id).await
    }
}
