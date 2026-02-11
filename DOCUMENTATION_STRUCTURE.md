# Kiki 漫游 - 文档架构设计

**更新时间**: 2026-02-11
**版本**: v2.0
**设计原则**: AI 驱动开发 + 三端同步

---

## 🎯 项目三端结构

```
kiki_chain/
├── kiki_web/              # 📱 Flutter App (移动端 iOS/Android)
├── kiki_web_manager/      # 💼 Web 管理后台 (Flutter Web)
└── kiki_server/           # 🔧 Rust 后端 (API Server)
```

---

## 📚 文档组织架构

### 🌟 根目录 - 项目级文档

```
kiki_chain/
├── README.md                          # 项目总览
├── DOCUMENTATION_STRUCTURE.md         # 本文档：文档架构说明
│
├── 📚 docs/                           # 共享文档中心
│   ├── README.md                      # 文档导航索引
│   │
│   ├── 📋 product/                    # 产品文档（产品经理维护）
│   │   ├── PRD_v1.0.md               # 产品需求文档
│   │   ├── roadmap.md                # 产品路线图
│   │   ├── requirements/             # 需求详细文档
│   │   │   ├── 场景需求.md
│   │   │   ├── 用户系统需求.md
│   │   │   └── 学习进度需求.md
│   │   └── analysis/                 # 需求分析
│   │       ├── 产品需求分析.md       # 从 kiki_web 迁移
│   │       └── 商业分析报告.md       # 从 kiki_web 迁移
│   │
│   ├── 🏗️ architecture/               # 系统架构（三端共享）
│   │   ├── system_design.md          # 系统总体设计
│   │   ├── data_model.md             # 数据模型设计
│   │   ├── tech_stack.md             # 技术栈选型
│   │   └── data_flow.md              # 数据流设计
│   │
│   ├── 🔌 api/                        # API 接口文档（三端共享）
│   │   ├── README.md                 # API 总览
│   │   ├── specification.md          # API 规范
│   │   ├── endpoints/                # 接口详细文档
│   │   │   ├── auth.md              # 认证接口
│   │   │   ├── users.md             # 用户接口
│   │   │   ├── scenes.md            # 场景接口
│   │   │   └── learning.md          # 学习进度接口
│   │   └── changelog.md              # API 变更日志
│   │
│   ├── 🎨 design/                     # 设计文档
│   │   ├── ui_specification.md       # UI 设计规范
│   │   ├── interaction.md            # 交互设计
│   │   └── assets/                   # 设计资源
│   │       ├── colors.md
│   │       └── typography.md
│   │
│   └── 🔄 workflow/                   # 工作流程
│       ├── AI_DRIVEN_DEVELOPMENT.md  # AI 驱动开发（从 kiki_web 迁移）
│       ├── collaboration.md          # 协作规范
│       └── git_workflow.md           # Git 工作流
│
├── 🎯 tasks/                          # 任务管理中心
│   ├── TASK_BOARD.md                 # 主任务看板（从 kiki_web 迁移）
│   ├── current_sprint/               # 当前 Sprint
│   │   ├── sprint_1.md
│   │   └── daily_tasks/
│   ├── backlog/                      # 待办任务
│   │   ├── features/
│   │   ├── bugs/
│   │   └── optimizations/
│   ├── completed/                    # 已完成任务
│   │   ├── sprint_1/
│   │   └── sprint_2/
│   └── archive/                      # 归档
│       ├── task_completion_day1-4.md    # 从 kiki_web 迁移
│       ├── task_completion_day5-7.md
│       ├── task_completion_day8-11.md
│       ├── task_completion_day12-14.md
│       └── task_completion_week3.md
│
└── 🤖 scripts/                        # 自动化脚本
    ├── task_manager.sh               # 任务管理
    ├── sync_docs.sh                  # 文档同步
    └── deploy/                       # 部署脚本
        ├── deploy_app.sh
        ├── deploy_web.sh
        └── deploy_server.sh
```

---

### 📱 kiki_web - App 特定文档

