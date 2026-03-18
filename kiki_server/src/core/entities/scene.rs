// 场景相关实体
// 对应数据库: scene_categories, scenes, scene_items 表

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// 场景分类实体
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SceneCategory {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    pub display_order: i32,
    pub is_new: bool,
    pub is_visible: bool,
    pub scene_count: Option<i64>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// 场景实体
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Scene {
    pub id: String,
    pub category_id: String,
    pub name: String,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    pub item_count: i32,
    pub display_order: i32,
    pub is_new: bool,
    pub is_visible: bool,
    pub items_data: Option<serde_json::Value>, // JSON 数组，存储场景物品数据
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// 场景物品实体
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SceneItem {
    pub id: String,
    pub scene_id: String,
    pub item_type: Option<String>,
    pub item_index: Option<i32>,
    pub text: Option<String>,
    pub text_pinyin: Option<String>,
    pub text_english: Option<String>,
    pub coordinates: Option<serde_json::Value>,
    pub created_at: DateTime<Utc>,
}

/// 场景详情（含物品列表）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SceneDetail {
    pub scene: Scene,
    pub items: Vec<serde_json::Value>, // 直接从 items_data 解析的 JSON 数组
}
