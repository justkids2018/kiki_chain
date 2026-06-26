-- Migration 007: VIP subscription commercialization
-- PostgreSQL, idempotent.
-- 来源: kiki_server/migrations/006_subscription_commercialization.sql
-- 说明: 新事实源中 006 已用于角色修复迁移，因此订阅商业化迁移使用 007。

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_vip BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS vip_expire_at TIMESTAMP;

ALTER TABLE scenes ADD COLUMN IF NOT EXISTS is_free BOOLEAN;
ALTER TABLE scenes ADD COLUMN IF NOT EXISTS requires_vip BOOLEAN;

CREATE TABLE IF NOT EXISTS subscription_products (
  product_id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(64) NOT NULL,
  period VARCHAR(16) NOT NULL,
  price_cents INT NOT NULL,
  currency VARCHAR(8) NOT NULL DEFAULT 'CNY',
  display_price VARCHAR(32) NOT NULL,
  trial_days INT NOT NULL DEFAULT 0,
  is_recommended BOOLEAN NOT NULL DEFAULT FALSE,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subscription_orders (
  order_id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  product_id VARCHAR(64) NOT NULL,
  payment_channel VARCHAR(32) NOT NULL,
  amount_cents INT NOT NULL,
  currency VARCHAR(8) NOT NULL DEFAULT 'CNY',
  status VARCHAR(16) NOT NULL DEFAULT 'pending',
  purchase_token TEXT,
  vip_expire_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subscription_orders_user_id ON subscription_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_orders_status ON subscription_orders(status);
CREATE INDEX IF NOT EXISTS idx_subscription_orders_created_at ON subscription_orders(created_at DESC);

CREATE TABLE IF NOT EXISTS subscription_events (
  id BIGSERIAL PRIMARY KEY,
  order_id VARCHAR(64) NOT NULL,
  user_id VARCHAR(64) NOT NULL,
  event_type VARCHAR(32) NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subscription_events_order_id ON subscription_events(order_id);
CREATE INDEX IF NOT EXISTS idx_subscription_events_user_id ON subscription_events(user_id);

INSERT INTO subscription_products (
  product_id, title, period, price_cents, currency, display_price,
  trial_days, is_recommended, enabled
) VALUES
  ('kiki_vip_monthly', '连续包月', 'monthly', 990, 'CNY', '¥9.9/月', 0, FALSE, TRUE),
  ('kiki_vip_yearly', '连续包年', 'yearly', 8800, 'CNY', '¥88/年', 3, TRUE, TRUE)
ON CONFLICT (product_id) DO UPDATE SET
  title = EXCLUDED.title,
  period = EXCLUDED.period,
  price_cents = EXCLUDED.price_cents,
  currency = EXCLUDED.currency,
  display_price = EXCLUDED.display_price,
  trial_days = EXCLUDED.trial_days,
  is_recommended = EXCLUDED.is_recommended,
  enabled = EXCLUDED.enabled,
  updated_at = CURRENT_TIMESTAMP;

SELECT '✅ Migration 007 完成：VIP subscription commercialization' as status;
