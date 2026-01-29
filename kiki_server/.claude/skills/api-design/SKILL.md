---
name: api-design
description: |
  API 设计规范和最佳实践。包括 RESTful API 设计、接口文档生成、参数验证等。

  Triggers: designing APIs, "设计接口", "API 文档", "接口设计"
---

# API Design Skill

> **本 Skill 遵循**:
> - [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范 ⭐
> - [`COMMON.md`](./COMMON.md) - 通用 API 设计规范（RESTful 标准）
> - [`PROJECT.md`](./PROJECT.md) - Hi Kiki 项目 API 规范

---

## 🎯 When to Use

**激活条件**:
- 设计新的 API 接口时
- 用户询问"如何设计 API"、"接口设计"、"API 文档"
- 需要生成 API 文档时

---

## 📋 Workflow

### 1. 需求分析
- 明确 API 的业务目标
- 确定输入和输出数据
- 识别边界条件

### 2. 设计 API
- 选择 HTTP 方法（GET/POST/PUT/DELETE）
- 设计 URL 路径（RESTful 风格）
- 定义请求和响应格式
- 设计错误码

### 3. 生成文档
- 按照标准模板生成 API 文档
- 包含：接口名称、方法、路径、参数、响应、示例

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用 API 设计规范
- [`PROJECT.md`](./PROJECT.md) - Hi Kiki API 规范
- [`../code-implementation/SKILL.md`](../code-implementation/SKILL.md) - 代码实现

---

**版本**: v2.0
**最后更新**: 2026-01-19
