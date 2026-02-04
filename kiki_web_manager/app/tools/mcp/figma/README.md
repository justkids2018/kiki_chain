# Figma MCP 本地服务器

本目录包含自建的 Figma Model Context Protocol 服务，方便按需扩展工具并与 Flutter 代码生成流程联动。

## 快速开始

1. **准备环境**
   - Node.js ≥ 18（部分依赖需 18+，如 `express@5`）。
   - npm 或 pnpm。
   - Figma 个人访问令牌（PAT）。

2. **复制环境变量**
   ```bash
   cd tools/mcp/figma
   cp .env.example .env
   ```
   编辑 `.env` 填写：
   ```ini
   FIGMA_PAT=你的PAT
   FIGMA_FILE_KEY=默认文件的 file key
   ```

3. **安装依赖**
   ```bash
   npm install
   ```

4. **启动服务器**
   ```bash
   npm run start
   ```
   看到日志 `[figma-mcp] server ready` 表示服务已监听。

5. **在 VS Code 中加载 manifest**
   - 安装 `Model Context Protocol` 扩展。
   - `⌘⇧P` → `MCP: Open Workspace Folder MCP Configuration`。
   - 将 `tools/mcp/figma/mcp.json` 添加到配置中。
   - 在 MCP 面板点击 **Start**，确认状态为 Running。

6. **测试工具**
   - 打开命令面板 `⌘⇧P` → `MCP: Run Tool`。
   - 选择 `figma.get_metadata`，输入 `{ "nodeId": "xxx" }`。
   - 若成功返回节点信息，表示链路连通。

## 常见问题

| 问题 | 可能原因 | 解决方案 |
| --- | --- | --- |
| `Missing FIGMA_PAT` | `.env` 未填写或未加载 | 检查 `.env` 并重启服务器 |
| `Node >=18` 报错 | 本机 Node 版本过低 | 使用 nvm / volta 升级 Node |
| 运行工具失败 | `nodeId` 不存在或文件不匹配 | 确保输入的 nodeId 和 fileKey 属于同一设计稿 |

## 下一步

- 在 `server/index.js` 中扩展更多工具（如批量导出、应用设计变量）。
- 编写脚本将生成的 Flutter 代码写入 `lib/presentation/page/test/generated`。
- 结合 `doc/task/chat/figma_mcp_roadmap.md` 的流程，完善设计转代码闭环。
