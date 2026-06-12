# 文档快速导航

> 一分钟找到你需要的文档！

---

## 🎯 我想要...

### 了解项目架构

➡️ **开始阅读**: `doc/architecture/clean_architecture_2026.md`

**包含内容**:
- ✅ 最新架构设计（4 层架构）
- ✅ 调用链和数据流
- ✅ 重构前后对比
- ✅ 核心组件详解

---

### 开始开发新功能

➡️ **开发流程**:

1. **需求澄清** → 查看 `doc/task/current-task-dev.md`
2. **API 设计** → 参考 `doc/api/backend_api_documentation.md`
3. **代码实现** → 遵循 `.claude/skills/code-implementation/SKILL.md`
4. **代码审查** → 自动触发（参见 `.claude/skills/code-review/SKILL.md`）

➡️ **示例**: `doc/dev/user_query_feature_development_guide.md`

---

### 配置 Claude Code Skills

➡️ **快速开始**: `doc/guides/RUST_SKILLS_SETUP_GUIDE.md`

**Skills 列表**:
- `requirement-clarification` - 需求澄清
- `api-design` - API 设计
- `code-implementation` - 代码实现 ⭐
- `code-review` - 代码审查（自动）
- `bug-analysis` - 错误分析

➡️ **Skills 总览**: `doc/guides/SKILLS_OVERVIEW.md`

---

### 查看 API 接口

➡️ **API 文档**: `doc/api/backend_api_documentation.md`

**主要接口**:
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/register` - 用户注册

---

### 理解重构过程

➡️ **架构分析**: `doc/architecture/ARCHITECTURE_ANALYSIS.md`

**包含内容**:
- 当前架构分析
- 3 个优化方案对比
- 主流 Rust Web 架构对比

➡️ **重构总结**: `doc/architecture/REFACTORING_SUMMARY.md`

**包含内容**:
- 重构详细步骤
- 代码对比
- 测试结果

---

### 解决编译错误

➡️ **错误分析**: `.claude/skills/bug-analysis/SKILL.md`

**常见错误**:
- 借用检查错误 (Borrow Checker)
- 类型错误 (Type Mismatch)
- SQL 错误
- panic/unwrap 失败

---

### 了解开发规范

➡️ **开发指南**: `doc/dev/development_guide.md`

**包含内容**:
- Rust 命名规范
- Clean Architecture 最佳实践
- 错误处理规范
- 数据库安全

---

## 📁 完整文档索引

➡️ **总索引**: `doc/README.md`

---

## 🔍 按类型查找

### 架构设计
- `doc/architecture/clean_architecture_2026.md` - 最新架构
- `doc/architecture/ARCHITECTURE_ANALYSIS.md` - 架构分析
- `doc/architecture/REFACTORING_SUMMARY.md` - 重构总结

### 开发指南
- `doc/guides/RUST_SKILLS_SETUP_GUIDE.md` - Skills 配置
- `doc/guides/SKILLS_OVERVIEW.md` - Skills 总览
- `doc/dev/development_guide.md` - 开发规范
- `doc/dev/user_query_feature_development_guide.md` - 功能开发示例

### API 文档
- `doc/api/backend_api_documentation.md` - 后端 API

### 业务文档
- `doc/business/project.md` - 项目概述

### 任务管理
- `doc/task/current-task-dev.md` - 当前开发任务
- `doc/task/current-task.md` - 任务列表

---

## 🚀 新人上手路径

1. **第 1 天**: 阅读 `doc/architecture/clean_architecture_2026.md`
2. **第 2 天**: 配置 Skills `doc/guides/RUST_SKILLS_SETUP_GUIDE.md`
3. **第 3 天**: 查看示例 `doc/dev/user_query_feature_development_guide.md`
4. **第 4 天**: 开始开发第一个功能！

---

**最后更新**: 2026-01-18
