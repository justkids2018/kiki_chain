// PostgreSQL 场景仓储实现

use async_trait::async_trait;
use chrono::{DateTime, NaiveDateTime, Utc};
use sqlx::{PgPool, Row};

use crate::core::entities::{Scene, SceneCategory, SceneDetail, SceneItem};
use crate::core::errors::{DomainError, Result};
use crate::core::ports::SceneRepository;

#[derive(Clone)]
pub struct PostgresSceneRepository {
    pool: PgPool,
}

impl PostgresSceneRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    fn naive_to_utc(naive: NaiveDateTime) -> DateTime<Utc> {
        DateTime::from_naive_utc_and_offset(naive, Utc)
    }

    fn map_row_to_category(row: &sqlx::postgres::PgRow) -> SceneCategory {
        SceneCategory {
            id: row.get("id"),
            name: row.get("name"),
            icon: row.try_get("icon").ok(),
            cover_image: row.try_get("cover_image").ok(),
            description: row.try_get("description").ok(),
            display_order: row.try_get("display_order").unwrap_or(0),
            is_new: row.try_get("is_new").unwrap_or(false),
            is_visible: row.try_get("is_visible").unwrap_or(true),
            scene_count: row.try_get("scene_count").ok(),
            created_at: Self::naive_to_utc(row.get("created_at")),
            updated_at: Self::naive_to_utc(
                row.try_get("updated_at")
                    .unwrap_or_else(|_| row.get("created_at")),
            ),
        }
    }

    fn map_row_to_scene(row: &sqlx::postgres::PgRow) -> Scene {
        Scene {
            id: row.get("id"),
            category_id: row.get("category_id"),
            name: row.get("name"),
            cover_image: row.try_get("cover_image").ok(),
            interactive_image: row.try_get("interactive_image").ok(),
            description: row.try_get("description").ok(),
            item_count: row.try_get("item_count").unwrap_or(0),
            display_order: row.try_get("display_order").unwrap_or(0),
            is_new: row.try_get("is_new").unwrap_or(false),
            is_visible: row.try_get("is_visible").unwrap_or(true),
            items_data: row.try_get("items_data").ok(),
            created_at: Self::naive_to_utc(row.get("created_at")),
            updated_at: Self::naive_to_utc(
                row.try_get("updated_at")
                    .unwrap_or_else(|_| row.get("created_at")),
            ),
        }
    }

    fn map_row_to_item(row: &sqlx::postgres::PgRow) -> SceneItem {
        SceneItem {
            id: row.get("id"),
            scene_id: row.get("scene_id"),
            item_type: row.try_get("item_type").ok(),
            item_index: row.try_get("item_index").ok(),
            text: row.try_get("text").ok(),
            text_pinyin: row.try_get("text_pinyin").ok(),
            text_english: row.try_get("text_english").ok(),
            coordinates: row.try_get("coordinates").ok(),
            created_at: Self::naive_to_utc(row.get("created_at")),
        }
    }
}

#[async_trait]
impl SceneRepository for PostgresSceneRepository {
    async fn find_all_categories(&self) -> Result<Vec<SceneCategory>> {
        let rows = sqlx::query(
            r#"
            SELECT sc.*,
                   COUNT(s.id) AS scene_count
            FROM scene_categories sc
            LEFT JOIN scenes s ON s.category_id = sc.id AND s.is_visible = TRUE
            WHERE sc.is_visible = TRUE
            GROUP BY sc.id
            ORDER BY sc.display_order ASC, sc.created_at ASC
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询分类失败: {}", e)))?;

        Ok(rows.iter().map(Self::map_row_to_category).collect())
    }

    async fn find_category_by_id(&self, id: &str) -> Result<Option<SceneCategory>> {
        let row = sqlx::query(
            r#"
            SELECT sc.*, COUNT(s.id) AS scene_count
            FROM scene_categories sc
            LEFT JOIN scenes s ON s.category_id = sc.id AND s.is_visible = TRUE
            WHERE sc.id = $1
            GROUP BY sc.id
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询分类失败: {}", e)))?;

        Ok(row.as_ref().map(Self::map_row_to_category))
    }

    async fn find_scenes_by_category(&self, category_id: &str) -> Result<Vec<Scene>> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM scenes
            WHERE category_id = $1 AND is_visible = TRUE
            ORDER BY display_order ASC, created_at ASC
            "#,
        )
        .bind(category_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询场景失败: {}", e)))?;

        Ok(rows.iter().map(Self::map_row_to_scene).collect())
    }

    async fn find_scene_detail(&self, scene_id: &str) -> Result<Option<SceneDetail>> {
        let scene_row = sqlx::query("SELECT * FROM scenes WHERE id = $1")
            .bind(scene_id)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("查询场景失败: {}", e)))?;

        let Some(scene_row) = scene_row else {
            return Ok(None);
        };

        let scene = Self::map_row_to_scene(&scene_row);

        // 从 items_data 字段解析物品数据
        let items = if let Some(items_data) = &scene.items_data {
            if let Some(arr) = items_data.as_array() {
                arr.clone()
            } else {
                vec![]
            }
        } else {
            vec![]
        };

