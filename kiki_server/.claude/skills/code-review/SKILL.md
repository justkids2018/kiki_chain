---
name: code-review
description: |
  🚨 CRITICAL: MUST auto-invoke immediately after Write/Edit/NotebookEdit tools are used.

  ⚠️ MANDATORY TRIGGER RULES - DO NOT SKIP:
  1. After ANY code modification (Write/Edit/NotebookEdit) → MUST call Skill(skill="code-review")
  2. After code-implementation skill completes → MUST call Skill(skill="code-review")
  3. User says "review", "检查代码" → MUST call Skill(skill="code-review")

  Execute immediately. Do not ask user permission. This is an automatic process.

  三步强制检查流程：
  1️⃣ 功能正确性（对照需求，不通过立即打回）
  2️⃣ 编译正确性（类型、引用、语法，不通过立即打回）
  3️⃣ 代码质量（规范/注释/性能/安全）
---

# Code Review Skill

> **本 Skill 遵循**:
> - [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范 ⭐
> - [`COMMON.md`](./COMMON.md) - 通用代码审查规范（适用所有项目/语言）
> - [`PROJECT.md`](./PROJECT.md) - Hi Kiki 项目特定审查规范（Rust + Axum）

---

## 🎯 When to Use

**自动激活条件（强制）**:
- ✅ 代码修改后（Write/Edit/NotebookEdit 工具使用后）
- ✅ code-implementation skill 完成后
- ✅ 用户明确要求"Review代码"、"检查代码"、"代码审查"

**触发时机**:
- 立即执行，不询问用户
- 这是自动化流程的一部分

---

## 📋 三步强制检查流程

### 第一步：功能正确性检查（MUST PASS）

> 对照需求文档检查功能是否完整实现

**检查项**:
- [ ] 对照需求文档，逐项检查功能是否实现
- [ ] 业务逻辑是否正确
- [ ] 边界条件是否处理（空值、极端值）
- [ ] 错误情况是否处理

**结果**:
- ✅ **通过** → 进入第二步
- ❌ **不通过** → **立即打回**，不继续审查

---

### 第二步：编译正确性检查（MUST PASS）

> 检查代码是否能成功编译，引用是否正确

**检查项**:
- [ ] 类型系统：所有类型是否正确
- [ ] 引用完整：所有 import/use 是否存在
- [ ] 方法/属性：调用的方法/属性是否存在
- [ ] 依赖正确：使用的依赖是否已声明

**结果**:
- ✅ **通过** → 进入第三步
- ❌ **不通过** → **立即打回**，代码无法编译

---

### 第三步：代码质量检查

> 检查代码规范、性能、安全性

**检查项**:
- [ ] 代码规范（命名、格式、风格）
- [ ] 代码注释（复杂逻辑、公共 API）
- [ ] 性能优化（循环、内存、并发）
- [ ] 错误处理（异常捕获、日志记录）
- [ ] 安全性（SQL 注入、XSS、权限）
- [ ] 测试覆盖（单元测试、集成测试）

**结果**:
- ⚠️ **有问题** → 给出分级建议（Critical / Warning / Suggestion）

---

## 📝 Review 反馈格式

```markdown
## 代码审查报告

**审查文件**: `路径/文件名.rs`
**审查时间**: YYYY-MM-DD

---

### 🚨 第一步：功能正确性检查

**状态**: ✅ 通过 / ❌ 不通过

#### 需求对照
- [x] 需求1：用户登录功能 - 已实现
- [x] 需求2：密码验证 - 已实现
- [ ] 需求3：验证码功能 - 未实现 ❌

#### 问题（如果有）
1. **未实现的功能**
   - 问题：需求要求支持验证码登录，但代码中未找到
   - 位置：应该在 `login_user.rs` 中实现
   - 建议：[具体实现方案]

**结论**: ❌ 功能不完整，立即打回

---

### 🚨 第二步：编译正确性检查

**状态**: ✅ 通过 / ❌ 不通过

#### 类型检查
- [x] 所有类型定义正确
- [x] 所有类型转换安全

#### 引用检查
- [x] 所有 use 语句正确
- [x] 所有调用的方法/函数存在
- [ ] 使用了不存在的 trait 方法 ❌

#### 问题（如果有）
1. **调用不存在的方法**
   - 位置：`user_repository.rs:45`
   - 问题：`user.get_id()` 方法不存在
   - 影响：编译失败
   - 建议：改为 `user.id()`

**结论**: ❌ 编译错误，立即打回

---

### ✅ 第三步：代码质量检查

**评分**: 85%（良好）

#### ✅ 做得好的地���
1. 错误处理规范，使用 Result 类型
2. 异步处理正确，使用 async/await
3. 日志记录完整

#### ⚠️ Critical - 必须修复（0项）
无

#### ⚠️ Warning - 应该修复（2项）
1. **缺少关键注释**
   - 位置：`login_user.rs:50-80`
   - 问题：复杂的业务逻辑缺少注释
   - 建议：添加说明"为什么"的注释

2. **可能的性能问题**
   - 位置：`user_repository.rs:120`
   - 问题：循环中多次数据库查询
   - 建议：使用批量查询

#### 💡 Suggestion - 可以改进（1项）
1. **代码复用**
   - 建议：提取重复的验证逻辑为独立函数

---

### 📊 总体评价

- **功能正确性**: ✅ 通过
- **编译正确性**: ✅ 通过
- **代码质量**: 85%（良好）

**结论**: ✅ 修复 2 个 Warning 问题后可以合并

**下次改进方向**:
1. 增加关键逻辑注释
2. 优化数据库查询性能
```

---

## 🔗 Integration with Other Skills

### 输入（依赖）
- **← code-implementation**: 代码实现完成后自动触发审查
- **← requirement-clarification**: 对照需求文档检查功能完整性

### 输出（链接）
- **→ bug-analysis**: 如果发现严重问题，可能需要错误分析

---

## ⚠️ 重要提醒

### 强制执行规则

1. **立即执行，不询问**
   - ❌ 不要询问用户"是否需要审查"
   - ✅ 代码修改后立即自动审查

2. **三步检查顺序不能变**
   - 第一步不通过 → 立即打回，不进行第二步
   - 第二步不通过 → 立即打回，不进行第三步

3. **审查必须具体**
   - ❌ 不要只说"有问题"
   - ✅ 指出具体位置、具体问题、具体建议

4. **区分问题优先级**
   - **Critical**: 必须修复（安全、编译错误）
   - **Warning**: 应该修复（性能、规范）
   - **Suggestion**: 可以改进（优化、重构）

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用代码审查规范
- [`PROJECT.md`](./PROJECT.md) - Hi Kiki 项目审查规范
- [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范
- [`../code-implementation/SKILL.md`](../code-implementation/SKILL.md) - 代码实现规范

---

**版本**: v2.0 (分层架构)
**最后更新**: 2026-01-19
**适用项目**: Hi Kiki Server (Rust Backend)
