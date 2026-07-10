// 场景仓储接口定义

use crate::core::entities::{Scene, SceneCategory, SceneDetail, SceneItem};
use crate::core::errors::Result;
use async_trait::async_trait;

#[async_trait]
pub trait SceneRepository: Send + Sync {
    /// 获取所有可见分类列表（含场景数量）
    async fn find_all_categories(&self) -> Result<Vec<SceneCategory>>;

    /// 获取单个分类
    async fn find_category_by_id(&self, id: &str) -> Result<Option<SceneCategory>>;

    /// 获取某分类下的场景列表
    async fn find_scenes_by_category(&self, category_id: &str) -> Result<Vec<Scene>>;

    /// 获取场景详情（含物品）
    async fn find_scene_detail(&self, scene_id: &str) -> Result<Option<SceneDetail>>;

    /// 搜索场景
    async fn search_scenes(
        &self,
        keyword: &str,
        page: i64,
        page_size: i64,
    ) -> Result<(Vec<Scene>, i64)>;

    /// 获取推荐场景
    async fn find_recommendations(&self, limit: i64) -> Result<Vec<Scene>>;

    // ===== Admin CRUD =====
    /// 保存分类（新增或更新）
    async fn save_category(&self, category: &SceneCategory) -> Result<()>;

    /// 删除分类
    async fn delete_category(&self, id: &str) -> Result<()>;

    /// 保存场景（新增或更新）
    async fn save_scene(&self, scene: &Scene) -> Result<()>;

    /// 保存场景和主题的多对多关联
    async fn save_scene_category_relations(
        &self,
        scene_id: &str,
        category_ids: &[String],
        primary_category_id: &str,
        display_order: i32,
    ) -> Result<()>;

    /// 删除场景
    async fn delete_scene(&self, id: &str) -> Result<()>;

    /// 保存场景物品
    async fn save_scene_item(&self, item: &SceneItem) -> Result<()>;

    /// 删除场景物品
    async fn delete_scene_item(&self, id: &str) -> Result<()>;

    /// 获取场景下所有物品
    async fn find_items_by_scene(&self, scene_id: &str) -> Result<Vec<SceneItem>>;

    /// 查询所有场景（分页，供管理端使用）
    async fn find_all_scenes(&self, page: i64, page_size: i64) -> Result<(Vec<Scene>, i64)>;
}
