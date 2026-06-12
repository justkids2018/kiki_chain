# Hi Kiki 服务器 - 文档索引

**项目**: Hi Kiki Server (Rust Backend)
**技术栈**: Rust + Axum + SQLx + PostgreSQL + Clean Architecture
**最后更新**: 2026-01-19

---

## 🎯 快速导航

- 📖 **新人上手**: 从这里开始 → [`QUICK_GUIDE.md`](./QUICK_GUIDE.md)
- 🏗️ **架构设计**: 最新架构说明 → [`architecture/clean_architecture_2026.md`](./architecture/clean_architecture_2026.md)
- 🤖 **Skills 配置**: Claude Code 配置 → [`guides/RUST_SKILLS_SETUP_GUIDE.md`](./guides/RUST_SKILLS_SETUP_GUIDE.md)
- 🌐 **API 文档**: 接口说明 → [`api/backend_api_documentation.md`](./api/backend_api_documentation.md)

---

## 📚 文档目录

### 🏗️ 架构设计（核心）

| 文档 | 说明 | 推荐度 |
|------|------|--------|
| [`clean_architecture_2026.md`](./architecture/clean_architecture_2026.md) | **最新架构设计** - 4 层简化架构 | ⭐⭐⭐⭐⭐ |
| [`ARCHITECTURE_ANALYSIS.md`](./architecture/ARCHITECTURE_ANALYSIS.md) | 架构分析 - 3 个方案对比 | ⭐⭐⭐⭐ |
| [`REFACTORING_SUMMARY.md`](./architecture/REFACTORING_SUMMARY.md) | 重构总结 - 详细重构记录 | ⭐⭐⭐⭐ |

**核心内容**:
- ✅ 4 层架构（HTTP → Handlers → Use Cases → Repository）
- ✅ 强类型 DTOs
- ✅ Clean Architecture 最佳实践
- ✅ 依赖倒置原则

---

### 📖 开发指南（必读）

| 文档 | 说明 | 推荐度 |
|------|------|--------|
| [`RUST_SKILLS_SETUP_GUIDE.md`](./guides/RUST_SKILLS_SETUP_GUIDE.md) | **Skills 配置指南** - Claude Code 使用 | ⭐⭐⭐⭐⭐ |
| [`SKILLS_OVERVIEW.md`](./guides/SKILLS_OVERVIEW.md) | Skills 总览 - 5 大能力介绍 | ⭐⭐⭐⭐ |
| [`development_guide.md`](./dev/development_guide.md) | 开发规范 - Rust 编码标准 | ⭐⭐⭐⭐ |
| [`user_query_feature_development_guide.md`](./dev/user_query_feature_development_guide.md) | 功能开发示例 - 完整流程 | ⭐⭐⭐ |

**Skills 能力**:
1. `requirement-clarification` - 需求澄清
2. `api-design` - RESTful API 设计
3. `code-implementation` - Rust 代码实现 ⭐
4. `code-review` - 代码审查（自动）
5. `bug-analysis` - 错误分析

---

### 🌐 API 文档

| 文档 | 说明 |
|------|------|
| [`backend_api_documentation.md`](./api/backend_api_documentation.md) | 后端 API 完整文档 |

