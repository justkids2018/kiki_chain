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
  1️⃣ 功能正确性（对照需求文档，不通过立即打回）
  2️⃣ 引用正确性（不通过立即打回）
     - 属性/方法存在性（如 result.errorMsg 不是 result.exception.message）
     - Import 正确性
     - 项目特定库使用
  3️⃣ 代码质量（规范/注释/性能/错误处理）
---

# Code Review Skill

## When to Use

自动激活条件：
- **主动触发**：代码编写完成后自动激活
- 用户明确要求"Review代码"
- 准备提交代码前
- 发现Bug需要检查代码质量时

## Core Patterns

### 1. Review 流程（三大核心）

**🚨 必须按顺序执行，任一失败则立即打回！**

```
第一步：功能正确性检查（MUST PASS）
  → 对照需求文档检查是否实现所有功能
  → 业务逻辑是否正确
  → 边界条件是否处理
  ❌ 不通过 → 立即打回，不继续review

第二步：引用正确性检查（MUST PASS）
  → 检查所有 import 是否存在
  → 检查所有类/方法/变量是否已定义
  → 检查是否使用了不存在的库（如 PenLog）
  → 检查是否使用了项目特定的库（YrLogger/YQResult）
  ❌ 不通过 → 立即打回，编译会失败

第三步：代码质量检查（重要）
  → 代码规范（命名/格式/风格）
  → 代码注释（复杂逻辑/公共API）
  → 性能优化（循环/内存/协程）
  → 错误处理（异常捕获/日志记录）
  ⚠️ 有问题 → 给出修改建议
```

### 2. 🚨 引用正确性检查（强制）

**这是最容易被忽略但会直接导致编译失败的问题！**

#### 检查步骤

1. **检查所有 import 语句**
   ```kotlin
   // ❌ 错误 - 不存在的类
   import com.yiqizuoye.library.yqpensdk.utils.PenLog

   // ✅ 正确 - 项目中存在的类
   import com.yiqizuoye.logger.YrLogger
   ```

2. **检查项目特定库的使用**
   - ✅ 日志：必须使用 `YrLogger`（不能用 `PenLog`、`Log`）
   - ✅ 网络：必须使用 `YQResult`
   - ✅ 用户信息：必须使用 `LoginUtils.getUserId()`

3. **检查属性/方法是否存在（重要！）**

   **检查方法**：
   - 在项目中搜索该类的定义或实际用法
   - 使用 Grep 查找其他地方如何使用该对象
   - 特别注意 when/if 分支中的属性访问

   **常见错误案例**：

   a) **YQResult.Error 的属性**
   ```kotlin
   // ❌ 错误 - YQResult.Error 没有 exception 属性
   is YQResult.Error -> {
       val msg = result.exception.message  // 编译失败！
   }

   // ✅ 正确 - 应该使用 errorMsg 属性
   is YQResult.Error -> {
       val msg = result.errorMsg  // 正确
   }

   // 验证方法：搜索项目中其他地方如何使用
   // grep -r "is YQResult.Error" --include="*.kt" -A 2
   ```

   b) **HttpResult 的数据访问**
   ```kotlin
   // ⚠️ 注意 - HttpResult 包装了一层，需要两次 data
   is YQResult.Success -> {
       val data = result.data.data  // result.data 是 HttpResult，再访问 .data
   }
   ```

   c) **对象方法调用**
   ```kotlin
   // ❌ 错误 - 调用不存在的方法
   someObject.nonExistentMethod()

   // ✅ 正确 - 先确认方法存在
   someObject.existingMethod()
   ```

   **Review 步骤**：
   1. 找到所有 `result.xxx` / `object.xxx` 形式的属性/方法访问
   2. 使用 Grep 搜索该类在项目中的其他用法
   3. 对比确认属性/方法名是否正确

4. **检查拼写错误**
   ```kotlin
   // ❌ 错误 - 拼写错误
   YrLoger.i(TAG, "message")  // Logger 拼成了 Loger

   // ✅ 正确
   YrLogger.i(TAG, "message")
   ```

