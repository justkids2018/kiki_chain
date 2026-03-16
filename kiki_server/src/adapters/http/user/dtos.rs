use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
pub struct UserProfileDto {
    pub uid: String,
    pub name: String,
    pub phone: String,
    pub email: String,
    pub role_type: i32,
    pub is_vip: bool,
    pub vip_expire_at: Option<String>,
    pub created_at: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProfileRequest {
    pub name: Option<String>,
    pub email: Option<String>,
}
