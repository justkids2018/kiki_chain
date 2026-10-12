## Failure Signature

注册页面显示 `请求失败 (409): HTTP 异常状态码: 409`，用户误以为所有网络请求失败。

## Root Cause

注册请求已到达正式环境，服务端以 HTTP 409 报告手机号已注册。iOS `APIClient` 在解析服务端 JSON 错误内容之前就根据 HTTP 状态抛出通用异常，导致真正的业务提示丢失。登录请求使用的 `phone` 字段由服务端 `identifier` 的 serde alias 支持，并非本次故障原因。

## Evidence

- 正式环境只读 `GET /api/v1/mobile/scene/categories` 返回 HTTP 200。
- 服务端注册用例 `ensure_unique_phone` 在重复手机号时返回 `AlreadyExists`，API 层映射为 HTTP 409。
- iOS `APIClient.request` 原实现先执行状态码 `switch`，之后才解码 `APIResponse`。

## Affected Scope

iOS 所有返回非 2xx 且附带业务 `message` 的接口；截图中的注册是可见案例。

## Patch Plan

在处理非 2xx 响应时优先提取服务端 `message`，无法提取时保留现有状态码兜底错误。

## Regression Risk

影响所有 HTTP 错误提示的显示文案；成功响应的解析路径不变。

## Verification Plan

1. 构建 iOS Simulator 目标。
2. 使用已有账号注册时应显示服务端的账号冲突提示；切换登录并输入正确密码后应正常进入应用。
3. 未授权、超时和断网场景应仍显示相应错误。
