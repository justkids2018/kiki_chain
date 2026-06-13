# Kiki Chain

> Hi Kiki 产品工程仓库：移动端学习 App、Rust 后端、Vue 管理后台和产品官网静态页。

Kiki Chain 当前服务于 **Hi Kiki**：一个面向儿童启蒙阶段的场景式识字与英语学习产品。孩子从生活、校园、故事和探索场景进入学习，在画面中认识汉字、英文词汇和声音；家长可以看到孩子的学习轨迹。

本仓库同时包含品牌与产品介绍静态页，用于承载「奇思蔓想」个人产品品牌和 Hi Kiki 下载页。

---

## 项目组成

```text
kiki_chain/
├── kiki_web/           # Flutter 移动端 App，Android / iOS
├── kiki_server/        # Rust 后端 API 服务
├── kiki_admin/         # Vue 3 管理后台
├── kiki_product_html/  # 产品官网与下载页静态站
├── docs/               # 项目级共享文档、API、架构、部署文档
├── nginx/              # 生产反向代理配置
├── scripts/            # 本地开发、发布部署脚本
└── .github/workflows/  # CI、移动端打包、Docker、静态站发布
```

### 子系统职责

| 子系统 | 目录 | 职责 | 主要技术 |
|---|---|---|---|
| 移动端 App | `kiki_web/` | 儿童学习端，负责场景学习、卡片互动、语音、笔顺、学习记录、更新提示 | Flutter, GetX, Dio, cached_network_image |
| 后端 API | `kiki_server/` | 认证、用户、场景、卡片、资源、管理后台接口 | Rust, Axum, Tokio, SQLx, PostgreSQL |
| 管理后台 | `kiki_admin/` | 内容运营与管理，包含场景、物品、热区、用户、统计等 | Vue 3, Vite, TypeScript, Element Plus, Pinia |
| 产品静态站 | `kiki_product_html/` | 品牌页、Hi Kiki 下载页、版本 JSON 与静态资源 | HTML, CSS, GitHub Actions 静态发布 |
| 部署层 | `docker-compose.prod.yml`, `nginx/` | 后端、管理后台、数据库、Nginx、证书续期 | Docker Compose, Nginx, Certbot |

---

## 核心技术方案

### 1. App 端技术方案

`kiki_web` 是 Flutter App，主要面向 Android 和 iOS。

核心选择：

- **状态与路由**：GetX 负责页面路由、Controller 和响应式状态。
- **网络访问**：Dio / http 访问后端 API。
- **图片加载**：统一使用带缓存的图片组件，降低学习卡片和场景图加载抖动。
- **本地存储**：shared_preferences、flutter_secure_storage、get_storage 保存轻量配置、认证和本地状态。
- **学习交互**：学习卡片、互动图片、热区点击、音频播放、笔顺动画等由 Flutter UI 层实现。
- **资源与发布**：App icon、启动图、音频、场景 JSON、字体和配置统一放在 `kiki_web/assets/` 和 `kiki_web/config/`。

架构规则见：

- [kiki_web Flutter 简化 DDD 架构](docs/architecture/kiki_web_flutter_simplified_ddd_architecture.md)
- [kiki_web Flutter 简化 DDD 实施指南](docs/architecture/kiki_web_flutter_simplified_ddd_implementation_guide.md)

App 端主要分层：

```text
presentation  -> 页面、Controller、Widget、用户交互
domain        -> 实体、仓储抽象、业务规则
data          -> DTO、数据源、仓储实现
core          -> 网络、日志、异常、基础设施
services      -> 跨功能技术服务
utils         -> 无业务耦合工具
```

依赖方向以 `presentation -> domain -> data -> core/services` 为主，避免 UI 直接调用网络或存储。

### 2. 后端技术方案

`kiki_server` 是 Rust 后端服务。

核心选择：

- **Web 框架**：Axum 0.8。
- **异步运行时**：Tokio。
- **数据库访问**：SQLx + PostgreSQL。
- **认证**：JWT + bcrypt。
- **日志与观测**：tracing / tracing-subscriber。
- **资源上传**：七牛云相关 SDK 与 HTTP 上传能力。
- **部署**：Dockerfile + `docker-compose.prod.yml`。

