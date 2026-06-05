// 学习进度仓储PostgreSQL实现

use async_trait::async_trait;
use chrono::Utc;
use sqlx::PgPool;
use tracing::{error, info};

use crate::core::domain::learning::{SceneProgress, LearningLog, UserScoreSummary};
use crate::core::repositories::learning::LearningProgressRepository;

pub struct PostgresLearningProgressRepository {
    pool: PgPool,
}

impl PostgresLearningProgressRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl LearningProgressRepository for PostgresLearningProgressRepository {
    async fn get_progress(&self, user_id: &str, scene_id: &str) -> anyhow::Result<Option<SceneProgress>> {
        let progress = sqlx::query_as::<_, SceneProgress>(
            r#"
            SELECT id, user_id, scene_id, total_regions, learned_regions,
                   learned_count, stars_earned, total_score, is_completed,
                   first_learned_at, last_learned_at, total_study_time,
                   created_at, updated_at
            FROM user_scene_progress
            WHERE user_id = $1 AND scene_id = $2
            "#,
        )
        .bind(user_id)
        .bind(scene_id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(progress)
    }

    async fn upsert_progress(&self, progress: &SceneProgress) -> anyhow::Result<()> {
        sqlx::query(
            r#"
            INSERT INTO user_scene_progress (
                user_id, scene_id, total_regions, learned_regions,
                learned_count, stars_earned, total_score, is_completed,
                first_learned_at, last_learned_at, total_study_time
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            ON CONFLICT (user_id, scene_id) DO UPDATE SET
                learned_regions = EXCLUDED.learned_regions,
                learned_count = EXCLUDED.learned_count,
                stars_earned = EXCLUDED.stars_earned,
                total_score = EXCLUDED.total_score,
                is_completed = EXCLUDED.is_completed,
                last_learned_at = EXCLUDED.last_learned_at,
                total_study_time = EXCLUDED.total_study_time,
                updated_at = NOW()
            "#,
        )
        .bind(&progress.user_id)
        .bind(&progress.scene_id)
        .bind(progress.total_regions)
        .bind(&progress.learned_regions)
        .bind(progress.learned_count)
        .bind(progress.stars_earned)
        .bind(progress.total_score)
        .bind(progress.is_completed)
        .bind(progress.first_learned_at)
        .bind(progress.last_learned_at)
        .bind(progress.total_study_time)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn insert_logs(&self, logs: Vec<LearningLog>) -> anyhow::Result<()> {
        if logs.is_empty() {
            return Ok(());
        }

        let mut tx = self.pool.begin().await?;

        for log in logs {
            sqlx::query(
                r#"
                INSERT INTO learning_detail_logs (
                    user_id, scene_id, region_id, region_text,
                    region_text_english, learned_at
                )
                VALUES ($1, $2, $3, $4, $5, $6)
                "#,
            )
            .bind(&log.user_id)
            .bind(&log.scene_id)
            .bind(&log.region_id)
            .bind(&log.region_text)
            .bind(&log.region_text_english)
            .bind(&log.learned_at)
            .execute(&mut *tx)
            .await?;
        }

        tx.commit().await?;
        Ok(())
    }

    async fn get_user_summary(&self, user_id: &str) -> anyhow::Result<Option<UserScoreSummary>> {
        let summary = sqlx::query_as::<_, UserScoreSummary>(
            r#"
            SELECT user_id, total_stars, total_score, completed_scenes,
                   total_study_time, last_active_at, created_at, updated_at
            FROM user_score_summary
            WHERE user_id = $1
            "#,
        )
        .bind(user_id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(summary)
    }

    async fn upsert_user_summary(&self, summary: &UserScoreSummary) -> anyhow::Result<()> {
        sqlx::query(
            r#"
            INSERT INTO user_score_summary (
                user_id, total_stars, total_score, completed_scenes,
                total_study_time, last_active_at
            )
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (user_id) DO UPDATE SET
                total_stars = EXCLUDED.total_stars,
                total_score = EXCLUDED.total_score,
                completed_scenes = EXCLUDED.completed_scenes,
                total_study_time = EXCLUDED.total_study_time,
                last_active_at = EXCLUDED.last_active_at,
                updated_at = NOW()
            "#,
        )
        .bind(&summary.user_id)
        .bind(summary.total_stars)
        .bind(summary.total_score)
        .bind(summary.completed_scenes)
        .bind(summary.total_study_time)
        .bind(summary.last_active_at)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn calculate_user_total_stars(&self, user_id: &str) -> anyhow::Result<i32> {
        let result: (Option<i64>,) = sqlx::query_as(
            r#"
            SELECT COALESCE(SUM(stars_earned), 0)
            FROM user_scene_progress
            WHERE user_id = $1
            "#,
        )
        .bind(user_id)
        .fetch_one(&self.pool)
        .await?;

        Ok(result.0.unwrap_or(0) as i32)
    }

    async fn calculate_completed_scenes(&self, user_id: &str) -> anyhow::Result<i32> {
        let result: (i64,) = sqlx::query_as(
            r#"
            SELECT COUNT(*)
            FROM user_scene_progress
            WHERE user_id = $1 AND is_completed = true
            "#,
        )
        .bind(user_id)
        .fetch_one(&self.pool)
        .await?;

        Ok(result.0 as i32)
    }
}