```
kiki_web/
└── doc/                              # App 技术文档
    ├── README.md                     # App 文档导航
    │
    ├── 🏗️ architecture/               # App 架构
    │   ├── overview.md               # 架构概览
    │   ├── clean_architecture.md     # Clean Architecture（保留现有）
    │   ├── state_management.md       # GetX 状态管理
    │   └── ARCHITECTURE_OPTIMIZATION.md  # 架构优化记录（保留）
    │
    ├── 🧩 features/                   # 功能模块文档
    │   ├── interactive_image.md      # 互动图片功能（保留现有）
    │   ├── scene_system.md           # 场景系统
    │   ├── user_auth.md              # 用户认证
    │   └── learning_progress.md      # 学习进度
    │
    ├── 💼 business/                   # 业务逻辑（保留）
    │   ├── 场景结构定义.md           # 保留
    │   ├── picture_config.md         # 保留
    │   ├── 功能需求-首页改版.md      # 保留
    │   ├── 功能需求-新场景规划.md    # 保留
    │   ├── 功能需求-用户登录.md      # 保留
    │   ├── 登录功能修复实施计划.md   # 保留
    │   ├── 登录功能需求验证报告.md   # 保留
    │   ├── 开发任务清单-需求拆分.md  # 保留
    │   └── 开发任务清单-每日计划.md  # 保留（或迁移到 tasks/）
    │
    ├── 🔧 technical/                  # 技术文档
    │   ├── framework/                # 框架相关（保留现有）
    │   │   ├── 技术架构文档.md
    │   │   ├── 基础库使用指南.md
    │   │   ├── 新功能开发指南标准.md
    │   │   ├── exception_system_migration.md
    │   │   └── auth_repository_架构优化.md
    │   ├── internationalization.md   # 国际化（保留）
    │   └── COMPLETE_FLOW_ANALYSIS.md # 数据流分析（保留）
    │
    ├── 🎨 ui/                         # UI 设计
    │   └── ui_design_specification.md # 保留
    │
    ├── 🖼️ assets/                     # 资源文档
    │   ├── IMAGE_OPTIMIZATION_GUIDE.md  # 图片优化指南（保留）
    │   └── prompts/                  # AI 绘图提示词（保留）
    │       ├── 01_daily_life_cover.md
    │       ├── 02_playground_cover.md
    │       ├── 03_numbers_cover.md
    │       ├── 04_letter_recognition_cover.md
    │       └── 05_traditional_festivals_cover.md
    │
    └── 🚀 development/                # 开发指南
        ├── setup.md                  # 环境搭建
        ├── testing.md                # 测试指南
        ├── debugging.md              # 调试指南
        └── deployment.md             # 部署指南
```

---

### 💼 kiki_web_manager - Web 管理后台文档

```
kiki_web_manager/
└── doc/                              # Web 管理后台文档
    ├── README.md                     # 文档导航
    │
    ├── 🏗️ architecture/               # 架构设计
    │   ├── overview.md               # 架构概览
    │   └── admin_system.md           # 管理系统设计
    │
    ├── 🧩 features/                   # 功能模块
    │   ├── content_management.md     # 内容管理
    │   ├── user_management.md        # 用户管理
    │   └── analytics.md              # 数据分析
    │
    ├── 🔧 technical/                  # 技术文档
    │   ├── framework/                # 框架相关
    │   └── components/               # 组件文档
    │
    └── 🚀 development/                # 开发指南
        ├── setup.md                  # 环境搭建
        └── deployment.md             # 部署指南
```

---

### 🔧 kiki_server - 后端文档

```
kiki_server/
└── doc/                              # 后端文档
    ├── README.md                     # 文档导航（保留）
    ├── START_HERE.md                 # 快速开始（保留）
    ├── QUICK_GUIDE.md                # 快速指南（保留）
    ├── DOCUMENTATION_SUMMARY.md      # 文档摘要（保留）
    │
    ├── 🏗️ architecture/               # DDD 架构
    │   ├── ddd_design.md             # DDD 设计
    │   ├── domain_model.md           # 领域模型
    │   └── layers.md                 # 分层架构
    │
    ├── 🔌 api/                        # API 实现（与根目录 API 文档对应）
    │   ├── implementation/           # 实现细节
    │   └── authentication.md         # 认证实现
    │
    ├── 🗄️ database/                   # 数据库
    │   ├── schema.md                 # 数据库模式
    │   ├── migrations/               # 迁移脚本文档
    │   └── optimization.md           # 性能优化
    │
    ├── 🔧 technical/                  # 技术文档
    │   ├── framework/                # 框架相关（保留现有）
    │   ├── dependencies.md           # 依赖管理
    │   └── configuration.md          # 配置说明
    │
    └── 🚀 development/                # 开发指南
        ├── setup.md                  # 环境搭建
        ├── testing.md                # 测试指南
        ├── deployment.md             # 部署指南
        └── docker.md                 # Docker 部署
```

