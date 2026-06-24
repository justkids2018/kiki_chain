## Failure Signature
VIP status remains stale after database changes or after returning from a successful subscription payment.

## Root Cause
The Flutter client treated cached user info as authoritative. `AuthRepositoryImpl.getCurrentUser()` returned local `userInfo` whenever present, so the profile page and home topic lock state did not see the latest `is_vip` value from `/api/v1/mobile/user/profile`. The server profile response also uses `uid/name/created_at`, while the generic `User.fromJson` path primarily expects `id/nickname/createdAt`.

## Evidence
- `kiki_web/lib/data/repositories/auth_repository_impl.dart` returned cached user data before making a profile request.
- `kiki_server/src/adapters/http/user/dtos.rs` exposes profile fields as `uid`, `name`, `created_at`, `is_vip`, and `vip_expire_at`.
- `kiki_web/lib/presentation/controllers/home_controller.dart` only applied subscription entitlement locally after payment, without refreshing the authoritative server profile.

## Affected Scope
- Profile VIP badge and personal info page.
- Home topic list lock state after payment or manual database VIP changes.

## Patch Plan
1. Add a repository method that forces a server profile refresh and updates local cache.
2. Normalize server profile fields into the frontend `User` entity.
3. Refresh current user state when entering the profile tab, opening personal info, and returning from subscription payment.

## Regression Risk
Low. The change is isolated to authenticated user state refresh and preserves cached fallback values such as total stars.

## Verification Plan
1. Run Dart formatting and Flutter static analysis.
2. Manual check: change `users.is_vip` in the database, enter profile, and verify VIP badge updates.
3. Manual check: complete VIP payment, return to the home topic list, and verify locked topic cards unlock.