服务默认配合 PostgreSQL 数据库 `hikiki_db`，生产 Compose 中后端通过内部网络连接数据库和管理后台。

### 3. 管理后台技术方案

`kiki_admin` 是运营管理后台。

核心选择：

- **框架**：Vue 3 Composition API。
- **构建工具**：Vite。
- **语言**：TypeScript。
- **UI**：Element Plus。
- **状态管理**：Pinia。
- **路由**：Vue Router。
- **HTTP**：Axios。
- **上传能力**：集成七牛 JS 上传相关依赖。

后台主要用于维护学习内容和运营数据，包括场景分类、场景、场景物品、热区编辑、用户和统计等。

### 4. 产品静态站技术方案

`kiki_product_html` 是无需构建的静态站：

- `all/`：奇思蔓想品牌与产品总览页。
- `hikiki/`：Hi Kiki 下载页和版本信息。
- `hikiki/hikik_version.json`：App 更新检查使用的版本信息。

静态站通过 `.github/workflows/product-static-sites-release.yml` 发布到 `all.keepthinking.me`：

- `/` 指向 `all/index.html`
- `/hikiki/` 指向 `hikiki/index.html`

---

## 快速开始

### 环境要求

- Flutter SDK，Dart SDK `>=3.6.0 <4.0.0`
- Rust stable toolchain
- Node.js + npm
- PostgreSQL 15 或 Docker

### 启动移动端 App

```bash
cd kiki_web
flutter pub get
flutter run
```

常用检查：

```bash
cd kiki_web
flutter analyze
```

### 启动后端服务

```bash
cd kiki_server
cargo run
```

常用检查：

```bash
cd kiki_server
cargo test
```

### 启动管理后台

```bash
cd kiki_admin
npm install
npm run dev
```

构建：

```bash
cd kiki_admin
npm run build
```

### 预览产品静态页

静态页可以直接用浏览器打开：

```text
kiki_product_html/all/index.html
kiki_product_html/hikiki/index.html
```

---

## 部署与发布

### 生产 Docker 服务

生产环境通过根目录 `docker-compose.prod.yml` 编排：

- `postgres`：PostgreSQL 15
- `backend`：Rust API
- `admin`：Vue 管理后台
- `nginx`：HTTPS 入口和反向代理
- `certbot`：证书续期

参考文档：

- [部署文档](docs/deployment/README.md)
- [正式部署流程](docs/deployment/kiki_chain_正式部署流程.md)
- [部署 runbook](docs/deployment/deploy-release-runbook.md)

### GitHub Actions

当前主要 workflows：

- `ci-validate.yml`：基础校验
- `android-release.yml`：Android 打包
- `ios-release.yml`：iOS 打包
- `docker-release.yml`：Docker 镜像发布
- `product-static-sites-release.yml`：产品静态站发布

---

## 文档入口

项目文档遵循“共享文档放 `docs/`，子项目实现文档放各自目录”的规则。

- [文档索引](docs/DOCS_INDEX.md)
- [API 文档](docs/api/README.md)
- [数据库文档](docs/database/README.md)
- [部署文档](docs/deployment/README.md)
- [TTS 文档](docs/tts/README.md)
- [App 文档](kiki_web/docs/README.md)
- [后端文档](kiki_server/docs/README.md)

开发规范参考：

- [API 开发规范](.ai/dev-prompts/api-development-standards.md)
- [文档管理规范](.ai/dev-prompts/documentation-standards.md)

---

## 开发约定

- API 变更必须同步更新 `docs/api/`。
- App 新功能遵循 `kiki_web` 项目自有的简化 DDD 分层。
- 管理后台接口以共享 API 文档为前后端契约。
- 静态产品页改动后，需要确认 `product-static-sites-release.yml` 的校验条件仍然满足。
- 提交前至少运行与改动相关的最小校验，例如 `flutter analyze`、`cargo test`、`npm run build` 或静态页校验。

---

## 联系方式

- 品牌与产品：奇思蔓想
- 联系邮箱：justkids2018101@gmail.com

