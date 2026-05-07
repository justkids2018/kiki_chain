# AGENT.md

## 目标
本文件用于让协作 Agent 快速理解 Hi Kiki 项目，并在你发出“启动本地服务”等指令时，直接执行统一命令。

## 项目总览

### 仓库定位
Hi Kiki 是一个三端协作项目：
1. `kiki_web/`：Flutter 学习端（移动端为主）
2. `kiki_admin/`：Vue 3 管理后台（内容与运营管理）
3. `kiki_server/`：Rust 后端 API（业务与数据核心）

补充目录：
1. `dream_web/`：独立静态站/原型资源
2. `docs/`：跨端共享文档与数据库初始化 SQL
3. `scripts/dev/`：本地一键启停脚本
4. `scripts/deploy/`：远端部署脚本（当前面向阿里云）

注意：根 README 中历史上出现过 `kiki_web_manager/` 名称，当前实际管理后台目录为 `kiki_admin/`。

## 架构规则

### 1) 总体规则（三端协作）
1. `kiki_server/` 是业务真源（鉴权、领域逻辑、数据访问）。
2. `kiki_admin/` 与 `kiki_web/` 只通过 API 与后端交互，避免前端绕过后端直连数据库。
3. 数据结构变更优先走 SQL 迁移文件（`kiki_server/migrations/`）并同步文档。
4. 生产部署使用 Docker Compose，服务编排以根目录 `docker-compose.prod.yml` 为准。

### 2) 后端规则（Rust Clean Architecture）
依据 `kiki_server/doc/framwork/clean_architecture_2026.md`：
1. 分层方向：`framework -> adapters -> core`，禁止反向依赖。
2. `core/` 只放领域模型、用例、端口接口，不依赖外层实现。
3. `adapters/` 负责 HTTP 与持久化实现（Repository 实现放这里）。
4. `framework/` 负责启动、路由装配、依赖注入。
5. 统一响应结构放 `shared/`，通用工具放 `utils/`。

### 3) 前端规则
1. `kiki_admin/`：Vue 3 + TypeScript + Element Plus，状态管理 Pinia。
2. `kiki_web/`：Flutter + GetX（含多平台目录）。
3. 前端配置与接口地址统一从环境配置读取，避免在页面硬编码域名。

## 设计原则
1. 单一职责：每个子项目聚焦单一业务角色（学习端、管理端、服务端）。
2. 可替换部署：业务代码尽量不耦合具体云厂商，云资源细节收敛在部署脚本和配置。
3. 先可运行再优化：优先保证本地可启动、可联调，再做性能和架构细化。
4. 变更可追踪：数据库与部署策略变更必须同时更新文档（本文件 + `CLOUD.md`）。

## 本地启动（标准流程）

### 一键启动（推荐）
在仓库根目录执行：

```bash
bash scripts/dev/dev-start.sh
```

启动内容：
1. PostgreSQL（Docker，容器名 `hikiki_postgres_local`）
2. Rust 后端（默认 `http://localhost:8081`）
3. Admin 前端（Vite 端口自动分配，默认 5173）

停止：

```bash
bash scripts/dev/dev-stop.sh
```

### 分服务启动（按需）
1. 仅数据库：
```bash
bash kiki_server/scripts/db-start.sh
```
2. 启动后端：
```bash
cd kiki_server
ENVIRONMENT=development DATABASE_URL=postgresql://postgres:postgres@localhost:5432/hikiki_db cargo run
```
3. 启动管理后台：
```bash
cd kiki_admin
npm install
npm run dev
```
4. 启动 Flutter 端：
```bash
cd kiki_web
flutter pub get
flutter run
```

## Agent 执行约定
当你说“启动本地服务”时，默认执行以下动作：
1. 在仓库根目录运行 `bash scripts/dev/dev-start.sh`
2. 回传后端和管理后台访问地址
3. 若启动失败，优先回传失败步骤与日志路径（如 `/tmp/kiki_server.log`、`/tmp/kiki_admin.log`）

当你说“停止本地服务”时，默认执行：

```bash
bash scripts/dev/dev-stop.sh
```

## 快速自检清单
1. Docker Desktop 已启动
2. 本地 5432/8081/5173 端口未被占用
3. `kiki_admin/` 已安装依赖
4. Rust 工具链可用（`cargo --version`）
5. Flutter 工具链可用（`flutter --version`）

## 文档维护规则
1. 新增服务、端口或脚本后，必须更新本文件。
2. 云端地址、域名、部署流程变化时，同时更新 `CLOUD.md`。
3. 若后续切腾讯云，先保留现状字段，再增量替换，避免“迁移中断档”。