**主要接口**:
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/register` - 用户注册
- 更多接口详见文档...

---

### 💼 业务文档

| 文档 | 说明 |
|------|------|
| [`project.md`](./business/project.md) | Hi Kiki 项目概述和业务需求 |

---

### 🔧 框架文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [`功能库引用文档.md`](./framework/功能库引用文档.md) | 第三方库使用说明（Axum/SQLx/Tokio） | ✅ 有效 |
| ~~`latest_ddd_architecture_2025.md`~~ | ~~旧版架构（2025）~~ | ⚠️ 已过时 |

**注意**: 请使用最新的 [`architecture/clean_architecture_2026.md`](./architecture/clean_architecture_2026.md)

---

### 📋 任务管理

| 文档 | 说明 |
|------|------|
| [`current-task-dev.md`](./task/current-task-dev.md) | 当前开发任务 |
| [`current-task.md`](./task/current-task.md) | 任务列表 |
| [`student/`](./task/student/) | 学生功能需求（3 个文件） |
| [`teacher/`](./task/teacher/) | 老师功能需求（2 个文件） |
| [`check/`](./task/check/) | 检查相关（1 个文件） |

---

### 🤖 AI Prompt 模板

| 文档 | 说明 |
|------|------|
| [`base_document_prompt.md`](./prompt/base_document_prompt.md) | 基础文档生成模板 |
| [`doc_framework_config_prompt.md`](./prompt/doc_framework_config_prompt.md) | 框架配置文档 |
| [`doc_framework_api_path.md`](./prompt/doc_framework_api_path.md) | API 路径文档 |
| [`doc_docker_prompt.md`](./prompt/doc_docker_prompt.md) | Docker 部署文档 |
| 其他 Prompt 模板... | 共 8 个文件 |

---

## 🚀 新人上手路径（推荐）

### 第 1 天：了解架构

1. 📖 阅读快速导航 → [`QUICK_GUIDE.md`](./QUICK_GUIDE.md)（5 分钟）
2. 🏗️ 学习架构设计 → [`architecture/clean_architecture_2026.md`](./architecture/clean_architecture_2026.md)（20 分钟）
3. 📊 理解重构过程 → [`architecture/ARCHITECTURE_ANALYSIS.md`](./architecture/ARCHITECTURE_ANALYSIS.md)（15 分钟）

### 第 2 天：配置环境

1. 🔧 安装 Rust 工具链
   ```bash
   cargo check
   cargo fmt
   cargo clippy
   cargo test
   ```

2. 🤖 配置 Claude Code Skills → [`guides/RUST_SKILLS_SETUP_GUIDE.md`](./guides/RUST_SKILLS_SETUP_GUIDE.md)（15 分钟）

3. 🌐 查看 API 文档 → [`api/backend_api_documentation.md`](./api/backend_api_documentation.md)（10 分钟）

### 第 3 天：开始开发

1. 📖 阅读开发规范 → [`dev/development_guide.md`](./dev/development_guide.md)（15 分钟）
2. 💡 查看开发示例 → [`dev/user_query_feature_development_guide.md`](./dev/user_query_feature_development_guide.md)（20 分钟）
3. 🚀 开始开发第一个功能！

---

## 📊 文档统计

| 分类 | 文件数 | 核心文档 |
|------|--------|---------|
| 架构设计 | 3 | ⭐⭐⭐⭐⭐ |
| 开发指南 | 4 | ⭐⭐⭐⭐⭐ |
| API 文档 | 1 | ⭐⭐⭐⭐ |
| 业务文档 | 1 | ⭐⭐⭐ |
| 框架文档 | 2 | ⭐⭐⭐ |
| 任务管理 | 7 | ⭐⭐ |
| AI Prompt | 8 | ⭐⭐ |
| **总计** | **26** | - |

---

## 🎯 按需查找

### 我想要...

| 需求 | 推荐文档 |
|------|---------|
| **了解架构** | [`architecture/clean_architecture_2026.md`](./architecture/clean_architecture_2026.md) |
| **开始开发** | [`QUICK_GUIDE.md`](./QUICK_GUIDE.md) |
| **配置 Skills** | [`guides/RUST_SKILLS_SETUP_GUIDE.md`](./guides/RUST_SKILLS_SETUP_GUIDE.md) |
| **查看 API** | [`api/backend_api_documentation.md`](./api/backend_api_documentation.md) |
| **学习规范** | [`dev/development_guide.md`](./dev/development_guide.md) |
| **解决错误** | `.claude/skills/bug-analysis/SKILL.md` |
| **设计 API** | `.claude/skills/api-design/` |

---

## 🔗 相关资源

### 官方文档

- [Rust 官方文档](https://doc.rust-lang.org/book/)
- [Axum 文档](https://docs.rs/axum/latest/axum/)
- [SQLx 文档](https://docs.rs/sqlx/latest/sqlx/)
- [Tokio 异步编程](https://tokio.rs/tokio/tutorial)

### 架构参考

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)

---

## 📝 文档维护

### 更新规则

1. **架构变更** → 更新 `architecture/clean_architecture_2026.md`
2. **新增功能** → 更新 `api/backend_api_documentation.md`
3. **开发规范** → 更新 `dev/development_guide.md`
4. **Skills 调整** → 更新 `.claude/skills/README.md`

### 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v2.1 | 2026-01-19 | 清理不需要的文档，聚焦后端开发 |
| v2.0 | 2026-01-18 | 重构完成，简化为 4 层架构 |
| v1.0 | 2025-08-15 | 初始版本，5 层 Clean Architecture |

---

**文档维护**: Hi Kiki 开发团队
**最后更新**: 2026-01-19
**版本**: v2.1 (Focused on Backend Development)
