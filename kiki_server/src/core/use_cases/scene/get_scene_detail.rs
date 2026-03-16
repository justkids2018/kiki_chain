use std::sync::Arc;
use crate::core::entities::SceneDetail;
use crate::core::errors::Result;
use crate::core::ports::SceneRepository;

pub struct GetSceneDetailUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl GetSceneDetailUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    pub async fn execute(&self, scene_id: &str) -> Result<Option<SceneDetail>> {
        self.repo.find_scene_detail(scene_id).await
    }
}
