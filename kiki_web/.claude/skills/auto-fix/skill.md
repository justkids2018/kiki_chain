---
name: auto-fix
description: |
  🔄 自动修复需求验证报告中发现的问题

  完整流程：需求验证 → 修复规划 → 代码实现 → Code Review → 优化

  ⚠️ WORKFLOW:
  1. 分析验证报告中的问题
  2. 自动规划修复任务（按优先级）
  3. 调用 code-implementation 实现代码
  4. 自动调用 code-review 审查代码
  5. 根据审查结果优化代码

  Triggers: "自动修复", "auto fix", "修复验证报告的问题", "实现修复计划"
---

# Auto Fix Skill - 自动修复工作流

## When to Use

自动激活条件：
- 已完成需求验证，发现了问题
- 用户要求自动修复问题
- 用户说"自动帮我实现"、"你自动修复"
- 存在修复计划或验证报告

## Workflow Overview

```
┌─────────────────────────────────────────────────────────┐
│                   Auto Fix Workflow                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. 📋 Parse Validation Report                          │
│     └─ Extract Critical/Medium/Low issues              │
│                                                         │
│  2. 📝 Create Fix Plan                                  │
│     └─ Prioritize tasks (P0 → P1 → P2)                │
│     └─ Estimate time for each task                    │
│                                                         │
│  3. 🔧 Implement Fixes (for each task)                  │
│     └─ Call code-implementation skill                  │
│     └─ Write/Edit code files                          │
│     └─ Update related files                           │
│                                                         │
│  4. ✅ Code Review (automatic)                          │
│     └─ Call code-review skill                         │
│     └─ Check code quality                             │
│     └─ Identify improvements                          │
│                                                         │
│  5. 🔄 Optimize (if needed)                             │
│     └─ Fix issues found in review                     │
│     └─ Re-review                                      │
│                                                         │
│  6. 📊 Generate Report                                  │
│     └─ Summary of changes                             │
│     └─ Files modified                                 │
│     └─ Testing checklist                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Phase 1: Parse Validation Report

从验证报告中提取问题清单：

### Critical Issues (🔴 必须修复)
```markdown
- [ ] Issue 1: Data model mismatch
      - File: lib/domain/entities/user.dart
      - Action: Modify User entity fields
      - Estimated time: 2h

- [ ] Issue 2: Password plain text in memory
      - File: lib/presentation/controllers/auth_controller.dart
      - Action: Encrypt password in controller
      - Estimated time: 30min

- [ ] Issue 3: Profile Tab missing
      - File: lib/presentation/pages/profile/ (new)
      - Action: Create ProfileTab widget
      - Estimated time: 4h
```

### Medium Issues (🟡 建议修复)
```markdown
- [ ] Issue 4: Guest data migration
      - Files: auth_controller.dart, auth_repository.dart
      - Action: Implement migration logic
      - Estimated time: 6h

- [ ] Issue 5: Auto token refresh
      - File: auth_controller.dart
      - Action: Add timer for auto refresh
      - Estimated time: 3h
```

### Low Issues (🟢 可延后)
```markdown
- [ ] Issue 6: Internationalization incomplete
      - File: register_page.dart
      - Action: Replace hardcoded strings
      - Estimated time: 1h
```

## Phase 2: Create Fix Plan

为每个问题创建详细的修复计划：

### Task Template
```dart
/**
 * TASK: [Task Name]
 * PRIORITY: P0/P1/P2
 * ESTIMATED TIME: Xh
 *
 * FILES TO MODIFY:
 * - file1.dart
 * - file2.dart
 *
 * DEPENDENCIES:
 * - Task X must complete first
 *
 * IMPLEMENTATION STEPS:
 * 1. Step 1
 * 2. Step 2
 * 3. Step 3
 *
 * TESTING CHECKLIST:
 * - [ ] Test case 1
 * - [ ] Test case 2
 */