5. **检查循环依赖**
   - A 引用 B，B 引用 A → ❌ 循环依赖
   - 使用工具或手动检查 import 链

#### 自动化验证（推荐）

```bash
# Android 项目编译检查
./gradlew assembleDebug --dry-run

# 如果编译失败，说明存在引用错误
```

#### Review 时必查项（重要性排序）

**优先级1 - 属性/方法存在性（最容易遗漏）**
- [ ] 所有 `result.xxx` 属性访问都正确
  - `YQResult.Error` 使用 `errorMsg`（不是 `exception.message`）
  - `YQResult.Success` 需要 `result.data.data`（两层）
- [ ] 所有 `object.method()` 调用都存在
- [ ] when/if 分支中的属性访问都验证过

**优先级2 - Import 和库使用**
- [ ] 所有 import 语句都指向存在的类
- [ ] 没有使用 `PenLog`（项目中不存在）
- [ ] 所有日志使用 `YrLogger`
- [ ] 所有网络请求使用 `YQResult`

**优先级3 - 其他**
- [ ] 没有拼写错误导致的引用失败
- [ ] 没有循环依赖

**🔍 检查方法（强烈推荐）**：
```bash
# 1. 查找所有属性访问
grep -r "result\\..*\\." --include="*.kt" | grep -v "result.data"

# 2. 查找项目中如何使用 YQResult.Error
grep -r "is YQResult.Error" --include="*.kt" -A 2

# 3. 运行编译检查（最可靠）
./gradlew assembleDebug --dry-run
```

### 3. 完整性检查（15项）

基于 `checklists/code-quality.md`：

#### 1. 功能完整性
- [ ] 所有设计的功能都已实现
- [ ] 所有必要的文件都已修改
- [ ] 没有遗漏的 TODO 注释
- [ ] 没有注释掉的代码（除非有说明）
- [ ] 所有引用的资源都存在（图片/文件/API等）

#### 2. 准确性
- [ ] 代码逻辑符合架构设计
- [ ] 数据模型实现正确
- [ ] UI组件符合设计稿
- [ ] 业务逻辑准确无误
- [ ] 命名规范统一（变量/函数/类）

#### 3. 可测试性
- [ ] 关键逻辑有测试用例
- [ ] 边界条件有测试覆盖
- [ ] 错误情况有测试验证
- [ ] 测试数据准备充分
- [ ] Mock/Stub 使用合理

#### 4. 可复用性
- [ ] 没有重复代码（遵循 DRY 原则）
- [ ] 组件/函数职责单一
- [ ] 可复用的逻辑已提取
- [ ] 配置项与代码分离
- [ ] 魔法数字/字符串已常量化

#### 5. 一致性
- [ ] 代码风格一致（缩进/命名/格式）
- [ ] 与现有代码风格保持一致
- [ ] API 命名风格统一
- [ ] 错误处理方式统一
- [ ] 日志格式统一
- [ ] **使用项目特定的库（重要！）**
  - ✅ 日志：使用 `com.yiqizuoye.logger.YrLogger`（不是 PenLog/Log）
  - ✅ 网络：使用 `com.yiqizuoye.library.network.YQResult`
  - ✅ 登录：使用 `LoginUtils.getUserId()`
  - ❌ 禁止使用不存在的库（如 PenLog）

#### 6. 设计合理性
- [ ] 没有过度设计
- [ ] 没有性能瓶颈
- [ ] 数据结构设计合理
- [ ] 算法效率可接受
- [ ] 内存使用合理

#### 7. 错误处理
- [ ] 所有可能的异常都已捕获
- [ ] 错误信息清晰明确
- [ ] 错误不会导致崩溃
- [ ] 用户友好的错误提示
- [ ] 记录足够的错误日志

#### 8. 数据安全
- [ ] 没有 SQL 注入风险
- [ ] 没有 XSS 风险
- [ ] 敏感数据已加密
- [ ] 输入数据已验证
- [ ] 权限控制正确

#### 9. 注释与文档
- [ ] 复杂逻辑有注释说明
- [ ] 公共 API 有文档注释
- [ ] 关键算法有说明
- [ ] 特殊处理有原因说明
- [ ] 不使用误导性注释

