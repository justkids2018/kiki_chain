use async_trait::async_trait;

use crate::core::entities::subscription::{SubscriptionOrder, SubscriptionProduct};
use crate::core::errors::Result;

#[async_trait]
pub trait SubscriptionRepository: Send + Sync {
    async fn list_products(&self) -> Result<Vec<SubscriptionProduct>>;
    async fn find_product(&self, product_id: &str) -> Result<Option<SubscriptionProduct>>;
    async fn save_order(&self, order: &SubscriptionOrder) -> Result<()>;
    async fn find_order(&self, order_id: &str, user_id: &str) -> Result<Option<SubscriptionOrder>>;
    async fn update_order_paid(
        &self,
        order_id: &str,
        user_id: &str,
        purchase_token: Option<&str>,
        vip_expire_at: chrono::DateTime<chrono::Utc>,
    ) -> Result<SubscriptionOrder>;
    async fn update_user_vip(
        &self,
        user_id: &str,
        vip_expire_at: chrono::DateTime<chrono::Utc>,
    ) -> Result<()>;
}
