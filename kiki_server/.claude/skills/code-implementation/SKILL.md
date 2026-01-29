---
name: code-implementation
description: |
  🔗 MUST AUTO-CHAIN to code-review after completion - DO NOT SKIP.

  ⚠️ COMPLETION CHECKLIST:
  1. Implement code using Write/Edit tools
  2. Verify changes are correct
  3. 🚨 MANDATORY: Immediately call Skill(skill="code-review") - THIS IS AUTOMATIC

  Code implementation standards and best practices for backend development.
  Includes Clean Architecture, async programming, error handling, and security.

  Triggers: implementing features, writing code, "如何实现", "写代码", "开发"
---

# Code Implementation Skill

> **本 Skill 遵循**:
> - [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范 ⭐
> - [`COMMON.md`](./COMMON.md) - 通用代码实现规范（适用所有项目/语言）
> - [`PROJECT.md`](./PROJECT.md) - Hi Kiki 项目特定规范（Rust + Axum）

---

## 🎯 When to Use

**自动激活条件**:
- 准备编写代码时
- 架构设计已完成，开始实现功能
- 用户询问"如何实现"、"怎么写代码"、"开发功能"
- 需要遵循项目代码规范

---

## 📋 Workflow

### 1. 上下文确认
> 遵循 [`COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) 的工作流

- ✅ 确认需求理解（最多提 3 个问题）
- ✅ 确认技术方案（架构、数据流）
- ❌ **禁止** 在此阶段输出成品代码

### 2. 设计与讨论
- ✅ 可发送"草案代码"或"伪代码"验证思路
- ✅ 识别风险（性能、安全、边界）
- ✅ 讨论实现方案

### 3. 代码实现
> **仅在收到明确"实现"或"交付代码"指令后执行**

#### 实现步骤

1. **参考规范**
   - 阅读 [`COMMON.md`](./COMMON.md) 了解通用规范
   - 阅读 [`PROJECT.md`](./PROJECT.md) 了解项目特定规范

2. **编写代码**
   - 遵循命名规范
   - 遵循架构模式
   - 添加必要注释（复杂逻辑说明"为什么"）

3. **自检清单**
   - [ ] 架构清晰，遵循分层原则
   - [ ] 依赖方向正确（内层不依赖外层）
   - [ ] 错误处理完善（无 panic 风险）
   - [ ] 安全性检查（SQL 注入、XSS、权限）
   - [ ] 性能考虑（大数据量、并发）
   - [ ] 日志记录关键操作

4. **🚨 自动触发 Code Review**
   - **代码实现完成后，立即自动调用** `Skill(skill="code-review")`
   - ❌ 不需要用户确认
   - ❌ 不能跳过此步骤

---

## 📑 交付清单

完成代码实现后，需提供：

### 1. 任务概览
```markdown
任务：[功能名称]
目标：[1-2 句话说明目标]
影响：[受影响的模块/文件/API]
```

### 2. 实现计划
```markdown
步骤：
1. [步骤 1]
2. [步骤 2]
...

受影响文件：
- path/to/file1.rs
- path/to/file2.rs
```

### 3. 代码变更
- **已有文件**: 使用 diff 格式
- **新文件**: 贴完整代码
- **复杂逻辑**: 附带功能注释

### 4. 测试建议
```markdown
测试策略：
- 单元测试：[测试哪些函数/方法]
- 集成测试：[测试哪些流程]
- 手动测试：[如何验证功能]
```

---

## 🚨 CRITICAL: Mandatory Post-Implementation

**代码实现完成后，必须立即执行**:

```
Skill(skill="code-review")
```

**这是强制的、自动的、不可跳过的步骤**:
- ❌ 不要询问用户是否需要
- ❌ 不要跳过此步骤
- ❌ 不要忘记
- ✅ 代码变更后立即执行

---

## 🔗 Integration with Other Skills

### 输入（依赖）
- **← requirement-clarification**: 需求澄清后进入代码实现
- **← api-design**: API 设计完成后进行实现

### 输出（链接）
- **→ code-review** (自动触发): 代码实现完成后自动审查
- **→ bug-analysis**: 如果发现错误，调用 bug-analysis 分析

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用代码实现规范
- [`PROJECT.md`](./PROJECT.md) - Hi Kiki 项目规范
- [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范
- [`../code-review/SKILL.md`](../code-review/SKILL.md) - 代码审查规范

---

**版本**: v2.0 (分层架构)
**最后更新**: 2026-01-19
**适用项目**: Hi Kiki Server (Rust Backend)
