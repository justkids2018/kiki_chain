# Adapters 层说明

- **职责**：实现 `core::ports` 定义的接口，将业务逻辑连接到具体技术（数据库、HTTP、日志等）。
- **目录约定**：
  - `http/`：HTTP 控制器、路由处理器及相关适配逻辑。
  - `persistence/`：数据库实现（目前包含 PostgreSQL 用户仓储）。
- **依赖方向**：允许依赖 `core` 和第三方库，不得依赖 `framework`。
- **扩展指南**：
  - 新的持久化实现建议放在 `persistence/<tech>/`，文件命名 `*_repository.rs`。
  - 若需要额外适配器（如消息队列），请创建对应子目录并在此 README 中记录约定。
