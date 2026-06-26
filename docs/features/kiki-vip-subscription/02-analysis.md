# Kiki VIP Subscription Analysis

> Created: 2026-06-23
> Status: DONE

## 现有实现概览

### 后端 `kiki_server`

- 技术栈：Rust + Axum + SQLx PostgreSQL。
- 路由入口：`kiki_server/src/framework/bootstrap/routes/`。
- 移动端公开场景接口：
  - `GET /api/v1/mobile/scene/categories`
  - `GET /api/v1/mobile/scene/categories/{category_id}/scenes`
  - `GET /api/v1/mobile/scene/{scene_id}`
- 移动端认证用户接口：
  - `GET /api/v1/mobile/user/profile`
- 用户实体已具备 VIP 字段：
  - `User::is_vip()`
  - `User::vip_expire_at()`
  - `User::is_vip_valid()`
  - `User::set_vip()`
  - `User::cancel_vip()`
- 登录响应和用户资料响应已经返回：
  - `is_vip`
  - `vip_expire_at`
- 当前缺口：
  - 没有订阅产品、订单、支付凭证记录表。
  - 没有统一支付/登录渠道管理层。
  - `UserRepository` 没有更新 VIP 到期的独立方法，只能 `save(user)`。
  - 场景 DTO 没有 `is_free` / `requires_vip` / `is_locked` 字段。

### 前端 `kiki_web`

- 技术栈：Flutter + GetX + Dio。
- 架构基线：`UI -> Controller -> Domain -> Repository -> DataSource/ApiService -> Network`。
- 首页分类页：`InteractiveImageHomePage` 展示分类。
- 卡片列表页：`SceneListPage` 展示分类下的场景卡片。
- 卡片点击逻辑：
  - 透明手势层统一处理点击。
  - 视觉卡片层通过 `IgnorePointer` 渲染。
  - 因此付费墙拦截必须放在 `SceneListController.navigateToSceneDetail()`，不能只放在 `SceneCard`。
- 当前缺口：
  - `Scene` 实体缺少付费字段。
  - `User` 实体没有解析/保存 `is_vip`、`vip_expire_at`。
  - 缺少 subscription/payment 的 domain/data/service/controller/page。
  - 缺少统一前端 `PaymentManager`，页面如果直接判断 iOS/Android 会造成耦合。

### API 文档

- 项目规范要求 API 文档先行，位置为 `docs/api/endpoints/`。
- 现有 `auth.md`、`scenes.md` 与当前 `/api/v1/mobile/...` 路由有历史差异。
- 本次不做大规模旧文档迁移，新增 `subscriptions.md`，并小范围更新 `scenes.md` 的付费字段说明。

## 复用点

- 后端用户 VIP 字段和实体行为可直接复用。
- 后端 `AppState` 已携带 `PgPool`，订阅模块可先使用 repository + use case 接入。
- 前端已有认证 token 注入、`RequestManager`、`HttpClient`、`ServiceLocator`。
- 前端卡片视觉组件 `SceneCard` 可扩展锁定遮罩，不需要重写列表布局。

## 设计约束

- 支付/登录渠道必须通过管理层解析，不允许在业务页面散落 `if iOS then IAP` 这类判断。
- 渠道管理输入：
  - `region`
  - `platform`
  - `distribution_channel`
  - 可选 `client_capabilities`
- 渠道管理输出：
  - payment provider
  - login providers
  - supported flag
  - reason/message
- 后续新增 Apple Pay、Google 登录、更多支付渠道时，应新增 provider/adapter 或配置项，而不是重写付费墙 UI。

## 风险点

- 真实 Apple IAP、微信支付、Google Play Billing 需要开发者后台和密钥；本仓库无法单独完成生产环境闭环。
- 当前注册/登录的数据字段在前后端命名不完全一致，新增 VIP 解析要兼容 `uid/id`、`name/nickname`。
- 数据库迁移目录里有旧 MySQL 风格学习表脚本，新增迁移需坚持 PostgreSQL 幂等写法。
- `SceneListPage` 的手势层与视觉层分离，若只加视觉锁不拦截 controller，会产生权限绕过。

## 文档差异点

- 新增 API 文档：`docs/api/endpoints/subscriptions.md`。
- 更新场景 API 文档：补充移动端场景列表付费字段。
- 新增功能设计/任务文档：`docs/features/kiki-vip-subscription/`。

## 建议实现顺序

1. API 文档与技术设计。
2. 后端订阅领域模型、渠道管理、repository、use case、路由和迁移。
3. 后端场景 DTO 增加免费/VIP 锁定字段。
4. 前端订阅 domain/data/manager 和用户 VIP 字段解析。
5. 前端场景卡片锁定视觉、点击拦截、订阅页面/弹框。
6. 构建、测试、自审和文档收口。