#### 10. 性能优化
- [ ] 没有不必要的计算
- [ ] 循环优化合理
- [ ] 数据库查询优化
- [ ] 避免内存泄漏
- [ ] 资源正确释放

#### 11. 用户体验
- [ ] 加载状态有提示
- [ ] 操作有反馈
- [ ] 错误有友好提示
- [ ] 关键操作有确认
- [ ] 界面响应及时

#### 12. 数据迁移
- [ ] 考虑了旧数据兼容
- [ ] 有数据迁移方案
- [ ] 迁移脚本已测试
- [ ] 回滚方案已准备
- [ ] 数据完整性验证

#### 13. 依赖管理
- [ ] 新依赖有必要性说明
- [ ] 依赖版本明确
- [ ] 许可证兼容
- [ ] 没有循环依赖
- [ ] 依赖安全性检查

#### 14. Git 提交
- [ ] 提交信息清晰
- [ ] 相关修改在同一提交
- [ ] 没有包含调试代码
- [ ] 没有包含敏感信息
- [ ] 分支命名规范

#### 15. 符合 doc/tel 规范
- [ ] 代码变更文档完整
- [ ] 示例与调用路径清晰
- [ ] 测试策略明确
- [ ] 运维与监控考虑完整
- [ ] 风险与决策记录清晰

### 4. 评分标准（新）

```
🚨 强制检查（必须通过，否则立即打回）

1. 功能正确性：✅ 通过 / ❌ 不通过
   - 不通过 → 立即打回，重新实现

2. 引用正确性：✅ 通过 / ❌ 不通过
   - 不通过 → 立即打回，编译会失败

代码质量评分（通过上述检查后评估）

- 优秀（90%+）：代码规范、注释完整、性能优秀
- 良好（70-89%）：整体不错，小问题可以修复后合并
- 需改进（<70%）：需要重构或大幅修改
```

### 5. Review反馈格式（新）

```markdown
## 代码审查报告

**审查文件**：`文件路径`
**审查时间**：YYYY-MM-DD

---

### 🚨 第一步：功能正确性检查

**状态**：✅ 通过 / ❌ 不通过

#### 需求对照
- [x] 需求1：XXX 功能已实现
- [x] 需求2：XXX 边界条件已处理
- [ ] 需求3：XXX 未实现 ❌

#### 问题（如果有）
1. **未实现的功能**
   - 问题：需求文档要求 XXX，但代码中未找到
   - 位置：应该在 `XXX.kt` 中实现
   - 建议：[具体实现方案]

**结论**：❌ 功能不完整，立即打回

---

### 🚨 第二步：引用正确性检查

**状态**：✅ 通过 / ❌ 不通过

#### 1. 属性/方法存在性检查（优先级最高）
- [ ] 所有 `result.xxx` 属性访问正确 ❌
- [x] 所有 `object.method()` 调用存在
- [x] when/if 分支中的属性已验证

#### 2. Import 检查
- [x] 所有 import 语句正确
- [ ] 使用了不存在的库 ❌

#### 3. 项目特定库检查
- [x] 日志使用 YrLogger
- [ ] 错误使用了 PenLog ❌
- [x] 网络请求使用 YQResult

#### 问题（如果有）
1. **❌ 访问不存在的属性（严重）**
   - 位置：`StarfishRewardManager.kt:134, 223`
   - 问题：`result.exception.message`
   - 分析：`YQResult.Error` 没有 `exception` 属性，只有 `errorMsg`
   - 验证：搜索其他用法 `grep -r "is YQResult.Error" -A 2`
   - 影响：编译失败
   - 建议：
     ```kotlin
     // ❌ 错误
     is YQResult.Error -> {
         val errorMsg = result.exception.message
     }

     // ✅ 正确
     is YQResult.Error -> {
         val errorMsg = result.errorMsg
     }
     ```

2. **❌ 使用了不存在的库**
   - 位置：`StarfishRewardManager.kt:6`
   - 问题：`import com.yiqizuoye.library.yqpensdk.utils.PenLog`
   - 影响：编译失败
   - 建议：
     ```kotlin
     // 修改为
     import com.yiqizuoye.logger.YrLogger
     ```

**结论**：❌ 引用错误，立即打回

---

### ✅ 第三步：代码质量检查

**评分**：85%（良好）

#### ✅ 做得好的地方
1. 协程使用规范，Job 管理正确
2. 异常处理完整，包含 CancellationException
3. 线程安全，使用了 AtomicBoolean

#### ⚠️ Critical - 必须修复（0项）
无

#### ⚠️ Warning - 应该修复（2项）
1. **缺少关键注释**
   - 位置：`StarfishRewardManager.kt:105-153`
   - 问题：init() 方法逻辑复杂，但缺少注释
   - 建议：添加关键步骤注释

2. **魔法数字**
   - 位置：多处使用硬编码字符串
   - 建议：提取为常量

#### 💡 Suggestion - 可以改进（1项）
1. **性能优化**
   - 建议：考虑使用 StateFlow 替代 volatile 变量

---

### 📊 总体评价

- **功能正确性**：✅ 通过
- **引用正确性**：✅ 通过
- **代码质量**：85%（良好）

**结论**：✅ 修复 2 个 Warning 问题后可以合并

**下次改进方向**：
1. 增加关键逻辑注释
2. 提取魔法数字为常量
```

