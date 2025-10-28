# Clean Architecture 改造蓝图（阶段1）

> 更新日期：2025-XX-XX  
> 目标：将现有分层结构重构为更清晰的 Clean Architecture，确保依赖方向只指向业务核心。

## 一、总体原则

1. **依赖向内**：外层（Adapters/Framework）只能依赖内层（Core），内层绝不引用外层实现。
2. **职责单一**：目录名即职责说明，任何非该职责的代码禁止放入。
3. **数据只向外暴露 DTO**：HTTP、DB等适配层负责转换；Core 只处理业务实体与 VO。
4. **文档与注释同步**：每个目录包含 README 简述职责与扩展方式。

## 二、目标目录结构

```
src/
  core/                          # 业务内核（不依赖外层）
    entities/                    # 实体、值对象
    use_cases/                   # 用例服务（按领域划分子目录）
      auth/
    ports/                       # 抽象接口（Repository / Gateway）
    errors.rs

  adapters/                      # 技术适配层（实现 core::ports）
    persistence/
      postgres/
        user_repository.rs
    http/
      auth/
        controller.rs
        routes.rs
    logging/                     # 日志适配（保留现有实现）

  framework/                     # 框架与启动层（生命周期管理）
    config/
    bootstrap/                   # 依赖注入、路由组合
      container.rs
      router.rs
    utils/                       # JWT、通用工具（仅提供给 framework/adapters 调用）

  main.rs                        # 入口，仅进行初始化与启动
```

> `shared` 目录可并入 `core`（若为纯业务 DTO）或 `adapters/http`（若为响应包装）。待迁移时具体判断。

## 三、命名与边界规范

| 层级 | 允许依赖 | 禁止依赖 | 说明 |
| --- | --- | --- | --- |
| `core` | Rust 标准库、第三方无副作用库 | `adapters`、`framework` | 保持纯业务逻辑；所有外部协作通过 `ports` 抽象。 |
| `adapters` | `core` + 必需第三方 | 其它 adapters（除非共享库） | 每个适配器只实现一个 `port`；HTTP 层使用 use case DTO。 |
| `framework` | `core`、`adapters` | — | 负责组合应用、提供配置、工具。 |

额外约束：
- `core::use_cases` 对外仅暴露输入/输出结构体，内部可调用 `ports`。
- 所有 trait 放在 `core::ports` 下，命名统一 `<功能>Port` 或 `<功能>Repository`。
- `adapters` 中的实现文件命名格式：`<tech>/<功能>_<实现>.rs`。

## 四、迁移优先级

1. **认证模块（登录/注册）**：最小可行功能，迁移后保证服务可跑。
2. **配置与启动流程**：改造 `framework/bootstrap`，与新目录结构对齐。
3. **共享模块 & 工具**：按使用场景分配到 `core` 或 `framework`。
4. **文档同步与历史文件归档**：旧功能说明（老师作业等）若暂不恢复，统一移至 `doc/archive/`。

> 后续新增业务（如老师作业）时，直接在 `core/use_cases/<bounded_context>` 下扩展，再在 `adapters` 增加实现。

## 五、实施清单（阶段划分）

| 阶段 | 工作内容 | 验收标准 |
| --- | --- | --- |
| 阶段2 | 搬迁 `domain`/`application` → `core`，建立 `ports` 并更新引用 | `cargo check/test`，`core/README` 完成 |
| 阶段3 | 重组 `infrastructure`/`presentation` → `adapters`，拆分控制器与路由 | `cargo check/test`，`adapters/http` 文档完成 |
| 阶段4 | 新建 `framework/bootstrap`，调整 `main.rs` | `cargo run` 成功，依赖注入说明文档完成 |
| 阶段5 | 文档与注释补全，清理遗留目录/文件 | 所有 README 更新，确认无未使用模块 |
| 阶段6 | 全量回归测试与总结 | `cargo test`、手动登入注册验证，变更总结发布 |

## 六、文档与工具要求

- 每完成一个阶段，更新 `doc/development/clean_architecture_plan.md` 的“进度”章节。
- 在 PR / 提交信息中引用对应阶段与任务，便于回溯。
- 考虑后续引入 lint/脚本（如 `cargo-deny`）防止出现跨层循环依赖。

## 七、进度记录

- [x] 阶段0：现状确认（记录目录与状态）
- [x] 阶段1：Clean Architecture 蓝图编制
- [x] 阶段2：核心层迁移至 `src/core`
- [x] 阶段3：适配层迁移至 `adapters`
- [x] 阶段4：框架层迁移至 `framework`
- [x] 阶段5：文档与注释补全
- [ ] 阶段6：最终回归测试与总结

---

> 下一步：进入阶段6，执行全量回归测试并整理最终总结。
