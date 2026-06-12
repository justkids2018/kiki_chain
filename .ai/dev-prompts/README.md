# 开发规范索引

本目录包含项目开发过程中的各类规范文档，供开发者和 AI Agent 参考。

## 📋 规范列表

### 核心规范

- **[API 开发规范](./api-development-standards.md)** - API 接口设计、文档编写、前后端协作流程
- **[文档管理规范](./documentation-standards.md)** - 文档目录结构、命名规范、更新规则

### 规范使用说明

1. **开发者**：开发前阅读相关规范，确保代码和文档符合标准
2. **AI Agent**：执行任务前查阅对应规范，确保输出符合项目要求
3. **Code Review**：评审时检查是否遵循规范

## 🎯 快速查找

| 需求 | 规范文档 |
|------|----------|
| 开发新的 API 接口 | [API 开发规范](./api-development-standards.md) |
| 创建或更新文档 | [文档管理规范](./documentation-standards.md) |
| 查找文档位置 | [文档管理规范](./documentation-standards.md) → 文档查找规则 |

## 📝 规范编写指南

### 新增规范时应包含

1. **规范名称**：清晰的标题
2. **适用范围**：哪些场景需要遵循
3. **具体规则**：详细的规范内容
4. **示例**：正确和错误的示例
5. **检查清单**：可执行的检查项
6. **常见问题**：FAQ

### 规范文件命名

使用小写字母和连字符：`{topic}-standards.md`

示例：
- `api-development-standards.md`
- `code-review-standards.md`
- `testing-standards.md`

## 🤖 AI Agent 提示

当你（AI Agent）执行任务时：

1. **先查阅相关规范**：`.ai/dev-prompts/{topic}-standards.md`
2. **遵循规范要求**：确保输出符合规范
3. **更新规范**：发现规范不足时，建议补充

**记住：规范是为了提高效率和质量，不是束缚创造力！**
