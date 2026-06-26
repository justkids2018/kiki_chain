# Kiki VIP Subscription Requirement

> Source: `docs/business/二期商业化方案-VIP订阅与支付-20260621.md`
> Created: 2026-06-23
> Status: Confirmed for implementation

## 功能名称

Kiki 二期 VIP 付费墙、订阅与渠道支付统一能力

## 背景与动机

- **解决什么问题**：现有场景卡片全部免费，二期需要转为“首页首张免费 + 后续 VIP”并支持订阅购买。
- **当前痛点**：前端缺少锁定态和订阅入口，服务端缺少统一 VIP 状态、订阅产品、支付渠道判断与订单校验承载。
- **不做会怎样**：无法形成商业化闭环，也无法按 iOS、Android、微信/H5、Google Play 等渠道满足支付合规要求。

## 用户故事

- US-1: 作为未付费用户，我希望能免费体验首页第 1 张卡片，以便判断产品是否适合孩子。
- US-2: 作为未付费用户，我希望看到第 2 张起卡片的 VIP 锁定态，并能点击进入订阅购买，以便解锁全部卡片。
- US-3: 作为 VIP 用户，我希望首页所有卡片都可正常进入，以便连续学习。
- US-4: 作为客户端，我希望能根据地区、平台、发行渠道获得支付方式，以便走合规支付链路。
- US-5: 作为服务端，我希望统一维护用户 VIP 到期时间和订阅状态，以便前后端一致判断访问权限。

## 子需求点

| ID | 子需求 | 状态 | 备注 |
|----|--------|------|------|
| R-1 | 首页卡片付费墙：第 1 张永久免费，第 2 张起需要 VIP | 已澄清 | 来源业务文档已勾选：免费卡范围为首页列表第 1 张 |
| R-2 | 前端卡片锁定态：非 VIP 付费卡置灰、灰色遮罩、显示 VIP/解锁/锁标识 | 已澄清 | 点击锁定卡片进入订阅弹框或支付页 |
| R-3 | 订阅档位：月订阅 9.9 元/月，年订阅 88 元/年 | 已澄清 | 来源业务文档已勾选 |
| R-4 | 支付/登录渠道管理：按 region/platform/distributionChannel 统一解析支付与登录 Provider | 已澄清 | 需要做成管理类/管理层，后续可低耦合添加 Apple Pay、Google 登录、更多支付渠道 |
| R-5 | 服务端 VIP 状态：统一维护 `vip_expire_at`，客户端以服务端返回为准 | 已澄清 | 当前登录响应和用户资料已存在 `is_vip` / `vip_expire_at` 字段，继续沿用 |
| R-6 | 支付闭环：创建订单、接收渠道凭证/回调、校验后刷新 VIP 状态 | 已澄清 | 首版实现统一订单与可扩展 Provider Adapter；真实三方校验通过 adapter 扩展，未配置时返回 sandbox/mock 结果或 Unsupported |
| R-7 | 登录渠道管理：iOS 支持 Apple，国内可支持微信，国外可支持 Google | 已澄清 | 本期先纳入统一渠道能力与返回结构，具体 OAuth SDK 可逐步接入 |
| R-8 | 年付 3 天免费试用 | 已澄清 | 先作为产品配置字段支持，是否对用户展示由产品配置控制 |
| R-9 | 国外 Android Google Play Billing | 已澄清 | 默认 Google Play Billing；渠道不支持时返回 Unsupported |
| R-10 | 前端通过统一管理服务调用订阅/支付能力 | 已澄清 | 页面不直接判断具体 SDK；由前端 payment manager 根据服务端 channel result 分派 |

## 验收标准

- AC-1: Given 用户不是 VIP，When 打开首页卡片列表，Then 第 1 张卡片可直接进入，第 2 张及之后显示锁定态。
- AC-2: Given 用户不是 VIP，When 点击第 2 张及之后的卡片，Then 显示订阅入口，并提供月订阅 9.9 元/月与年订阅 88 元/年。
- AC-3: Given 用户是有效 VIP，When 打开首页卡片列表，Then 所有卡片均不显示锁定遮罩，点击任一卡片可进入学习页。
- AC-4: Given 客户端请求支付渠道，When region/platform/distributionChannel 分别为国内 iOS、国内 Android、国外 iOS、国外 Android、微信/H5 或未知渠道，Then 服务端返回对应支付渠道或 Unsupported。
- AC-5: Given 支付成功或订阅凭证校验成功，When 客户端刷新用户权益，Then 服务端返回新的 `is_vip=true` 与 `vip_expire_at`。
- AC-6: Given 支付失败、取消支付或渠道 Unsupported，When 用户返回卡片列表，Then VIP 状态不改变，并显示明确提示。
- AC-7: Given API 文档定义了订阅/权益接口，When 前后端实现完成，Then 响应结构必须与 `docs/api/endpoints/` 文档一致。
- AC-8: Given 后续新增 Apple Pay、Google 登录或其他支付 Provider，When 新增 provider 配置或 adapter，Then 不需要修改首页卡片付费墙 UI 的核心判断逻辑。

## 边界 / 不在范围内

- 不在首轮实现复杂营销活动、优惠券、家庭共享、补差价升级等订阅运营能力。
- 不在首轮支持每个场景首张免费，免费范围只按首页列表整体第 1 张计算。
- 不在首轮把 Apple、微信、Google 三方支付 SDK 全量真实生产接入作为硬性前置；本期重点是统一管理能力、API 契约、订单/权益闭环和前端接入点。
- 不允许客户端单方面决定 VIP 权益，最终状态以服务端为准。

## 数据需求

- 新增或扩展用户权益字段：`vip_expire_at`、`is_vip`。
- 新增订阅产品配置：`product_id`、`period`、`price_cents`、`currency`、`payment_channel`、`enabled`。
- 新增订阅/订单记录：`user_id`、`product_id`、`platform`、`payment_channel`、`purchase_token`、`expire_at`、`status`。
- 卡片列表响应新增或派生：`is_free`、`requires_vip`、`is_locked`。
- 数据迁移需要：是。

## 非功能需求

- **性能**：首页卡片列表权益判断不应显著增加首屏耗时；VIP 状态可随用户信息或列表接口一起返回。
- **安全**：支付成功不得只信客户端，生产环境必须校验渠道凭证或支付回调。
- **兼容性**：老版本客户端没有锁定字段时，服务端仍应保持卡片数据基础字段兼容。
- **可观测**：记录支付渠道解析、订单创建、凭证校验、VIP 状态变更的关键日志。

## 风险与未知

- 风险 1：真实 IAP、微信支付、Google Play Billing 接入需要开发者后台配置和密钥，当前仓库可能不具备完整生产凭证。
- 风险 2：过早把具体 SDK 写入页面会造成后续渠道扩展困难，因此需要管理类/管理层隔离。
- 未知 1：生产环境 Apple/微信/Google 账号、商户号、回调地址与密钥配置需要部署前补齐。

## 关联

- 业务需求：`docs/business/二期商业化方案-VIP订阅与支付-20260621.md`
- API 契约：计划新增 `docs/api/endpoints/subscriptions.md`，并按需更新 `docs/api/endpoints/scenes.md` 与 `docs/api/endpoints/auth.md`
- 前端实现：`kiki_web`
- 后端实现：`kiki_server`

## 对齐确认

- [x] 用户已确认所有子需求点（R-1 ~ R-10）
- [x] 用户已确认验收标准
- [x] 用户已确认 Out of Scope
