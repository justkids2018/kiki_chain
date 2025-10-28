# Core 层说明

- **职责**：封装业务内核（实体、值对象、领域错误、端口接口、用例逻辑）。
- **依赖方向**：仅依赖标准库与无副作用第三方库；不允许引用 `adapters`、`framework`。
- **扩展规则**：
  - 新实体放入 `entities/`，必要的值对象在 `value_objects.rs` 中维护。
  - 所有外部依赖都通过 `ports/` 定义 trait；禁止在用例中直接调用数据库/HTTP SDK。
  - 用例放在 `use_cases/<bounded_context>/`，输入输出使用 `Command/Response` 结构。

> 注意：若新增业务上下文，请在 `use_cases` 下创建子目录并添加模块说明，保持边界清晰。
