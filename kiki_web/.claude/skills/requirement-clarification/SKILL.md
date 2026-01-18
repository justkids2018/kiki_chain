---
name: requirement-clarification
description: |
  **AUTO-ACTIVATE when user mentions**: new feature, add functionality, implement,
  create, build, "I want to", unclear requirements, vague ideas.

  Asks 3 core questions to clarify requirements. Generates requirement documents
  with clarity scores. Has templates for: priority features, search, forms, etc.

  Triggers: new feature, add, implement, create, unclear, vague, requirement
---

# Requirement Clarification Skill

## When to Use

自动激活条件：
- 用户提到"新功能"、"需求"、"想要添加"
- 用户描述的需求模糊不清
- 用户询问"如何定义需求"
- 用户提到特定功能类型（优先级、搜索、表单等）

## Core Patterns

### 1. 需求澄清流程

**原则**：
- 最多问 3 个核心问题，避免过度询问
- 问题要针对性强，直击核心
- 提供选项而非开放问题
- 关注"什么"而非"如何"（技术实现留给架构阶段）

**标准提问结构**：
```
问题 1：数据结构/核心功能
  → 明确功能的数据模型和核心能力

问题 2：UI/UX 设计
  → 明确用户如何使用和看到这个功能

问题 3：功能范围/边界
  → 明确哪些做、哪些不做、默认值、边界情况
```

### 2. 需求文档模板

使用 `templates/requirement-doc.md` 生成标准化需求文档：

**必须包含的章节**：
```markdown
## 1. 任务概览
- 关键目标（3个以内）
- 背景说明
- 受影响范围

## 2. 上下文与假设
- 数据结构
- UI/UX 描述
- 功能范围（必须/可选/未来）
- 边界与约束

## 3. 需求明确度
- 数据结构明确度
- UI设计明确度
- 功能范围明确度
- 总体明确度百分比
```

### 3. 场景化提问模板

针对常见功能类型，使用预设提问模板：

**优先级功能** → `prompts/priority-feature.md`
- 问等级数量（3级/5级）
- 问展示方式（颜色/图标/标签）
- 问关联功能（排序/筛选/批量修改）

**搜索功能** → `prompts/search-feature.md`
- 问搜索范围（标题/内容/标签）
- 问搜索类型（模糊/精确/高级）
- 问结果展示（列表/高亮/分页）

**表单功能** → `prompts/form-feature.md`
- 问字段类型和验证规则
- 问提交行为和错误处理
- 问数据持久化方式

### 4. 需求明确度评估

在生成需求文档后，评估明确度：

```javascript
评分维度：
- 数据结构：[明确 = 100% | 部分明确 = 60% | 不明确 = 20%]
- UI设计：[明确 = 100% | 部分明确 = 60% | 不明确 = 20%]
- 功能范围：[明确 = 100% | 部分明确 = 60% | 不明确 = 20%]
- 边界条件：[明确 = 100% | 部分明确 = 60% | 不明确 = 20%]

总体明确度 = 平均值

建议：
- ≥ 80%：可以进入架构设计阶段
- 60-79%：补充关键信息后再继续
- < 60%：需要重新澄清需求
```

## Anti-Patterns

### ❌ 错误做法

1. **过度询问**
   ```
   ❌ 问10个问题，让用户疲惫
   ✅ 问3个核心问题，快速进入开发
   ```

2. **问技术实现**
   ```
   ❌ "用什么数据库存储？"
   ✅ "需要存储哪些数据？"
   ```

3. **没有提供选项**
   ```
   ❌ "你想要什么样的UI？"（太开放）
   ✅ "UI展示方式：颜色标识 / 图标 / 文字标签？"
   ```

4. **忽略边界情况**
   ```
   ❌ 只关注正常流程
   ✅ 必须明确默认值、异常情况、数据迁移
   ```

5. **需求文档不完整**
   ```
   ❌ 只记录功能，没有约束和假设
   ✅ 使用标准模板，包含所有必要章节
   ```

## Integration with Other Skills

需求澄清后，自然衔接到其他 Skills：

1. **→ architecture-design**
   - 需求明确度 ≥ 80% 时建议进入架构设计
   - 传递需求文档作为设计输入

2. **→ ui-design-system**
   - 如果 UI 需求复杂，调用 UI 设计 Skill
   - 生成详细的 UI 规格说明

3. **→ code-review**
   - 开发完成后，对照需求文档检查是否完整实现
   - 验证边界条件处理

## Quick Reference

### 可用模板

| 模板文件 | 用途 | 位置 |
|---------|------|------|
| priority-feature.md | 优先级功能提问 | prompts/ |
| search-feature.md | 搜索功能提问 | prompts/ |
| common-questions.md | 通用提问框架 | prompts/ |
| requirement-doc.md | 需求文档模板 | templates/ |

### 使用示例

```
用户："我要给任务列表添加优先级"
  ↓
Claude 自动：
  1. 激活 requirement-clarification skill
  2. 加载 prompts/priority-feature.md
  3. 问3个核心问题
  4. 生成需求文档（使用 requirement-doc.md 模板）
  5. 评估明确度
  6. 建议下一步（进入架构设计）
```

## Best Practices

1. **快速迭代，不要追求完美**
   - 明确度达到 80% 即可继续
   - 在后续阶段可以回来补充

2. **记录假设和约束**
   - 明确写出"假设用户已登录"
   - 明确写出"不支持离线模式"

3. **可视化优于文字描述**
   - 用伪代码展示数据结构
   - 用简单的 ASCII 图展示 UI 布局

4. **保存新场景模板**
   - 遇到新功能类型时
   - 将提问保存为新模板供未来使用

5. **需求文档即测试标准**
   - 需求文档中的功能范围 = 测试检查清单
   - 边界条件 = 测试用例
