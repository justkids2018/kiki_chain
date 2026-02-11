# Kiki 漫游 (Kiki Journey)

> **AI 驱动的儿童中文学习平台**
> 通过互动场景和沉浸式体验，让孩子快乐学习中文

[![Project Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Sprint](https://img.shields.io/badge/sprint-1-blue.svg)]()
[![Completion](https://img.shields.io/badge/completion-10%25-yellow.svg)]()

---

## 📋 项目概览

**Kiki 漫游**是一个创新的儿童中文学习应用，采用场景化、互动式的学习方式，让 3-8 岁儿童在游戏中自然习得中文。

### 🎯 核心功能

- **📱 互动场景学习**: 通过点击场景中的物品学习汉字、拼音、英文
- **🎨 汉字笔画动画**: 动态展示汉字书写过程
- **🔊 TTS 语音播放**: 标准中文发音，帮助孩子正确学习
- **📊 学习进度跟踪**: 记录学习轨迹，激励持续学习
- **🏆 成就系统**: 通过徽章和奖励增强学习动力

---

## 🏗️ 项目架构

```
kiki_chain/                          # 项目根目录
├── 📱 kiki_web/                     # Flutter App (iOS/Android)
│   └── 技术栈: Flutter 3.29.2 + GetX
├── 💼 kiki_web_manager/             # Web 管理后台 (Flutter Web)
│   └── 技术栈: Flutter Web + Admin UI
└── 🔧 kiki_server/                  # Rust 后端 API
    └── 技术栈: Rust + Actix-web + PostgreSQL
```

### 🔗 三端职责

| 端 | 职责 | 技术栈 |
|---|------|--------|
| **App** | 儿童学习端，提供互动学习体验 | Flutter + GetX |
| **Manager** | 内容管理后台，管理场景、物品、用户 | Flutter Web |
| **Server** | API 服务，提供数据和业务逻辑 | Rust + DDD |

---

## 📚 文档导航

### 🌟 核心文档

- **[📖 文档架构说明](./DOCUMENTATION_STRUCTURE.md)** - 文档组织架构和规范
- **[🎯 任务看板](./tasks/TASK_BOARD.md)** - 当前开发任务和进度
- **[🔄 AI 驱动开发流程](./docs/workflow/AI_DRIVEN_DEVELOPMENT.md)** - 开发工作流和协作方式

### 📋 产品文档

- **[产品需求分析](./docs/product/analysis/产品需求分析.md)** - 核心需求分析
- **[商业分析报告](./docs/product/analysis/商业分析报告.md)** - 市场和商业模式分析

### 🏗️ 技术文档

- **[系统架构](./docs/architecture/)** - 系统总体架构设计
- **[API 文档](./docs/api/)** - 接口规范和文档
- **[App 文档](./kiki_web/doc/)** - Flutter App 技术文档
- **[后端文档](./kiki_server/doc/)** - Rust 后端技术文档
- **[管理后台文档](./kiki_web_manager/doc/)** - Web 管理后台文档

---

## 🚀 快速开始

### 前置要求

- **Flutter**: 3.29.2 或更高
- **Rust**: 1.70+ (后端开发)
- **PostgreSQL**: 14+ (数据库)
- **Node.js**: 18+ (工具链)

### 开发 App

```bash
cd kiki_web
flutter pub get
flutter run
```

### 开发后端

```bash
cd kiki_server
cargo run
```

### 开发管理后台

```bash
cd kiki_web_manager
flutter pub get
flutter run -d chrome
```

---

## 👥 团队协作

本项目采用 **AI 驱动开发模式**：

- **🤖 AI (Claude)**: 主要工程师 - 负责代码实现、架构设计、技术决策
- **👨‍💼 产品经理**: 负责需求定义、功能规划、验收测试

详见：[AI 驱动开发流程](./docs/workflow/AI_DRIVEN_DEVELOPMENT.md)

---

## 📊 项目进度

**当前 Sprint**: Sprint 1 (第 1-2 周)
**完成率**: 10% (2/20 任务)

### ✅ 已完成

- [x] 项目初始化和基础架构
- [x] 架构优化（合并 SceneDetailPage）

### 🔥 进行中

- 暂无进行中任务

### 📝 待办

- [ ] Mock 数据完善
- [ ] 实现日常生活场景 (6个)
- [ ] TTS 功能完善
- [ ] UI/UX 优化

查看完整进度：[任务看板](./tasks/TASK_BOARD.md)

---

## 🤖 AI 驱动开发

### Claude Code 使用方式

```bash
# 1. 在根目录启动（推荐）
cd /Users/qisd/Documents/development/chain/kiki_chain

# 2. 查看任务
cat tasks/TASK_BOARD.md

# 3. 开发 App
cd kiki_web
# 进行开发...

# 4. 开发后端
cd ../kiki_server
# 进行开发...

# 5. 开发管理后台
cd ../kiki_web_manager
# 进行开发...

# 6. 回到根目录更新任务
cd ..
# 更新任务状态
```

---

## 📦 项目结构

<details>
<summary>点击展开完整项目结构</summary>

```
kiki_chain/
├── 📚 docs/                           # 共享文档
│   ├── product/                       # 产品文档
│   ├── architecture/                  # 架构设计
│   ├── api/                           # API 文档
│   ├── design/                        # 设计文档
│   └── workflow/                      # 工作流程
├── 🎯 tasks/                          # 任务管理
│   ├── TASK_BOARD.md                 # 主任务看板
│   ├── current_sprint/               # 当前 Sprint
│   ├── backlog/                      # 待办任务
│   ├── completed/                    # 已完成
│   └── archive/                      # 历史归档
├── 🤖 scripts/                        # 自动化脚本
├── 📱 kiki_web/                       # Flutter App
├── 💼 kiki_web_manager/               # Web 管理后台
└── 🔧 kiki_server/                    # Rust 后端
```

</details>

---

## 🛠️ 技术栈

### 前端 (App & Web)

- **Flutter**: 3.29.2
- **状态管理**: GetX
- **网络**: Dio
- **本地存储**: Hive
- **多语言**: flutter_localizations

### 后端

- **语言**: Rust
- **框架**: Actix-web
- **数据库**: PostgreSQL
- **架构**: DDD (领域驱动设计)
- **ORM**: Diesel / SeaORM

### DevOps

- **容器化**: Docker
- **CI/CD**: GitHub Actions
- **部署**: 待定

---

## 📝 开发规范

- **代码风格**: 遵循 Flutter 和 Rust 官方规范
- **Git 提交**: 使用 Conventional Commits
- **分支策略**: Git Flow
- **文档更新**: 随代码同步更新

---

## 📄 License

Copyright © 2026 Kiki Journey Team. All rights reserved.

---

## 📞 联系方式

- **项目管理**: [查看任务看板](./tasks/TASK_BOARD.md)
- **技术文档**: [文档中心](./docs/)
- **问题反馈**: GitHub Issues

---

**最后更新**: 2026-02-11
**文档版本**: v2.0
**维护者**: AI (Claude) + 产品经理
