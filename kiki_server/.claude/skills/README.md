# Claude Code Skills - Hi Kiki 后端开发

> **项目**: Hi Kiki 服务器 (Rust Backend)
> **架构**: Clean Architecture (4 Layers)
> **版本**: v2.0 (分层架构)
> **最后更新**: 2026-01-19

---

## 🎯 Skills 架构概览

### 新架构特点（v2.0）

**分层设计**: 每个 skill 分为三个独立文件
```
skill/
├── SKILL.md          # 入口：流程、触发条件、使用说明
├── COMMON.md         # 通用规范：适用所有项目/语言
└── PROJECT.md        # 项目特定：Hi Kiki Rust 后端规范
```

**全局规范**: 所有 skills 共享
```
.claude/skills/
└── COMMON_GUIDELINES.md    # 全局开发规范（工作流、SOLID、文档管理）
```

---

## 📚 Skills 列表

### 核心 Skills（已完成）✅

#### 1. code-implementation (代码实现)
**用途**: Rust 后端代码实现标准和最佳实践

**特性**:
- ✅ 完成后**自动触发** code-review
- ✅ Clean Architecture 4 层架构
- ✅ Rust 命名规范、错误处理、异步编程

---

#### 2. code-review (代码审查)
**用途**: 三步强制检查（功能正确性 → 编译正确性 → 代码质量）

**特性**:
- 🚨 强制自动触发（不询问用户）
- ✅ 三步检查：功能 → 编译 → 质量
- ✅ 分级建议：Critical / Warning / Suggestion

---

#### 3. api-design (API 设计)
**用途**: RESTful API 设计规范和文档生成

**特性**:
- ✅ RESTful API 设计原则
- ✅ 统一响应格式
- ✅ API 文档模板

---

### 其他 Skills（待完善）

#### 4. bug-analysis (错误分析)
**状态**: 🔄 待重构为分层架构

#### 5. requirement-clarification (需求澄清)
**状态**: 🔄 待重构为分层架构

---

## 🔗 Skills 工作流

### 典型开发流程

```
用户需求
    ↓
[requirement-clarification]  # 需求澄清（可选）
    ↓
[api-design]                 # API 设计
    ↓
[code-implementation]        # 代码实现
    ↓
[code-review] (自动触发)     # 代码审查
    ↓
如果有错误 → [bug-analysis]  # 错误分析
```

---

## 📖 使用指南

### 快速开始

**阅读顺序**:
1. `COMMON_GUIDELINES.md` - 全局规范（必读）
2. `code-implementation/SKILL.md` - 代码实现入口
3. `code-implementation/COMMON.md` - 通用代码规范
4. `code-implementation/PROJECT.md` - Hi Kiki 规范

---

**维护者**: Hi Kiki Development Team
**版本**: v2.0 (分层架构)
**最后更新**: 2026-01-19
