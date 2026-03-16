use std::sync::Arc;
use crate::core::entities::Scene;
use crate::core::errors::Result;
use crate::core::ports::SceneRepository;

pub struct GetScenesByCategoryUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl GetScenesByCategoryUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    pub async fn execute(&self, category_id: &str) -> Result<Vec<Scene>> {
        self.repo.find_scenes_by_category(category_id).await
    }
}
