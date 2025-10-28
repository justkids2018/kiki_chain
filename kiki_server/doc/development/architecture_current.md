# 现状架构记录（阶段0）

> 更新日期：2025-XX-XX  
> 记录目的：为Clean Architecture改造提供基线信息，明确当前实现和必须保留的功能。

## 构建与测试状态

- `cargo check` ✅
- `cargo test` ✅ （包含 doctest，`utils::http` 示例已标记为 `ignore`，不会参与编译执行）

结论：当前主干分支可正常编译与运行现有单元测试。

## 目录结构（Top-Level）

| 目录 | 说明 |
| --- | --- |
| `src/core` | 业务内核：实体、值对象、错误、端口接口，以及认证用例实现。 |
| `src/adapters` | 技术适配层：包含 PostgreSQL 用户仓储、认证控制器、HTTP 中间件。 |
| `src/framework` | 框架层：`bootstrap` 负责依赖注入与路由装配，`logging` 统一日志初始化。 |
| `src/config` | 配置加载逻辑，要求 `JWT_SECRET`、`DATABASE_URL`（开发环境缺省填充）。 |
| `src/utils` | 通用工具（JWT、HTTP 头解析等）。 |
| `src/shared` | 共享模块（API 响应包装等）。 |

> 注：业务核心已迁移至 `core`，下一步将继续拆分 `adapters / framework`。

## 关键模块职责

- **认证业务**
  - 用例：`core/use_cases/auth/login_user.rs`、`register_user.rs`
  - 控制器：`adapters/http/auth/controller.rs`
  - 路由处理器：`adapters/http/auth/routes.rs`
  - 路由装配：`framework/bootstrap/routes`（`auth.rs`、`main.rs`）
  - 仓储抽象：`core/ports/mod.rs::UserRepository`
  - 仓储实现：`adapters/persistence/postgres/user_repository.rs`
  - JWT 工具：`utils/jwt.rs`

- **配置与启动**
  - 配置加载：`config/mod.rs`
  - 依赖注入：`framework/bootstrap/container.rs`
  - 入口：`main.rs`

- **日志**
  - `framework/logging.rs`（统一日志初始化、便捷宏定义）

## 必须保留的功能

1. 用户登录接口（手机/邮箱 + 密码，返回 JWT）。
2. 用户注册接口（唯一性校验 + 新增用户）。
3. JWT 工具类（生成、验证、提取用户 ID）。
4. PostgreSQL 用户仓储实现（`UserRepository` 接口适配 SQLX）。
5. 配置系统（至少支持 `development`，并保留对 `JWT_SECRET` / `DATABASE_URL` 的要求）。

## 已知风险/待改进项

- Clean 架构主线目录已稳定，Stage5 完成后兼容层目录全部移除；需持续关注外部文档引用是否仍指向旧路径。
- `doc/dev` 与历史开发文档仍包含旧示例，Stage6 前需补充“已归档/示例用途”标注或更新内容。
- 核心用例仍缺少系统化的单元/集成测试，Stage6 计划补充。
- 需执行完整回归（`cargo test` + manual login/register 验证）确认移除兼容层后行为一致。

---

> 下一阶段进入 Stage6，聚焦测试与回归验证，准备最终总结。
