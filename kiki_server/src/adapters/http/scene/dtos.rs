use crate::core::entities::{Scene, SceneCategory, SceneDetail, SceneItem};
use serde::{Deserialize, Serialize};

// ===== 响应 DTOs =====

#[derive(Debug, Serialize)]
pub struct SceneCategoryDto {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    #[serde(rename = "order")]
    pub display_order: i32,
    pub is_new: bool,
    pub scene_count: i64,
    pub total_item_count: i64,
}

#[derive(Debug, Serialize)]
pub struct SceneDto {
    pub id: String,
    pub category_id: String,
    pub category_ids: Vec<String>,
    pub name: String,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    pub data_file: Option<String>,
    pub item_count: i32,
    #[serde(rename = "order")]
    pub display_order: i32,
    pub is_new: bool,
    pub is_free: bool,
    pub requires_vip: bool,
    pub is_locked: bool,
    pub items_data: Option<serde_json::Value>, // JSON 数组
}

#[derive(Debug, Serialize)]
pub struct SceneItemDto {
    pub id: String,
    pub scene_id: String,
    pub item_type: Option<String>,
    pub item_index: Option<i32>,
    pub text: Option<String>,
    pub text_pinyin: Option<String>,
    pub text_english: Option<String>,
    pub coordinates: Option<serde_json::Value>,
}

#[derive(Debug, Serialize)]
pub struct SceneDetailDto {
    pub scene: SceneDto,
    pub items: Vec<serde_json::Value>, // JSON 数组
}

#[derive(Debug, Serialize)]
pub struct SearchScenesDto {
    pub total: i64,
    pub page: i64,
    pub page_size: i64,
    pub scenes: Vec<SceneDto>,
}

// ===== 请求 DTOs =====

#[derive(Debug, Deserialize)]
pub struct SearchQuery {
    pub keyword: Option<String>,
    pub page: Option<i64>,
    #[serde(rename = "pageSize")]
    pub page_size: Option<i64>,
}

#[derive(Debug, Deserialize)]
pub struct RecommendationsQuery {
    pub limit: Option<i64>,
}

// Admin 请求 DTOs
#[derive(Debug, Deserialize)]
pub struct CreateCategoryRequest {
    pub id: Option<String>,
    pub name: String,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    #[serde(alias = "order")]
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateCategoryRequest {
    pub name: Option<String>,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    #[serde(alias = "order")]
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
    pub is_visible: Option<bool>,
}

#[derive(Debug, Deserialize)]
pub struct CreateSceneRequest {
    pub id: Option<String>,
    pub category_id: Option<String>,
    pub category_ids: Option<Vec<String>>,
    pub name: String,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    #[serde(alias = "order")]
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
    pub items_data: Option<serde_json::Value>, // JSON 数组
}

#[derive(Debug, Deserialize)]
pub struct UpdateSceneRequest {
    pub category_id: Option<String>,
    pub category_ids: Option<Vec<String>>,
    pub name: Option<String>,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    #[serde(rename = "order", alias = "display_order")]
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
    pub is_visible: Option<bool>,
    pub items_data: Option<serde_json::Value>, // JSON 数组
}

#[derive(Debug, Deserialize)]
pub struct AdminListQuery {
    pub page: Option<i64>,
    #[serde(rename = "pageSize")]
    pub page_size: Option<i64>,
    #[serde(rename = "categoryId")]
    pub category_id: Option<String>,
}

// ===== 转换 =====

impl From<&SceneCategory> for SceneCategoryDto {
    fn from(c: &SceneCategory) -> Self {
        Self {
            id: c.id.clone(),
            name: c.name.clone(),
            icon: c.icon.clone(),
            cover_image: c.cover_image.clone(),
            description: c.description.clone(),
            display_order: c.display_order,
            is_new: c.is_new,
            scene_count: c.scene_count.unwrap_or(0),
            total_item_count: 0,
        }
    }
}

impl From<&Scene> for SceneDto {
    fn from(s: &Scene) -> Self {
        Self::from_scene_with_index(s, None, false)
    }
}

impl SceneDto {
    pub fn from_scene_with_index(s: &Scene, index: Option<usize>, user_is_vip: bool) -> Self {
        let index_is_free = index.map(|i| i == 0).unwrap_or(s.display_order <= 1);
        let is_free = s.is_free.unwrap_or(index_is_free);
        let requires_vip = s.requires_vip.unwrap_or(!is_free);
        let is_locked = requires_vip && !user_is_vip;

        Self {
            id: s.id.clone(),
            category_id: s.category_id.clone(),
            category_ids: s.category_ids.clone(),
            name: s.name.clone(),
            name_en: s.name_en.clone(),
            cover_image: s.cover_image.clone(),
            interactive_image: s.interactive_image.clone(),
            description: s.description.clone(),
            context: s.context.clone(),
            data_file: None,
            item_count: s.item_count,
            display_order: s.display_order,
            is_new: s.is_new,
            is_free,
            requires_vip,
            is_locked,
            items_data: s.items_data.clone(),
        }
    }
}

impl From<&SceneItem> for SceneItemDto {
    fn from(i: &SceneItem) -> Self {
        Self {
            id: i.id.clone(),
            scene_id: i.scene_id.clone(),
            item_type: i.item_type.clone(),
            item_index: i.item_index,
            text: i.text.clone(),
            text_pinyin: i.text_pinyin.clone(),
            text_english: i.text_english.clone(),
            coordinates: i.coordinates.clone(),
        }
    }
}

impl From<SceneDetail> for SceneDetailDto {
    fn from(d: SceneDetail) -> Self {
        Self {
            scene: SceneDto::from(&d.scene),
            items: d.items,
        }
    }
}