        Ok(Some(SceneDetail { scene, items }))
    }

    async fn search_scenes(
        &self,
        keyword: &str,
        page: i64,
        page_size: i64,
    ) -> Result<(Vec<Scene>, i64)> {
        let pattern = format!("%{}%", keyword);
        let offset = (page - 1) * page_size;

        let total: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM scenes WHERE is_visible = TRUE AND (name ILIKE $1 OR description ILIKE $1)",
        )
        .bind(&pattern)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("搜索统计失败: {}", e)))?;

        let rows = sqlx::query(
            r#"
            SELECT * FROM scenes
            WHERE is_visible = TRUE AND (name ILIKE $1 OR description ILIKE $1)
            ORDER BY display_order ASC, created_at DESC
            LIMIT $2 OFFSET $3
            "#,
        )
        .bind(&pattern)
        .bind(page_size)
        .bind(offset)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("搜索场景失败: {}", e)))?;

        Ok((rows.iter().map(Self::map_row_to_scene).collect(), total))
    }

    async fn find_recommendations(&self, limit: i64) -> Result<Vec<Scene>> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM scenes
            WHERE is_visible = TRUE
            ORDER BY is_new DESC, created_at DESC
            LIMIT $1
            "#,
        )
        .bind(limit)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询推荐失败: {}", e)))?;

        Ok(rows.iter().map(Self::map_row_to_scene).collect())
    }

    async fn save_category(&self, category: &SceneCategory) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO scene_categories
                (id, name, icon, cover_image, description, display_order, is_new, is_visible, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                icon = EXCLUDED.icon,
                cover_image = EXCLUDED.cover_image,
                description = EXCLUDED.description,
                display_order = EXCLUDED.display_order,
                is_new = EXCLUDED.is_new,
                is_visible = EXCLUDED.is_visible,
                updated_at = EXCLUDED.updated_at
            "#,
        )
        .bind(&category.id)
        .bind(&category.name)
        .bind(&category.icon)
        .bind(&category.cover_image)
        .bind(&category.description)
        .bind(category.display_order)
        .bind(category.is_new)
        .bind(category.is_visible)
        .bind(category.created_at.naive_utc())
        .bind(category.updated_at.naive_utc())
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存分类失败: {}", e)))?;

        Ok(())
    }

    async fn delete_category(&self, id: &str) -> Result<()> {
        sqlx::query("DELETE FROM scene_categories WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("删除分类失败: {}", e)))?;
        Ok(())
    }

    async fn save_scene(&self, scene: &Scene) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO scenes
                (id, category_id, name, cover_image, interactive_image, description,
                 item_count, display_order, is_new, is_visible, items_data, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
            ON CONFLICT (id) DO UPDATE SET
                category_id = EXCLUDED.category_id,
                name = EXCLUDED.name,
                cover_image = EXCLUDED.cover_image,
                interactive_image = EXCLUDED.interactive_image,
                description = EXCLUDED.description,
                item_count = EXCLUDED.item_count,
                display_order = EXCLUDED.display_order,
                is_new = EXCLUDED.is_new,
                is_visible = EXCLUDED.is_visible,
                items_data = EXCLUDED.items_data,
                updated_at = EXCLUDED.updated_at
            "#,
        )
        .bind(&scene.id)
        .bind(&scene.category_id)
        .bind(&scene.name)
        .bind(&scene.cover_image)
        .bind(&scene.interactive_image)
        .bind(&scene.description)
        .bind(scene.item_count)
        .bind(scene.display_order)
        .bind(scene.is_new)
        .bind(scene.is_visible)
        .bind(&scene.items_data)
        .bind(scene.created_at.naive_utc())
        .bind(scene.updated_at.naive_utc())
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存场景失败: {}", e)))?;

        Ok(())
    }

    async fn delete_scene(&self, id: &str) -> Result<()> {
        sqlx::query("DELETE FROM scenes WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("删除场景失败: {}", e)))?;
        Ok(())
    }

    async fn save_scene_item(&self, item: &SceneItem) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO scene_items
                (id, scene_id, item_type, item_index, text, text_pinyin, text_english, coordinates, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (id) DO UPDATE SET
                item_type = EXCLUDED.item_type,
                item_index = EXCLUDED.item_index,
                text = EXCLUDED.text,
                text_pinyin = EXCLUDED.text_pinyin,
                text_english = EXCLUDED.text_english,
                coordinates = EXCLUDED.coordinates
            "#,
        )
        .bind(&item.id)
        .bind(&item.scene_id)
        .bind(&item.item_type)
        .bind(item.item_index)
        .bind(&item.text)
        .bind(&item.text_pinyin)
        .bind(&item.text_english)
        .bind(&item.coordinates)
        .bind(item.created_at.naive_utc())
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存场景物品失败: {}", e)))?;

        Ok(())
    }

    async fn delete_scene_item(&self, id: &str) -> Result<()> {
        sqlx::query("DELETE FROM scene_items WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("删除场景物品失败: {}", e)))?;
        Ok(())
    }

    async fn find_items_by_scene(&self, scene_id: &str) -> Result<Vec<SceneItem>> {
        let rows = sqlx::query(
            "SELECT * FROM scene_items WHERE scene_id = $1 ORDER BY item_index ASC",
        )
        .bind(scene_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询场景物品失败: {}", e)))?;

        Ok(rows.iter().map(Self::map_row_to_item).collect())
    }

    async fn find_all_scenes(&self, page: i64, page_size: i64) -> Result<(Vec<Scene>, i64)> {
        let offset = (page - 1) * page_size;

        let total: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM scenes")
            .fetch_one(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("统计场景失败: {}", e)))?;

        let rows = sqlx::query(
            "SELECT * FROM scenes ORDER BY display_order ASC, created_at DESC LIMIT $1 OFFSET $2",
        )
        .bind(page_size)
        .bind(offset)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("查询所有场景失败: {}", e)))?;

        Ok((rows.iter().map(Self::map_row_to_scene).collect(), total))
    }
}
