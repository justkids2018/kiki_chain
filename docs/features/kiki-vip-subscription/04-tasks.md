# Kiki VIP Subscription Tasks

> Created: 2026-06-23

## Task 01: API Contract And Backend Channel Core

- Files:
  - `docs/api/endpoints/subscriptions.md`
  - `docs/api/endpoints/scenes.md`
  - backend subscription domain/use-case/http files
- Work:
  - Define subscription API contract.
  - Add channel policy manager.
  - Add subscription products and entitlement use cases.
- Verification:
  - `cargo check`

## Task 02: Backend Persistence And Routes

- Files:
  - `kiki_server/migrations/006_subscription_commercialization.sql`
  - `kiki_server/src/adapters/persistence/...`
  - `kiki_server/src/framework/bootstrap/...`
- Work:
  - Add subscription tables.
  - Register routes and repositories.
  - Add order create/confirm flow and VIP update.
- Verification:
  - `cargo check`

## Task 03: Paywall Data Fields

- Files:
  - `kiki_server/src/adapters/http/scene/dtos.rs`
  - `kiki_web/lib/domain/entities/scene.dart`
- Work:
  - Add `is_free`, `requires_vip`, `is_locked` fields.
  - Keep compatibility for API paywall metadata.
- Verification:
  - `cargo check`
  - `flutter analyze`

## Task 04: Frontend Subscription Data And Payment Manager

- Files:
  - `kiki_web/lib/domain/entities/subscription.dart`
  - `kiki_web/lib/data/services/api/subscription_api_service.dart`
  - `kiki_web/lib/core/services/payment/payment_manager.dart`
- Work:
  - Add repository/service/models.
  - Add extensible payment manager and adapters.
- Verification:
  - `flutter analyze`

## Task 05: Frontend Subscription UI And Navigation Guard

- Files:
  - `kiki_web/lib/presentation/features/subscription/...`
  - `kiki_web/lib/presentation/controllers/home_controller.dart`
  - `kiki_web/lib/presentation/widgets/category_card.dart`
  - `kiki_web/lib/presentation/widgets/profile_tab.dart`
  - route/service wiring files
- Work:
  - Add card-style subscription page.
  - Guard the home category list: first category is free, later categories require VIP.
  - Add animated VIP lock state on home category cards.
  - Add VIP status and recharge entry to the profile header.
  - Refresh entitlement after successful payment.
- Verification:
  - `flutter analyze`
  - relevant Flutter tests

## Task 06: QA, Review, Documentation Closure

- Files:
  - `docs/features/kiki-vip-subscription/05-test-result.md`
  - `docs/features/kiki-vip-subscription/06-review.md`
  - `docs/features/kiki-vip-subscription/08-doc-updates.md`
- Work:
  - Run backend/frontend checks.
  - Self-review and fix blockers.
  - Document final behavior and remaining production setup.