```

## Phase 3: Implement Fixes

对每个任务：

### Step 1: 准备修改
```
1. Read current file
2. Understand existing code
3. Plan modifications
```

### Step 2: 执行修改
```
1. Use Edit tool for existing files
2. Use Write tool for new files
3. Ensure code follows standards
4. Add logging and error handling
```

### Step 3: 验证修改
```
1. Check syntax
2. Verify logic
3. Ensure no breaking changes
```

## Phase 4: Code Review (Automatic)

**CRITICAL**: After implementing EACH task, MUST call:
```
Skill(skill="code-review")
```

Code review checks:
- ✅ Code quality
- ✅ Follows Flutter/Dart standards
- ✅ GetX best practices
- ✅ Null safety
- ✅ Error handling
- ✅ Performance
- ✅ Security

## Phase 5: Optimize

If code review finds issues:
```
1. Parse review feedback
2. Create optimization tasks
3. Re-implement fixes
4. Re-review
```

## Phase 6: Generate Report

Create a summary document:

```markdown
# Fix Implementation Report

## Date: YYYY-MM-DD
## Total Tasks: X
## Completed: Y

## Critical Issues Fixed (P0)
- [x] Issue 1: Description
      - Files: file1.dart, file2.dart
      - Changes: Summary of changes
      - Status: ✅ Completed & Reviewed

## Medium Issues Fixed (P1)
- [x] Issue 4: Description
      - Files: file3.dart
      - Changes: Summary
      - Status: ✅ Completed & Reviewed

## Testing Checklist
- [ ] Test case 1
- [ ] Test case 2
- [ ] Manual testing required

## Next Steps
1. Run tests
2. Verify functionality
3. Deploy to staging
```

## Best Practices

### ✅ DO
- 按优先级顺序修复（P0 → P1 → P2）
- 每完成一个任务就review
- 记录详细的修改日志
- 更新相关文档
- 保持代码风格一致

### ❌ DON'T
- 跳过code review
- 一次修改太多文件
- 忽略测试用例
- 破坏现有功能
- 引入新的依赖未经确认

## Integration with Other Skills

### Upstream Skills
- **requirement-clarification** → auto-fix
  - 需求验证后发现问题，调用auto-fix修复

### Downstream Skills
- auto-fix → **code-implementation**
  - 调用实现具体代码

- auto-fix → **code-review**
  - 自动审查实现的代码

- auto-fix → **bug-analysis**
  - 如果修复后仍有bug，分析原因

## Example Usage

### User Request
```
用户：帮我修复登录功能验证报告中的所有Critical问题
```

### Skill Response
```
1. 📋 解析验证报告：
   - 发现3个Critical问题
   - 2个Medium问题
   - 2个Low问题

2. 📝 创建修复计划：
   Phase 1: Critical问题（6.5小时）
   - Task 1: User数据模型修复 (2h)
   - Task 2: 密码加密提前 (30min)
   - Task 3: ProfileTab实现 (4h)

3. 🔧 开始实现Task 1...
   [调用code-implementation]

4. ✅ 审查Task 1...
   [调用code-review]

5. 继续Task 2...
   [重复3-4]

6. 📊 生成报告
```

## Template: Fix Plan Document

```markdown
# [Project Name] - Fix Implementation Plan

**Created**: YYYY-MM-DD
**Based on**: [Validation Report Name]
**Total Issues**: X Critical, Y Medium, Z Low
**Estimated Time**: Xh

---

## Phase 1: Critical Issues (MUST FIX)

### Task 1: [Issue Name]
- **Priority**: P0
- **Files**:
  - lib/path/to/file1.dart
  - lib/path/to/file2.dart
- **Estimated Time**: Xh
- **Dependencies**: None
- **Steps**:
  1. Step 1
  2. Step 2
- **Testing**:
  - [ ] Test case 1
- **Status**: 🔴 Not Started / 🟡 In Progress / ✅ Completed

---

## Phase 2: Medium Issues (RECOMMENDED)

### Task 4: [Issue Name]
- **Priority**: P1
- **Files**: [...]
- **Estimated Time**: Xh
- **Steps**: [...]
- **Status**: ⏳ Pending

---

## Implementation Log

### [Date] - Task 1
- ✅ Modified user.dart
- ✅ Updated auth_controller.dart
- ✅ Passed code review
- ⚠️ Minor optimization needed

---

## Summary
- Total tasks: X
- Completed: Y
- Remaining: Z
- Blocked: 0
```

---

## 🚨 CRITICAL: Execution Rules

1. **NEVER skip code review** - Every code change MUST be reviewed
2. **Follow priority order** - P0 → P1 → P2
3. **One task at a time** - Complete and review before next
4. **Document everything** - Keep detailed logs
5. **Test after each fix** - Verify functionality

---

**Auto-fix is a COMPLETE workflow that ensures code quality through automated review cycles.**
