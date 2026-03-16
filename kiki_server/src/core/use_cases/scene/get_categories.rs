use std::sync::Arc;
use crate::core::entities::SceneCategory;
use crate::core::errors::Result;
use crate::core::ports::SceneRepository;

pub struct GetCategoriesUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl GetCategoriesUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    pub async fn execute(&self) -> Result<Vec<SceneCategory>> {
        self.repo.find_all_categories().await
    }
}
