# Kiki VIP Subscription Documentation Updates

> Updated: 2026-06-23

## Updated

- `docs/api/endpoints/subscriptions.md`: new subscription/channel/payment API contract.
- `docs/api/endpoints/scenes.md`: added mobile scene list VIP paywall fields.
- `docs/features/kiki-vip-subscription/01-requirement.md`: confirmed channel management requirement.
- `docs/features/kiki-vip-subscription/02-analysis.md`: current backend/frontend analysis.
- `docs/features/kiki-vip-subscription/03-design.md`: technical design and engineering review.
- `docs/features/kiki-vip-subscription/04-tasks.md`: implementation task breakdown.
- `docs/features/kiki-vip-subscription/05-test-result.md`: verification summary.
- `docs/features/kiki-vip-subscription/06-review.md`: self-review result.

## Production Setup Still Needed

- Apply `kiki_server/migrations/006_subscription_commercialization.sql`.
- Configure Apple IAP product IDs and App Store Server validation.
- Configure WeChat Pay merchant credentials and payment callback.
- Configure Google Play Billing credentials if publishing global Android on Google Play.
- Decide final region source, for example server profile, app build flavor, or remote config.