---

## 🔄 文档迁移计划

### 从 kiki_web/doc 迁移到根目录

| 源文件 | 目标位置 | 原因 |
|--------|---------|------|
| `workflow/AI_DRIVEN_DEVELOPMENT.md` | `docs/workflow/` | ✅ 三端共享工作流 |
| `task/TASK_BOARD.md` | `tasks/` | ✅ 统一任务管理 |
| `task/task_completion_*.md` | `tasks/archive/` | ✅ 历史记录归档 |
| `business/产品需求分析.md` | `docs/product/analysis/` | ✅ 产品文档 |
| `business/商业分析报告.md` | `docs/product/analysis/` | ✅ 产品文档 |
| `business/开发排期计划.md` | `tasks/` | ✅ 任务规划 |
| `开发计划.md` | `tasks/` | ✅ 任务规划 |

### 保留在 kiki_web/doc

| 文件 | 位置 | 原因 |
|------|------|------|
| `ARCHITECTURE_OPTIMIZATION.md` | `architecture/` | ❌ App 特定架构 |
| `COMPLETE_FLOW_ANALYSIS.md` | `technical/` | ❌ App 数据流分析 |
| `framework/*` | `technical/framework/` | ❌ App 框架文档 |
| `business/场景结构定义.md` | `business/` | ❌ App 业务逻辑 |
| `business/picture_config.md` | `business/` | ❌ App 资源配置 |
| `features/interactive_image.md` | `features/` | ❌ App 功能模块 |
| `image/*` | `assets/` | ❌ App 资源文档 |
| `ui/*` | `ui/` | ❌ App UI 文档 |

---

## 🎯 AI 驱动开发的文档规范

### 1. 文档命名规范

- **产品文档**: `PRD_`, `需求_`, `分析_`
- **技术文档**: 小写英文 + 下划线，如 `system_design.md`
- **任务文档**: `TASK_`, `sprint_`, `daily_`
- **API 文档**: 按领域命名，如 `auth.md`, `scenes.md`

### 2. 文档更新规则

| 文档类型 | 更新者 | 更新时机 |
|---------|--------|----------|
| 产品需求 | 产品经理（用户） | 需求变更时 |
| API 文档 | AI | 接口变更时 |
| 架构文档 | AI | 架构调整时 |
| 任务看板 | AI + 用户 | 任务状态变更时 |
| 技术文档 | AI | 实现完成时 |

### 3. 文档索引维护

每个目录都有 `README.md` 作为导航索引，包含：
- 📋 文档清单
- 🔗 快速链接
- 📝 最近更新

---

## 🚀 使用方式

### AI（Claude）工作流

```bash
# 1. 在根目录启动
cd /Users/qisd/Documents/development/chain/kiki_chain

# 2. 查看任务
cat tasks/TASK_BOARD.md

# 3. 查看 API 文档
cat docs/api/README.md

# 4. 开发 App
cd kiki_web
# 开发...

# 5. 开发后端
cd ../kiki_server
# 开发...

# 6. 开发管理后台
cd ../kiki_web_manager
# 开发...

# 7. 回到根目录更新任务
cd ..
# 更新 tasks/TASK_BOARD.md
```

### 产品经理（用户）工作流

1. **提出需求**: 在 `docs/product/requirements/` 创建新需求文档
2. **查看进度**: 查看 `tasks/TASK_BOARD.md`
3. **审核功能**: 查看各端的 `features/` 文档
4. **查看 API**: 查看 `docs/api/` 了解接口设计

---

## 📊 文档维护责任

| 文档目录 | 主要维护者 | 协作维护者 |
|---------|-----------|-----------|
| `docs/product/` | 产品经理（用户） | AI |
| `docs/api/` | AI | - |
| `docs/architecture/` | AI | - |
| `docs/workflow/` | AI + 用户 | - |
| `tasks/` | AI + 用户 | - |
| `kiki_web/doc/` | AI | - |
| `kiki_server/doc/` | AI | - |
| `kiki_web_manager/doc/` | AI | - |

---

**文档版本**: v2.0
**创建时间**: 2026-02-11
**最后更新**: 2026-02-11
**维护者**: AI (Claude) + 产品经理