## Anti-Patterns

### ❌ 错误做法

1. **只看代码，不看需求**
   ```
   ❌ 只检查代码是否有bug
   ✅ 检查代码是否实现了需求文档中的所有功能
   ```

2. **只提问题，不给方案**
   ```
   ❌ "这里有问题"
   ✅ "这里有问题，建议修改为：[代码示例]"
   ```

3. **过于主观**
   ```
   ❌ "我觉得这样写不好"
   ✅ "违反了单一职责原则，建议拆分成两个函数"
   ```

4. **忽略小问题**
   ```
   ❌ "小问题不重要，不用管"
   ✅ "虽然是小问题，但影响可读性，建议修复"
   ```

5. **批量提出问题**
   ```
   ❌ 一次提出20个问题，让开发者overwhelmed
   ✅ 按优先级分类：Critical > Warning > Suggestion
   ```

## Integration with Other Skills

1. **← requirement-clarification**
   - 对照需求文档检查功能完整性

2. **← architecture-design**
   - 检查实现是否符合架构设计

3. **← ui-design-system**
   - 检查UI是否符合设计规范

4. **← code-implementation**
   - 检查是否遵循代码规范

## Automated Checks

在手动Review前，先运行自动化检查：

```bash
# 1. 代码格式检查
npm run lint

# 2. 类型检查
npm run typecheck

# 3. 单元测试
npm test

# 4. 代码覆盖率
npm run test:coverage

# 5. 构建检查
npm run build
```

**如果自动化检查不通过，不要进行手动Review！**

## Best Practices

1. **先表扬，再批评**
   - 先说做得好的地方
   - 再指出需要改进的地方

2. **提供上下文**
   - 说明为什么这是问题
   - 解释背后的原理

3. **给出具体建议**
   - 不只说"有问题"
   - 给出具体的修改代码

4. **区分优先级**
   - Critical：必须修复
   - Warning：应该修复
   - Suggestion：可以改进

5. **鼓励学习**
   - 推荐相关资料
   - 解释最佳实践

## 🚨 项目特定检查规则

### 必须检查的项目特定库

在代码审查时，必须检查以下项目特定的库使用：

#### 1. 日志库
- ✅ **正确**：使用 `com.yiqizuoye.logger.YrLogger`
  ```kotlin
  import com.yiqizuoye.logger.YrLogger
  YrLogger.i(TAG, "message")
  YrLogger.e(TAG, "error message")
  ```
- ❌ **错误**：使用 `PenLog` 或 `android.util.Log`
  ```kotlin
  import com.yiqizuoye.library.yqpensdk.utils.PenLog  // ❌ 不存在
  import android.util.Log  // ❌ 不使用系统日志
  ```

