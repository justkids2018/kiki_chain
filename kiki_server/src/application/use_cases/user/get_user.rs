use crate::domain::entities::User;
use crate::domain::errors::Result;
use crate::domain::repositories::UserRepository;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Deserialize)]
pub struct GetUserCommand {
    pub uid: Option<String>,
    pub role_id: Option<i32>,
}

#[derive(Serialize)]
pub enum GetUserResponse {
    User(Option<User>),
    Users(Vec<User>),
}

pub struct GetUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl GetUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    pub async fn execute(&self, command: GetUserCommand) -> Result<GetUserResponse> {
        if let Some(uid) = command.uid {
            let user = self.user_repository.find_by_uid(&uid).await?;
            return Ok(GetUserResponse::User(user));
        }

        if let Some(role_id) = command.role_id {
            let users = self.user_repository.find_users_by_role(role_id).await?;
            return Ok(GetUserResponse::Users(users));
        }

        Ok(GetUserResponse::Users(vec![]))
    }
}
