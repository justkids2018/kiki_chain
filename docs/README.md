# 📚 Kiki 漫游 - 文档中心

> **统一的项目文档导航和索引**

**最后更新**: 2026-03-12

---

## 🚀 快速开始

### 新手必读

1. **[开发环境配置](./setup/DEV_SETUP.md)** ⭐
   - 数据库连接信息
   - kiki_server 启动方法
   - kiki_web 配置说明
   - 常见问题解决

2. **[项目进度与计划](./management/PROJECT_STATUS.md)** ⭐
   - 当前状态总览
   - 已��成工作
   - 待办事项
   - 下一步计划

3. **[任务执行记录](./management/TASK_LOG.md)** ⭐
   - 每次执行的计划
   - 完成情况记录
   - 问题和解决方案

### 一键启动

```bash
# 检查环境状态
./scripts/dev-start.sh

# 启动开发环境（仅启动未运行的服务）
./scripts/dev-start.sh --start

# 停止开发环境
./scripts/dev-stop.sh
```

---

## 📋 文档分类

### 🎯 快速导航

| 类别 | 描述 | 快速链接 |
|------|------|----------|
| 🚀 **开发环境** | 环境配置、启动脚本 | [查看 →](#-开发环境) |
| 📊 **项目管理** | 进度、计划、任务记录 | [查看 →](#-项目管理) |
| 📖 **产品文档** | 产品需求、分析、规划 | [查看 →](#-产品文档) |
| 🏗️ **架构设计** | 系统架构、数据模型 | [查看 →](#%EF%B8%8F-架构设计) |
| 🔌 **API 文档** | 接口规范和说明 | [查看 →](#-api-文档) |
| 🎨 **设计文档** | UI/UX 设计规范 | [查看 →](#-设计文档) |
| 🔄 **工作流程** | 开发流程和规范 | [查看 →](#-工作流程) |

---

## 🚀 开发环境

### 核心文档 ✅

- **[开发环境快速启动](./setup/DEV_SETUP.md)** ⭐ **必读**
  - 数据库连接信息（PostgreSQL）
  - kiki_server 配置和启动
  - kiki_web API 地址配置
  - 启动检查清单
  - 常见问题解决

### 自动化脚本 ✅

**路径**: `../scripts/`

- **dev-start.sh** - 智能启动脚本
  - 自动检查服务状态
  - 仅启动未运行的服务
  - 验证服务健康状态

- **dev-stop.sh** - 优雅停止脚本
  - 停止 kiki_server
  - 停止 PostgreSQL（保留数据）

### 使用方法

```bash
# 检查环境状态（不启动任何服务）
./scripts/dev-start.sh

# 启动缺失的服务
./scripts/dev-start.sh --start

# 停止所有服务
./scripts/dev-stop.sh
```

> 🤖 **AI 维护** | 🔧 **自动化优先**

---

## 📊 项目管理

### 进度追踪 ✅

- **[项目进度与计划](./management/PROJECT_STATUS.md)** ⭐ **必读**
  - 当前状态总览
  - 已完成工作清单
  - 待办事项（P0/P1/P2）
  - 下一步计划
  - 里程碑追踪
  - 已知问题

- **[任务执行记录](./management/TASK_LOG.md)** ⭐ **每次更新**
  - 每次开发会话的计划
  - 执行过程记录
  - 完成情况统计
  - 遇到的问题和解决方案
  - 下次执行计划

### 任务管理

**路径**: `../tasks/`

- **TASK_BOARD.md** - 任务看板
- **backend/** - 后端任务
- **app/** - 移动端任务
- **admin/** - 管理后台任务

> 🤖 **AI 维护** | 📈 **持续更新**

---

## 📖 产品文档

**路径**: `product/`

### 需求分析

- **[产品需求分析](./product/analysis/产品需求分析.md)**
  - 核心功能需求
  - 用户画像分析
  - 功能优先级

- **[商业分析报告](./product/analysis/商业分析报告.md)**
  - 市场分析
  - 竞品分析
  - 商业模式

### 需求文档

**路径**: `product/requirements/`

- 场景需求
- 用户系统需求
- 学习进度需求

> 📝 **产品经理维护** | 🤖 **AI 协作**

---

## 🏗️ 架构设计

**路径**: `architecture/`

### 系统架构

待创建的文档：

- **system_design.md** - 系统总体设计
  - 三端架构
  - 数据流设计
  - 技术选型

- **data_model.md** - 数据模型设计
  - 实体关系图
  - 数据字典
  - 数据库设计

- **tech_stack.md** - 技术栈说明
  - Flutter 技术栈
  - Rust 技术栈
  - DevOps 工具链

> 🤖 **AI 维护**

---

## 💾 数据库文档

**路径**: `database/`

### 数据库设计 ✅

- **[数据库文档导航](./database/README.md)**
  - 表结构设计
  - 迁移管理
  - ER 图设计
  - 索引优化

### 文档结构

```
database/
├── schema/           # 表结构文档
├── migrations/       # 迁移历史
└── design/          # 设计文档
```

> 🤖 **AI 维护** | 🔗 **三端共享**

---

## 🔌 API 文档

**路径**: `api/`

### 接口文档

**路径**: `api/endpoints/`

待创建的文档：

- **auth.md** - 认证接口
  - 登录 / 注册
  - Token 管理
  - 密码找回

- **users.md** - 用户接口
  - 用户信息
  - 用户设置
  - 学习记录

- **scenes.md** - 场景接口
  - 分类列表
  - 场景列表
  - 场景详情

- **learning.md** - 学习进度接口
  - 进度查询
  - 进度更新
  - 成就系统

### API 规范

待创建：

- **specification.md** - API 设计规范
- **changelog.md** - API 变更日志

> 🤖 **AI 维护** | 🔗 **三端共享**

---

## 🎨 设计文档

**路径**: `design/`

### UI 设计

待创建的文档：

- **ui_specification.md** - UI 设计规范
  - 颜色系统
  - 字体规范
  - 组件规范

- **interaction.md** - 交互设计
  - 交互流程
  - 手势规范
  - 动画规范

### 设计资源

**路径**: `design/assets/`

- colors.md - 颜色规范
- typography.md - 字体规范

> 👨‍💼 **产品经理维护** | 🤖 **AI 协作**

---

## 🔄 工作流程

**路径**: `workflow/`

### 核心工作流 ✅

1. **[AI 驱动开发流程](./workflow/AI_DRIVEN_DEVELOPMENT.md)**
   - 角色定义
   - 任务管理系统
   - 三端同步策略
   - 开发流程规范

2. **[任务结构定义](./workflow/TASK_STRUCTURE.md)**
   - 三端任务分类
   - 任务命名规范
   - 任务模板
   - 任务优先级管理

3. **[高效工作流指南](./workflow/EFFICIENT_WORKFLOW.md)**
   - 5 步工作流
   - 实战演练
   - 三端协同开发
   - 快速迭代方法

4. **[协作开发指南](./workflow/COLLABORATION_GUIDE.md)** ⭐ **推荐阅读**
   - 你和 AI 的协作模式
   - 每日工作节奏
   - 项目掌控方法
   - 常见问题解答

5. **[高级 AI 开发模式](./workflow/ADVANCED_AI_DEVELOPMENT.md)**
   - Agent 驱动开发
   - 架构先行方法
   - 持续开发实践
   - 专业工程师模式

### 待创建 📝

- **git_workflow.md** - Git 工作流规范

> 🤖 **AI 维护** | 👨‍💼 **产品经理协作**

---

## 🔗 各端技术文档

### 📱 App 文档

**路径**: `../kiki_web/doc/`

- [App 文档导航](../kiki_web/doc/README.md)
- 架构设计
- 功能模块
- 技术指南

### 🔧 后端文档

**路径**: `../kiki_server/doc/`

- [后端文档导航](../kiki_server/doc/README.md)
- DDD 架构
- API 实现
- 数据库设计

### 💼 管理后台文档

**路径**: `../kiki_web_manager/doc/`

- [管理后台文档导航](../kiki_web_manager/doc/README.md)
- 功能模块
- 管理系统设计

---

## 📊 文档状态

### 已创建 ✅

- [x] AI 驱动开发流程
- [x] 产品需求分析
- [x] 商业分析报告

### 待创建 📝

- [ ] 系统架构设计
- [ ] 数据模型设计
- [ ] API 规范文档
- [ ] UI 设计规范
- [ ] 协作指南

---

## 🚀 如何使用文档

### 对于产品经理

1. **提需求**: 在 `product/requirements/` 创建新需求文档
2. **查进度**: 查看 `../tasks/TASK_BOARD.md`
3. **审功能**: 查看各端的功能文档
4. **看 API**: 查看 `api/` 了解接口设计

### 对于 AI (Claude)

1. **查需求**: 读取 `product/` 了解功能需求
2. **看架构**: 参考 `architecture/` 设计方案
3. **写代码**: 在各端项目目录开发
4. **更文档**: 同步更新技术文档

---

## 📝 文档维护规则

| 文档类型 | 维护者 | 更新时机 |
|---------|--------|----------|
| 产品文档 | 产品经理 | 需求变更时 |
| API 文档 | AI | 接口变更时 |
| 架构文档 | AI | 架构调整时 |
| 技术文档 | AI | 实现完成时 |

---

## 🔍 搜索文档

### 按类型搜索

```bash
# 搜索产品文档
find docs/product -name "*.md"

# 搜索 API 文档
find docs/api -name "*.md"

# 搜索所有文档
find docs -name "*.md"
```

### 按内容搜索

```bash
# 搜索包含 "登录" 的文档
grep -r "登录" docs/

# 搜索包含 "API" 的文档
grep -r "API" docs/
```

---

## 📞 帮助

- **文档问题**: 查看 [文档架构说明](../DOCUMENTATION_STRUCTURE.md)
- **开发问题**: 查看 [AI 驱动开发流程](./workflow/AI_DRIVEN_DEVELOPMENT.md)
- **任务问题**: 查看 [任务看板](../tasks/TASK_BOARD.md)

---

**文档版本**: v1.0
**创建时间**: 2026-02-11
**维护者**: AI (Claude) + 产品经理
