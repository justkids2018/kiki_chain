# API 契约体系

## 目标

API 是 Server、Flutter 用户端、Admin 管理后台共享的合同。API 契约必须独立于任何单端实现，作为跨端协作的仲裁标准。

## 唯一事实源

```text
docs/api/
├── README.md
├── endpoints/
└── schemas/
```

| 目录 | 用途 |
|---|---|
| `docs/api/endpoints/` | 接口路径、方法、参数、响应、错误码 |
| `docs/api/schemas/` | 共享数据结构 |
| `docs/api/README.md` | API 文档规范 |

## 各端职责

| 项目 | 职责 |
|---|---|
| `kiki_server/` | 按 `docs/api/` 实现接口 |
| `kiki_web/` | 按 `docs/api/` 调用用户端接口 |
| `kiki_admin/` | 按 `docs/api/` 调用管理端接口 |

后端可以在 `kiki_server/docs/` 写实现说明，但不能把它当跨端 API 契约。

## API 变更流程

1. 先更新 `docs/api/`。
2. 再更新后端实现。
3. 再更新 Web/Admin 调用。
4. 最后执行验证。

涉及接口变更时，PR 必须包含 API 文档更新。文档和代码冲突时，以 `docs/api/` 为准，除非本次变更明确先修正文档。

## 文档必填内容

每个接口必须包含：

- 接口描述
- 请求方法和路径
- 请求参数
- 响应结构
- 请求示例
- 响应示例
- 错误码
- 鉴权要求

## CI 门禁建议

后续可增加检查：

- 后端路由变更时提醒检查 `docs/api/`。
- API 文档中路径重复时报错。
- OpenAPI/Swagger 生成物与 `docs/api/` 对齐。

当前阶段先保持人工规则和 Agent 规则一致，不在本轮强制改运行逻辑。
