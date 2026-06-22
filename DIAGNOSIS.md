## Failure Signature

登录 1~2 天后再次打开 App，被强制跳转回登录页（登录状态无法持久化超过 1 天）。

## Root Cause

1. 后端 JWT access token 固定 **24 小时过期**（`jwt.rs` `create_default_config` 中 `expiry_hours: 24`）。
2. 客户端启动时只做"本地是否登录 + 是否有 token"的判断，不会主动续期。一旦发起任何受保护接口请求，过期 token 被服务端拒绝返回 **401**。
3. 客户端 `AuthInterceptor.onError` 收到非认证接口的 401 时，会立即 `clearToken()` 并调用 `AuthController.logout()` -> 跳转登录页。**整个过程没有尝试用 refresh token 续期**。
4. 登录流程从未下发/保存 refresh token：后端登录响应 DTO 只有 `token` 一个字段（`auth/dtos.rs`），客户端 `login()` 也只 `setAccessToken`，从不调用 `setRefreshToken`。
5. 即使客户端调用 `/api/v1/auth/refresh-token` 续期接口，**后端根本没有注册该路由**（`routes/auth.rs` 只挂了 login/register/verify/logout），调用会 404，刷新必然失败。

结论：token 必然在 24 小时后过期 -> 下次冷启动后首个受保护请求触发 401 -> 客户端自动登出跳登录页。与"登录 1、2 天后被踢回登录页"现象完全吻合。

## Evidence

- `kiki_server/src/utils/jwt.rs:73` — `expiry_hours: 24`（access token 24 小时过期）。
- `kiki_server/src/framework/bootstrap/routes/auth.rs:22-33` — 仅注册 LOGIN/REGISTER/AUTH_VERIFY/AUTH_LOGOUT，**无 refresh-token 路由**。
- `kiki_server/src/adapters/http/auth/dtos.rs:26` — 登录响应 DTO 仅含 `token`，不含 refresh token。
- `kiki_web/lib/core/network/interceptors/auth_interceptor.dart:57-78` — 401（非 auth 接口）直接 clearToken + logout，无 refresh 重试。
- `kiki_web/lib/data/repositories/auth_repository_impl.dart:42-92` — `login()` 只 setAccessToken，从不 setRefreshToken。
- `kiki_web/lib/data/repositories/auth_repository_impl.dart:194-216` — `refreshAccessToken()` 调用 `/api/v1/auth/refresh-token`（后端无此路由 -> 404）。
- `kiki_web/lib/presentation/controllers/auth_controller.dart:97-128` — `_checkLoginStatus()` 启动仅做本地状态判断，不做服务端续期。

## Affected Scope

- 后端：`kiki_server/src/utils/jwt.rs`、`src/framework/bootstrap/routes/auth.rs`、`src/adapters/http/auth/*`
- 前端：`kiki_web/lib/core/network/interceptors/auth_interceptor.dart`、`lib/data/repositories/auth_repository_impl.dart`、`lib/presentation/controllers/auth_controller.dart`
- 影响：所有登录用户的会话持久性

## Patch Plan

推荐方案 A（标准 refresh token 机制，最稳妥）：

1. 后端：登录响应同时下发 refresh_token（长效，如 30 天）与 access_token（短效，如 24h~7d）。
2. 后端：注册 POST /api/v1/auth/refresh-token 路由，校验 refresh token 后签发新的 access token。
3. 前端：登录时保存 refresh token（setRefreshToken）。
4. 前端：AuthInterceptor 收到 401 时，先尝试用 refresh token 静默续期并重放原请求；续期失败才登出跳转。

快速缓解方案 B（最小改动，先止血）：

1. 后端：将 jwt.rs 的 expiry_hours 从 24 调大（如 24*30 = 30 天），延长会话有效期。
2. 说明：不引入 refresh token，仅延长 access token 寿命，牺牲部分安全性换取体验，适合作为临时方案。

## Regression Risk

- 方案 A：中等。涉及前后端 token 流程改动，需回归登录/续期/登出/401 处理。
- 方案 B：低。仅改一个常量，需重新部署后端，旧 token 仍按旧寿命过期。

## Verification Plan

1. 后端：`cd kiki_server && cargo build`（及相关单测）。
2. 前端：`cd kiki_web && flutter analyze`。
3. 手动（方案 A）：登录 -> 令 access token 过期 -> 发起受保护请求 -> 验证自动续期且不跳登录页；refresh token 过期后才跳登录页。
4. 手动（方案 B）：登录 -> 等待 >24h 冷启动 -> 验证仍保持登录态。
