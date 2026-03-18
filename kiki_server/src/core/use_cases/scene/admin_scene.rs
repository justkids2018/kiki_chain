use std::sync::Arc;
use chrono::Utc;
use crate::core::entities::{Scene, SceneCategory, SceneDetail};
use crate::core::errors::{DomainError, Result};
use crate::core::ports::SceneRepository;

// ===== Commands =====

pub struct CreateCategoryCommand {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    pub display_order: i32,
    pub is_new: bool,
}

pub struct UpdateCategoryCommand {
    pub id: String,
    pub name: Option<String>,
    pub icon: Option<String>,
    pub cover_image: Option<String>,
    pub description: Option<String>,
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
    pub is_visible: Option<bool>,
}

pub struct CreateSceneCommand {
    pub id: String,
    pub category_id: String,
    pub name: String,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    pub display_order: i32,
    pub is_new: bool,
    pub items_data: Option<serde_json::Value>,
}

pub struct UpdateSceneCommand {
    pub id: String,
    pub name: Option<String>,
    pub name_en: Option<String>,
    pub cover_image: Option<String>,
    pub interactive_image: Option<String>,
    pub description: Option<String>,
    pub context: Option<String>,
    pub display_order: Option<i32>,
    pub is_new: Option<bool>,
    pub is_visible: Option<bool>,
    pub items_data: Option<serde_json::Value>,
}

/// 管理端场景用例（分类和场景的 CRUD）
pub struct AdminSceneUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl AdminSceneUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    // ===== 分类管理 =====

    pub async fn list_categories(&self) -> Result<Vec<SceneCategory>> {
        self.repo.find_all_categories().await
    }

    pub async fn create_category(&self, cmd: CreateCategoryCommand) -> Result<SceneCategory> {
        let now = Utc::now();
        let category = SceneCategory {
            id: cmd.id,
            name: cmd.name,
            icon: cmd.icon,
            cover_image: cmd.cover_image,
            description: cmd.description,
            display_order: cmd.display_order,
            is_new: cmd.is_new,
            is_visible: true,
            scene_count: Some(0),
            created_at: now,
            updated_at: now,
        };
        self.repo.save_category(&category).await?;
        Ok(category)
    }

    pub async fn update_category(&self, cmd: UpdateCategoryCommand) -> Result<SceneCategory> {
        let mut category = self.repo
            .find_category_by_id(&cmd.id).await?
            .ok_or_else(|| DomainError::NotFound(format!("分类不存在: {}", cmd.id)))?;

        if let Some(name) = cmd.name { category.name = name; }
        if let Some(icon) = cmd.icon { category.icon = Some(icon); }
        if let Some(img) = cmd.cover_image { category.cover_image = Some(img); }
        if let Some(desc) = cmd.description { category.description = Some(desc); }
        if let Some(order) = cmd.display_order { category.display_order = order; }
        if let Some(is_new) = cmd.is_new { category.is_new = is_new; }
        if let Some(visible) = cmd.is_visible { category.is_visible = visible; }
        category.updated_at = Utc::now();

        self.repo.save_category(&category).await?;
        Ok(category)
    }

    pub async fn delete_category(&self, id: &str) -> Result<()> {
        self.repo.delete_category(id).await
    }

    // ===== 场景管理 =====

    pub async fn list_scenes(&self, page: i64, page_size: i64) -> Result<(Vec<Scene>, i64)> {
        let page = page.max(1);
        let page_size = page_size.clamp(1, 100);
        self.repo.find_all_scenes(page, page_size).await
    }

    pub async fn list_scenes_by_category(
        &self,
        page: i64,
        page_size: i64,
        category_id: Option<&str>,
    ) -> Result<(Vec<Scene>, i64)> {
        let page = page.max(1);
        let page_size = page_size.clamp(1, 100);

        match category_id {
            Some(cat_id) => {
                // 获取该分类下的所有场景
                let all_scenes = self.repo.find_scenes_by_category(cat_id).await?;
                let total = all_scenes.len() as i64;

                // 手动分页
                let offset = ((page - 1) * page_size) as usize;
                let scenes: Vec<Scene> = all_scenes
                    .into_iter()
                    .skip(offset)
                    .take(page_size as usize)
                    .collect();

                Ok((scenes, total))
            }
            None => self.repo.find_all_scenes(page, page_size).await,
        }
    }

    pub async fn create_scene(&self, cmd: CreateSceneCommand) -> Result<Scene> {
        let now = Utc::now();

        // 计算 item_count
        let item_count = if let Some(ref items_data) = cmd.items_data {
            if let Some(arr) = items_data.as_array() {
                arr.len() as i32
            } else {
                0
            }
        } else {
            0
        };

        let scene = Scene {
            id: cmd.id,
            category_id: cmd.category_id,
            name: cmd.name,
            name_en: cmd.name_en,
            cover_image: cmd.cover_image,
            interactive_image: cmd.interactive_image,
            description: cmd.description,
            context: cmd.context,
            item_count,
            display_order: cmd.display_order,
            is_new: cmd.is_new,
            is_visible: true,
            items_data: cmd.items_data,
            created_at: now,
            updated_at: now,
        };
        self.repo.save_scene(&scene).await?;
        Ok(scene)
    }

    pub async fn update_scene(&self, cmd: UpdateSceneCommand) -> Result<Scene> {
        let detail = self.repo.find_scene_detail(&cmd.id).await?
            .ok_or_else(|| DomainError::NotFound(format!("场景不存在: {}", cmd.id)))?;
        let mut scene = detail.scene;

        if let Some(name) = cmd.name { scene.name = name; }
        if let Some(name_en) = cmd.name_en { scene.name_en = Some(name_en); }
        if let Some(img) = cmd.cover_image { scene.cover_image = Some(img); }
        if let Some(img) = cmd.interactive_image { scene.interactive_image = Some(img); }
        if let Some(desc) = cmd.description { scene.description = Some(desc); }
        if let Some(ctx) = cmd.context { scene.context = Some(ctx); }
        if let Some(order) = cmd.display_order { scene.display_order = order; }
        if let Some(is_new) = cmd.is_new { scene.is_new = is_new; }
        if let Some(visible) = cmd.is_visible { scene.is_visible = visible; }

        // 更新 items_data 和 item_count
        if let Some(items_data) = cmd.items_data {
            scene.item_count = if let Some(arr) = items_data.as_array() {
                arr.len() as i32
            } else {
                0
            };
            scene.items_data = Some(items_data);
        }

        scene.updated_at = Utc::now();

        self.repo.save_scene(&scene).await?;
        Ok(scene)
    }

    pub async fn delete_scene(&self, id: &str) -> Result<()> {
        self.repo.delete_scene(id).await
    }

    pub async fn get_scene_detail(&self, id: &str) -> Result<Option<SceneDetail>> {
        self.repo.find_scene_detail(id).await
    }
}
