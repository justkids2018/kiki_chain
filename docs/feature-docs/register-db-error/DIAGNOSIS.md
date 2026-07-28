# Register database error diagnosis

## Failure Signature

线上新账号注册返回 `errorcode: 501`，提示 `数据库错误: 保存用户失败`。

## Root Cause

移动端注册请求显式提交 `role_type: 0`，但线上 `users` 表约束 `chk_users_role_type` 只允许 `1` 或 `2`。后端在保存用户时直接把 `0` 写入 `users.role_type`，PostgreSQL 拒绝插入，错误被包装成“数据库错误 / 保存用户失败”。

## Evidence

- 线上后端日志：注册请求体包含 `"role_type": 0`。
- 线上后端日志：`new row for relation "users" violates check constraint "chk_users_role_type"`。
- 线上数据库约束：`CHECK ((role_type = ANY (ARRAY[1, 2])))`。
- 前端代码：`kiki_web/lib/data/services/api/auth_api_service.dart` 曾在注册请求中固定传 `role_type: 0`。

## Affected Scope

- 移动端新用户注册。
- 仍发送 `role_type: 0` 的旧客户端注册请求。

## Patch Plan

1. 移动端注册请求改为发送普通用户角色 `role_type: 1`。
2. 后端注册用例兼容旧客户端，将 `role_type: 0` 归一化为普通用户 `1`，未知角色值在保存前返回参数校验错误。
3. 同步注册 API 文档中的路径、字段和角色说明。
4. 增加后端单元测试覆盖 `role_type: 0 -> 1` 和非法角色拒绝。

## Regression Risk

低。变更只影响注册角色字段归一化，不改变登录、已注册用户或数据库结构。

## Verification Plan

1. `cargo test register_ --lib`
2. `flutter analyze --no-pub`
3. 线上发版后，用新手机号注册，期望返回 `201` 和 `role_type: 1`。