#### 2. 网络库
- ✅ **正确**：使用 `com.yiqizuoye.library.network.YQResult`
  ```kotlin
  import com.yiqizuoye.library.network.YQResult
  when (result) {
      is YQResult.Success -> { }
      is YQResult.Error -> { }
  }
  ```

#### 3. 用户信息
- ✅ **正确**：使用 `LoginUtils.getUserId()`
  ```kotlin
  val userId = LoginUtils.getUserId()
  ```

### Review时必须验证
- [ ] 所有日志调用使用 `YrLogger`
- [ ] 没有 `PenLog` 的 import 语句
- [ ] 没有 `android.util.Log` 的使用
- [ ] 网络请求使用 `YQResult`
- [ ] 用户信息通过 `LoginUtils` 获取

---

## 📋 快速参考

### Review 三步流程（强制）

```
┌─────────────────────────────────────────┐
│ 第一步：功能正确性检查 (MUST PASS)      │
├─────────────────────────────────────────┤
│ □ 对照需求文档逐项检查                  │
│ □ 业务逻辑是否正确                      │
│ □ 边界条件是否处理                      │
│ ❌ 不通过 → 立即打回                     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 第二步：引用正确性检查 (MUST PASS)      │
├─────────────────────────────────────────┤
│ ✪ 属性/方法存在性（优先级最高）         │
│   □ result.errorMsg（不是 exception）   │
│   □ result.data.data（两层）            │
│   □ 验证：grep 搜索其他用法             │
│ □ 所有 import 是否存在                  │
│ □ 没有使用 PenLog（不存在）             │
│ □ 日志使用 YrLogger                     │
│ □ 网络使用 YQResult                     │
│ ❌ 不通过 → 立即打回（编译失败）         │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 第三步：代码质量检查                    │
├─────────────────────────────────────────┤
│ □ 代码规范（命名/格式）                 │
│ □ 代码注释（复杂逻辑/公共API）          │
│ □ 性能优化（循环/内存/协程）            │
│ □ 错误处理（异常/日志）                 │
│ ⚠️ 有问题 → 给出修改建议                │
└─────────────────────────────────────────┘
```

### 项目特定库（必查）

| 功能 | ✅ 正确 | ❌ 错误 |
|------|---------|---------|
| 日志 | `YrLogger` | `PenLog`, `Log` |
| 网络 | `YQResult` | 其他 |
| 用户 | `LoginUtils.getUserId()` | 直接获取 |

### 评分标准

- **功能正确性**：通过 / 不通过（不通过直接打回）
- **引用正确性**：通过 / 不通过（不通过直接打回）
- **代码质量**：
  - 优秀（90%+）
  - 良好（70-89%）
  - 需改进（<70%）

---

## ⚠️ 常见错误案例速查表

### 1. YQResult.Error 属性错误
```kotlin
// ❌ 错误 - 会导致编译失败
is YQResult.Error -> {
    val msg = result.exception.message  // YQResult.Error 没有 exception 属性！
}

// ✅ 正确
is YQResult.Error -> {
    val msg = result.errorMsg  // 使用 errorMsg 属性
}
```
**检查方法**：`grep -r "is YQResult.Error" --include="*.kt" -A 2`

### 2. HttpResult 数据访问
```kotlin
// ⚠️ 注意 - HttpResult 包装了一层
is YQResult.Success -> {
    val data = result.data.data  // 需要两次 .data
    // result.data 是 HttpResult<T>
    // result.data.data 是 T
}
```

### 3. 日志库错误
```kotlin
// ❌ 错误 - PenLog 不存在
import com.yiqizuoye.library.yqpensdk.utils.PenLog
PenLog.i(TAG, "message")

// ✅ 正确
import com.yiqizuoye.logger.YrLogger
YrLogger.i(TAG, "message")
```

### 4. 拼写错误
```kotlin
// ❌ 错误 - Logger 拼成 Loger
YrLoger.i(TAG, "message")

// ✅ 正确
YrLogger.i(TAG, "message")
```

**Review 时必须检查这些常见错误！**

