# Agent Entry

## Source Of Truth

Project-level agent behavior must follow shared platform governance.
Read these files first:

1. `.ai/system-platform/README.md`
2. `.ai/common-prompt/baseline/README.md`
3. `.github/copilot-instructions.md`

## Project-Specific Notes

Keep project-specific operational details in project docs (for example `docs/project-ops.md`),
not in this entry file.

For `kiki_web` architecture generation, use project-owned docs in `docs/architecture/` as the baseline.
For `kiki_web` implementation rules, follow `docs/architecture/kiki_web_flutter_simplified_ddd_architecture.md` and `docs/architecture/kiki_web_flutter_simplified_ddd_implementation_guide.md`.

## Documentation Standards

### 1. 文档目录统一规范

- **统一使用 `docs` 目录**：所有项目文档必须放在 `docs/` 目录下，不使用 `doc/` 目录
- 项目级文档结构：
  ```
  docs/
  ├── api/              # API 接口文档（重要）
  ├── architecture/     # 架构设计文档
  ├── deployment/       # 部署相关文档
  ├── database/         # 数据库设计文档
  └── ...               # 其他功能模块文档
  ```
- 子项目文档：`kiki_web/docs/`、`kiki_server/docs/` 遵循相同规范

### 2. API 文档强制要求

**核心原则：前后端接口以 API 文档为唯一标准，保证接口一致性**

#### 2.1 文档位置
- 统一放在 `docs/api/` 目录
- 按功能模块组织：`docs/api/endpoints/{module}.md`
- 参考：`docs/api/README.md` 了解完整规范

#### 2.2 强制更新规则
**每次开发新功能时，必须同步更新 API 文档，包括：**
- 新增接口：添加完整接口文档
- 修改接口：更新参数、响应结构或说明
- 删除接口：标记为已废弃并说明替代方案

#### 2.3 接口文档必填内容
每个接口必须包含：
- 接口描述、请求方式、接口路径
- 请求参数（包括类型、必填、说明、示例）
- 响应参数（包括数据结构说明）
- 请求和响应示例（完整 JSON）
- 错误码说明和处理建议

#### 2.4 前后端协作流程
1. **接口设计阶段**：后端先编写 API 文档
2. **评审确认**：前后端评审接口文档
3. **并行开发**：前端根据文档 mock，后端根据文档实现
4. **联调验证**：以文档为标准验证接口一致性
5. **文档同步**：任何变更必须立即更新文档

#### 2.5 Code Review 检查点
- PR 中如果涉及接口变更，必须包含对应的 API 文档更新
- 文档与代码不一致时，PR 不予通过

### 3. 响应格式统一规范

所有 API 接口响应必须遵循统一格式：

```json
{
  "code": 200,           // 状态码：200 成功，其他为错误码
  "message": "success",  // 响应消息
  "data": {}             // 业务数据（可为对象或数组）
}
```

## Execution Rule

- Prefer skill-first routing.
- Respect baseline boundaries and quality gates.
- For high-risk changes, require explicit review and rollback plan.
- **Documentation-driven development**: API 文档先行，代码跟随文档实现
- **Documentation consistency**: 每次代码变更必须检查并更新相关文档
