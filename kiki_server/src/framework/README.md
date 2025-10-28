# Framework 层说明

- **职责**：处理应用启动流程、依赖注入、配置加载以及路由组合。
- **结构**：
  - `bootstrap/`：包含容器(`container.rs`)、路由(`routes/`)、API 常量(`api_paths.rs`)、日志/数据库初始化函数。
- **依赖方向**：可以依赖 `core`、`adapters` 以及第三方库；不应引入业务逻辑。
- **扩展指引**：
  - 若新增中间件或全局组件，请在 `bootstrap` 中集中配置。
  - 未来若需要配置模块，可在 `framework/config` 下补充说明文件。
