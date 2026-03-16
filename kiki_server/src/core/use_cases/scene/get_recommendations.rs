use std::sync::Arc;
use crate::core::entities::Scene;
use crate::core::errors::Result;
use crate::core::ports::SceneRepository;

pub struct GetRecommendationsUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl GetRecommendationsUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    pub async fn execute(&self, limit: i64) -> Result<Vec<Scene>> {
        let limit = limit.clamp(1, 50);
        self.repo.find_recommendations(limit).await
    }
}
