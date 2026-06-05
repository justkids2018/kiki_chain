// 学习进度 HTTP DTOs

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::core::domain::learning::{SceneProgress, UserScoreSummary, LearnedRegion};

/// 学习进度响应DTO
#[derive(Debug, Serialize)]
pub struct ProgressResponseDto {
    pub user_id: String,
    pub scene_id: String,
    pub total_regions: i32,
    pub learned_regions: Vec<String>,
    pub learned_count: i32,
    pub stars_earned: i32,
    pub total_score: i32,
    pub is_completed: bool,
    pub first_learned_at: Option<DateTime<Utc>>,
    pub last_learned_at: Option<DateTime<Utc>>,
    pub total_study_time: i32,
}

impl From<&SceneProgress> for ProgressResponseDto {
    fn from(p: &SceneProgress) -> Self {
        Self {
            user_id: p.user_id.clone(),
            scene_id: p.scene_id.clone(),
            total_regions: p.total_regions,
            learned_regions: p.learned_regions.0.clone(),
            learned_count: p.learned_count,
            stars_earned: p.stars_earned,
            total_score: p.total_score,
            is_completed: p.is_completed,
            first_learned_at: p.first_learned_at,
            last_learned_at: p.last_learned_at,
            total_study_time: p.total_study_time,
        }
    }
}

/// 批量提交进度请求DTO
#[derive(Debug, Deserialize)]
pub struct SubmitProgressRequestDto {
    pub user_id: String,
    pub scene_id: String,
    pub learned_regions: Vec<LearnedRegionDto>,
    pub stars_earned: i32,
    pub is_completed: bool,
    pub study_time: i32,
}

#[derive(Debug, Deserialize)]
pub struct LearnedRegionDto {
    pub region_id: String,
    pub region_text: String,
    pub region_text_english: String,
    pub learned_at: String,
}

impl From<LearnedRegionDto> for LearnedRegion {
    fn from(dto: LearnedRegionDto) -> Self {
        Self {
            region_id: dto.region_id,
            region_text: dto.region_text,
            region_text_english: dto.region_text_english,
            learned_at: dto.learned_at,
        }
    }
}

/// 提交进度响应DTO
#[derive(Debug, Serialize)]
pub struct SubmitProgressResponseDto {
    pub total_stars: i32,
    pub total_score: i32,
    pub user_total_stars: i32,
    pub user_total_score: i32,
}

/// 用户汇总响应DTO
#[derive(Debug, Serialize)]
pub struct UserSummaryResponseDto {
    pub user_id: String,
    pub total_stars: i32,
    pub total_score: i32,
    pub completed_scenes: i32,
    pub total_study_time: i32,
    pub last_active_at: Option<DateTime<Utc>>,
}

impl From<&UserScoreSummary> for UserSummaryResponseDto {
    fn from(s: &UserScoreSummary) -> Self {
        Self {
            user_id: s.user_id.clone(),
            total_stars: s.total_stars,
            total_score: s.total_score,
            completed_scenes: s.completed_scenes,
            total_study_time: s.total_study_time,
            last_active_at: s.last_active_at,
        }
    }
}
