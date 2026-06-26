# Kiki VIP Subscription Technical Design

> Created: 2026-06-23
> Status: APPROVED_WITH_CONSTRAINTS

## 目标

实现一套低耦合的 VIP 商业化能力：

1. 首页场景列表第 1 张免费，第 2 张起需要 VIP。
2. 服务端统一维护 VIP 权益、订阅产品、订阅订单。
3. 支付/登录渠道通过公共管理层解析，支持后续扩展 Apple Pay、Google 登录、更多支付渠道。
4. 前端页面不直接耦合具体支付 SDK，而是通过 `PaymentManager` 调度。

## 总体架构

```text
Flutter SceneListPage
  -> SceneListController
  -> SubscriptionController / PaymentManager
  -> SubscriptionRepository
  -> SubscriptionApiService
  -> kiki_server subscription APIs
  -> SubscriptionUseCase
  -> ChannelPolicy + SubscriptionRepository
  -> PostgreSQL
```

## 后端设计

### 新增领域模型

- `RegionCode`: `cn` / `global`
- `ClientPlatform`: `ios` / `android` / `web` / `wechat_miniprogram` / `h5`
- `DistributionChannel`: `app_store` / `wechat` / `google_play` / `direct_apk` / `web` / `unknown`
- `PaymentChannel`: `apple_iap` / `wechat_pay` / `google_play_billing` / `apple_pay` / `unsupported`
- `LoginProvider`: `apple` / `wechat` / `google` / `phone`
- `SubscriptionPeriod`: `monthly` / `yearly`
- `SubscriptionOrderStatus`: `pending` / `paid` / `failed` / `cancelled`

### 渠道管理层

后端新增 `ChannelPolicy`：

```text
resolve(region, platform, distribution_channel, capabilities)
  -> ChannelResolution {
       payment_channel,
       login_providers,
       supported,
       reason,
       message
     }
```

规则：

| 条件 | 支付渠道 | 登录渠道 |
|------|----------|----------|
| CN + iOS | Apple IAP | Apple + WeChat 可选 |
| CN + Android | WeChat Pay | WeChat + Phone |
| Global + iOS | Apple IAP | Apple |
| Global + Android + Google Play | Google Play Billing | Google |
| WeChat Mini Program / H5 | WeChat Pay | WeChat |
| Unknown | Unsupported | Phone |

Apple Pay 作为可扩展 provider 保留枚举和 adapter 位，不作为数字内容解锁默认支付。

### API

新增 `docs/api/endpoints/subscriptions.md`，包含：

- `POST /api/v1/mobile/subscriptions/channel/resolve`
- `GET /api/v1/mobile/subscriptions/products`
- `GET /api/v1/mobile/subscriptions/entitlement`
- `POST /api/v1/mobile/subscriptions/orders`
- `POST /api/v1/mobile/subscriptions/orders/{order_id}/confirm`

### 数据库

新增迁移 `006_subscription_commercialization.sql`：

- `subscription_products`
- `subscription_orders`
- `subscription_events`
- `users.vip_expire_at` / `users.is_vip` 幂等兜底
- `scenes.requires_vip` / `scenes.is_free` 幂等兜底

### 权益策略

- 场景列表接口按 `display_order` 排序。
- 第 1 张：`is_free=true`、`requires_vip=false`、`is_locked=false`。
- 第 2 张起：`is_free=false`、`requires_vip=true`。
- 服务端当前公开场景列表接口没有用户 token，无法知道当前用户是否 VIP；因此列表字段只返回 `requires_vip`，前端结合本地用户权益计算 `is_locked`。
- 认证接口和 `GET /mobile/subscriptions/entitlement` 返回当前用户 VIP 权益。

## 前端设计

### Domain/Data

新增：

- `domain/entities/subscription.dart`
- `domain/repositories/i_subscription_repository.dart`
- `data/services/api/subscription_api_service.dart`
- `data/repositories/subscription_repository_impl.dart`

### PaymentManager

新增 `core/services/payment/payment_manager.dart`：

- 输入产品、客户端上下文、服务端渠道解析结果。
- 输出统一 `PaymentResult`。
- 具体 provider 通过 adapter 分派：
  - `AppleIapPaymentAdapter`
  - `WechatPayPaymentAdapter`
  - `GooglePlayBillingPaymentAdapter`
  - `UnsupportedPaymentAdapter`
- 首版 adapter 可返回 sandbox/mock 结果或 Unsupported，不把 SDK 逻辑写入页面。

### UI

新增 `presentation/features/subscription/`：

- `controllers/subscription_controller.dart`
- `pages/subscription_page.dart`
- `widgets/subscription_plan_tile.dart`

改造：

- `Scene` 增加 `isFree`、`requiresVip`、`isLocked`。
- `User` 增加 `isVip`、`vipExpireAt`。
- `SceneCard` 显示锁定遮罩。
- `SceneListController.navigateToSceneDetail` 先判断 `scene.requiresVip && !currentUser.isVip`，满足时进入订阅页。

## 工程评审

### 结论

APPROVED_WITH_CONSTRAINTS，可以进入实现。

### 必须遵守

1. 不把三方支付 SDK 调用写入 `SceneListPage` 或 `SceneCard`。
2. 订单确认接口不得在生产环境只信客户端；当前 mock/sandbox 路径必须明确标识。
3. 前端视觉锁和 controller 拦截必须同时存在。
4. API 文档必须先于后端/前端代码落地。

### 风险与缓解

- 高风险：真实支付校验依赖外部密钥。缓解：adapter 化，未配置时走 sandbox/Unsupported。
- 中风险：公开场景接口无法知道用户 VIP。缓解：场景接口返回 `requires_vip`，前端结合用户权益计算锁定态；后续可增加带认证的 personalized scenes 接口。
- 中风险：旧 API 文档不完全一致。缓解：新增订阅文档作为本次唯一新增契约，小范围补充 scenes 字段。

