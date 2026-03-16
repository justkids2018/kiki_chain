use std::sync::Arc;
use crate::core::entities::Scene;
use crate::core::errors::Result;
use crate::core::ports::SceneRepository;

pub struct SearchScenesCommand {
    pub keyword: String,
    pub page: i64,
    pub page_size: i64,
}

pub struct SearchScenesResult {
    pub scenes: Vec<Scene>,
    pub total: i64,
    pub page: i64,
    pub page_size: i64,
}

pub struct SearchScenesUseCase {
    repo: Arc<dyn SceneRepository>,
}

impl SearchScenesUseCase {
    pub fn new(repo: Arc<dyn SceneRepository>) -> Self {
        Self { repo }
    }

    pub async fn execute(&self, cmd: SearchScenesCommand) -> Result<SearchScenesResult> {
        let page = cmd.page.max(1);
        let page_size = cmd.page_size.clamp(1, 100);
        let (scenes, total) = self.repo.search_scenes(&cmd.keyword, page, page_size).await?;
        Ok(SearchScenesResult { scenes, total, page, page_size })
    }
}
