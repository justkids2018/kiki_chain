# 订阅与渠道管理接口

> 版本：v1.0
> 更新时间：2026-06-23
> 范围：移动端 VIP 订阅、支付/登录渠道解析、订单确认、用户权益查询

## 通用枚举

### region

| 值 | 说明 |
|----|------|
| `cn` | 国内 |
| `global` | 国外/国际 |

### platform

| 值 | 说明 |
|----|------|
| `ios` | iOS App |
| `android` | Android App |
| `web` | Web |
| `wechat_miniprogram` | 微信小程序 |
| `h5` | H5 |

### distribution_channel

| 值 | 说明 |
|----|------|
| `app_store` | Apple App Store |
| `google_play` | Google Play |
| `wechat` | 微信生态 |
| `direct_apk` | 国内安卓直装包 |
| `web` | Web/H5 |
| `unknown` | 未识别渠道 |

### payment_channel

| 值 | 说明 |
|----|------|
| `apple_iap` | Apple App 内购，数字内容默认渠道 |
| `wechat_pay` | 微信支付 |
| `google_play_billing` | Google Play Billing |
| `apple_pay` | Apple Pay，保留扩展位，不作为本期数字内容默认渠道 |
| `unsupported` | 当前渠道不支持购买 |

### login_provider

| 值 | 说明 |
|----|------|
| `apple` | Sign in with Apple |
| `wechat` | 微信登录 |
| `google` | Google 登录 |
| `phone` | 手机号登录 |

---

## 解析支付与登录渠道

**接口描述**：根据地区、平台、发行渠道和客户端能力，统一解析本次可用的支付渠道与登录方式。

**请求方式**：POST

**接口路径**：`/api/v1/mobile/subscriptions/channel/resolve`

**认证**：可选。未登录也可以解析渠道。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| region | string | 是 | 地区 | `cn` |
| platform | string | 是 | 平台 | `ios` |
| distribution_channel | string | 否 | 发行渠道 | `app_store` |
| client_capabilities | string[] | 否 | 客户端支持能力 | `["apple_iap"]` |

**请求示例**：

```json
{
  "region": "cn",
  "platform": "ios",
  "distribution_channel": "app_store",
  "client_capabilities": ["apple_iap", "apple_login"]
}
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 是否成功 |
| data.payment_channel | string | 支付渠道 |
| data.login_providers | string[] | 推荐登录方式 |
| data.supported | boolean | 是否支持购买 |
| data.reason | string | 机器可读原因 |
| data.message | string | 用户可读提示 |

**响应示例**：

```json
{
  "success": true,
  "data": {
    "payment_channel": "apple_iap",
    "login_providers": ["apple", "wechat"],
    "supported": true,
    "reason": "ios_digital_content_requires_iap",
    "message": "iOS 数字内容将使用 Apple App 内购"
  },
  "message": "解析成功"
}
```

---

## 获取订阅产品

**接口描述**：获取当前渠道可购买的 VIP 订阅产品。

**请求方式**：GET

**接口路径**：`/api/v1/mobile/subscriptions/products`

**认证**：可选。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| region | string | 否 | 地区，默认 `cn` | `cn` |
| platform | string | 否 | 平台 | `ios` |
| distribution_channel | string | 否 | 发行渠道 | `app_store` |

**响应示例**：

```json
{
  "success": true,
  "data": {
    "payment_channel": "apple_iap",
    "products": [
      {
        "product_id": "kiki_vip_monthly",
        "title": "连续包月",
        "period": "monthly",
        "price_cents": 990,
        "currency": "CNY",
        "display_price": "¥9.9/月",
        "trial_days": 0,
        "is_recommended": false
      },
      {
        "product_id": "kiki_vip_yearly",
        "title": "连续包年",
        "period": "yearly",
        "price_cents": 8800,
        "currency": "CNY",
        "display_price": "¥88/年",
        "trial_days": 3,
        "is_recommended": true
      }
    ]
  },
  "message": "获取成功"
}
```

---

## 获取我的 VIP 权益

**接口描述**：获取当前登录用户的 VIP 权益状态。

**请求方式**：GET

**接口路径**：`/api/v1/mobile/subscriptions/entitlement`

**认证**：Bearer Token 必填。

**响应示例**：

```json
{
  "success": true,
  "data": {
    "is_vip": true,
    "vip_expire_at": "2026-07-23T12:00:00Z",
    "source": "subscription",
    "server_time": "2026-06-23T12:00:00Z"
  },
  "message": "获取成功"
}
```

---

## 创建订阅订单

**接口描述**：创建订阅订单，返回客户端拉起支付所需的统一订单信息。

**请求方式**：POST

**接口路径**：`/api/v1/mobile/subscriptions/orders`

**认证**：Bearer Token 必填。

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| product_id | string | 是 | 订阅产品 ID | `kiki_vip_monthly` |
| region | string | 是 | 地区 | `cn` |
| platform | string | 是 | 平台 | `android` |
| distribution_channel | string | 否 | 发行渠道 | `direct_apk` |

**响应示例**：

```json
{
  "success": true,
  "data": {
    "order_id": "sub_ord_20260623120000_abcd1234",
    "product_id": "kiki_vip_monthly",
    "payment_channel": "wechat_pay",
    "status": "pending",
    "amount_cents": 990,
    "currency": "CNY",
    "payment_payload": {
      "mode": "sandbox",
      "provider": "wechat_pay"
    }
  },
  "message": "创建成功"
}
```

---

## 确认订阅订单

**接口描述**：提交支付渠道凭证或 sandbox 确认，服务端校验后更新用户 VIP 权益。

**请求方式**：POST

**接口路径**：`/api/v1/mobile/subscriptions/orders/{order_id}/confirm`

**认证**：Bearer Token 必填。

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| order_id | string | 是 | 订单 ID | `sub_ord_20260623120000_abcd1234` |

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| purchase_token | string | 否 | 渠道购买凭证 | `sandbox_success` |
| sandbox | boolean | 否 | 是否 sandbox 确认 | `true` |

**响应示例**：

```json
{
  "success": true,
  "data": {
    "order_id": "sub_ord_20260623120000_abcd1234",
    "status": "paid",
    "is_vip": true,
    "vip_expire_at": "2026-07-23T12:00:00Z"
  },
  "message": "确认成功"
}
```

**错误码说明**：

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 400 | 参数错误或渠道不支持 | 检查渠道参数 |
| 401 | 未登录 | 重新登录 |
| 404 | 订单不存在 | 重新创建订单 |
| 500 | 服务端错误 | 稍后重试 |

