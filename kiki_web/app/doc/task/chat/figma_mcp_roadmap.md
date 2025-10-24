# Figma MCP 联动与设计转代码统一步骤

> 目标：在本地快速搭建 Figma Model Context Protocol (MCP) 服务器，通过 `mcp.json` 发布能力，并梳理从 Figma 设计稿拉取节点到生成 Flutter 代码的完整操作链，最终落地到 `page/test` 目录的演示实现。

## 1. 准备工作

1. **安装基础工具**
   - Node.js ≥ 18（含 npm / pnpm）。
   - VS Code 或支持 MCP 的 IDE（需安装 MCP 客户端扩展，示例：`Model Context Protocol` 扩展）。
   - Dart / Flutter SDK（用于生成代码后验证）。

2. **配置 Figma 访问凭证**
   - 访问 [Figma Personal Access Token](https://www.figma.com/developers/api#access-tokens) 页面，生成 PAT。
   - 记录目标文件的 File Key（Figma 地址中 `https://www.figma.com/design/<fileKey>/...` 部分）。
   - 建议将 PAT 写入 `.env` 或 macOS 钥匙串，避免硬编码。

3. **仓库目录约定**
   ```
   tools/
     mcp/
       figma/
         server/        # MCP 服务端代码
         .env           # Figma PAT 等敏感信息（加入 .gitignore）
         mcp.json       # MCP manifest
   ```

## 1.1 对比：官方远程 MCP 服务器

- Figma 官方在 `https://mcp.figma.com/mcp` 提供托管版远程服务器，无需本地实现。
- 适用条件：需拥有 Figma Dev 或 Full 席位，且账号已开放 MCP beta 访问。
- 启用步骤（VS Code 示例，与[官方文档](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/)一致）：
  1. 在 VS Code 中按 `⌘⇧P`，选择 **MCP: Open User Configuration**（或 Workspace 配置）。
  2. 若提示创建 `mcp.json`，写入：
     ```json
     {
       "inputs": [],
       "servers": {
         "figma": {
           "url": "https://mcp.figma.com/mcp",
           "type": "http"
         }
       }
     }
     ```
  3. 在 MCP 面板中点击 **Start**，浏览器会进入 OAuth 流程（需要登陆并授权 Figma）。
  4. 授权后可直接在 IDE 中调用官方提供的工具集。

> **何时选择官方远程服务器？**
> - 希望即刻体验 Figma 官方输出质量（含 Code Connect、变量获取等高级能力）。
> - 不想维护本地服务端，或暂时不需要自定义工具。
> - 需要官方的 link-based Prompt：复制任何 Frame 链接，即可让客户端提取 `node-id` 并生成代码。

> **何时选择自建服务器？**
> - 需要定制生成逻辑（如直接输出 Flutter、自动写入仓库等）。
> - 希望缓存或批量导出，减少官方服务的速率限制。
> - 想与自研工具链深度集成（CLI、脚本、CI）。

## 2. 创建 manifest：`mcp.json`

1. 在 `tools/mcp/figma/` 下创建 `mcp.json`：
   ```json
   {
     "$schema": "https://modelcontextprotocol.io/schema/v1/manifest.json",
     "name": "figma-mcp",
     "version": "0.1.0",
     "description": "Expose Figma metadata & code generation endpoints",
     "env": {
       "FIGMA_PAT": {
         "required": true,
         "description": "Personal Access Token for Figma REST API"
       },
       "FIGMA_FILE_KEY": {
         "required": true,
         "description": "Default Figma file to query metadata"
       }
     },
     "commands": {
       "start": {
         "command": "node",
         "args": ["./server/index.js"],
         "description": "Launch local Figma MCP server"
       }
     },
     "capabilities": ["resources", "prompts", "tools"]
   }
   ```
2. 关键点：manifest **只声明** 启动方式与能力；真正的逻辑由服务器承担。

## 3. 实现 MCP 服务器（Node 版示例）

1. 初始化工程：
   ```bash
   cd tools/mcp/figma
   npm init -y
   npm install @modelcontextprotocol/server figma-api dotenv
   ```
2. 创建 `server/index.js`：
   ```javascript
   import 'dotenv/config';
   import { createServer } from '@modelcontextprotocol/server';
   import { Client } from 'figma-api';

   const FIGMA_PAT = process.env.FIGMA_PAT;
   const DEFAULT_FILE = process.env.FIGMA_FILE_KEY;

   if (!FIGMA_PAT) throw new Error('Missing FIGMA_PAT');

   const figma = new Client({ personalAccessToken: FIGMA_PAT });

   const server = createServer();

   server.registerTool({
     name: 'figma.get_metadata',
     description: 'Fetch Figma node metadata by node ID',
     inputSchema: {
       type: 'object',
       properties: {
         fileKey: { type: 'string' },
         nodeId: { type: 'string' }
       },
       required: ['nodeId']
     },
     async handler({ input }) {
       const fileKey = input.fileKey ?? DEFAULT_FILE;
       const { nodes } = await figma.fileNodes(fileKey, [input.nodeId]);
       return nodes[input.nodeId];
     }
   });

   server.registerTool({
     name: 'figma.export_flutter_widget',
     description: 'Generate Flutter widget snippet from auto-layout node',
     inputSchema: {
       type: 'object',
       properties: {
         nodeId: { type: 'string' },
         fileKey: { type: 'string' }
       },
       required: ['nodeId']
     },
     async handler({ input }) {
       const fileKey = input.fileKey ?? DEFAULT_FILE;
       const { nodes } = await figma.fileNodes(fileKey, [input.nodeId]);
       const node = nodes[input.nodeId];
       // TODO: 实现更完整的 DSL -> Flutter 转换
       return {
         widget: `Container(/* TODO render ${node.name} */)`
       };
     }
   });

   server.listen();
   console.log('[figma-mcp] server ready');
   ```
3. 在 `tools/mcp/figma/.env` 写入：
   ```bash
   FIGMA_PAT=xxxxxxxx
   FIGMA_FILE_KEY=yyyyyyyy
   ```
4. 可选：在 `package.json` 添加快捷启动命令：
   ```json
   {
     "scripts": {
       "dev": "node --watch ./server/index.js"
     }
   }
   ```

## 4. 将 manifest 注册到 MCP 客户端

1. 打开 VS Code，安装 **Model Context Protocol** 扩展。
2. 在设置中配置 manifest 路径，例如将 `tools/mcp/figma/mcp.json` 添加到扩展的 server 列表。
3. 启动 VS Code 的 MCP 面板，确认 `figma-mcp` 服务成功启动（会自动执行 manifest 中的 `node ./server/index.js`）。
4. 通过命令面板/聊天输入：
   - `mcp: run tool figma.get_metadata`，输入 `nodeId` 验证数据返回。
   - 观察终端日志确认请求命中。

## 5. 设计转 Flutter 代码流程（建议迭代）

1. **抽象中间模型**
   - 从 Figma API 返回的 JSON 中提取核心字段（布局、文本、颜色）。
   - 定义内部 DSL，例如 `WidgetNode { type, props, children }`。

2. **转换策略**
   - AutoLayout → `Column` / `Row`
   - Frame + Fill → `Container`
   - Text node → `Text`
   - 递归转换 children。

3. **生成器模块**（可放在 `tools/mcp/figma/server/generator/flutter.js`）：
   - 输入 DSL 节点树，输出字符串形式的 Flutter widget。
   - 加入缩进与命名规则，便于最终写入 Dart 文件。

4. **落地到 `page/test`**
   - 在 Flutter 工程中创建 `lib/presentation/page/test/figma_preview.dart`。
   - 暂先以 `FutureBuilder` 调用本地命令生成的 Dart 代码文件。
   - 在 `tools/mcp/figma` 编写一个 CLI `node scripts/export.js --node <id>`，调用 `figma.export_flutter_widget`，并把返回的 `widget` 文本写入 `lib/presentation/page/test/generated/node_<id>.dart`。
   - 在 Flutter 页面中 `import` 对应文件进行展示。

## 6. 推荐的迭代节奏

1. **第一阶段**：打通 `figma.get_metadata`，确认 manifest + server 工作正常。
2. **第二阶段**：实现基础布局节点的 DSL 映射（Frame、Text、Image）。
3. **第三阶段**：构建 CLI 与 Flutter 页面联动（自动写文件 + 热刷新）。
4. **第四阶段**：完善样式（颜色、字体、阴影）、组件命名、错误处理。
5. **第五阶段**：考虑缓存、批量导出、增量更新。

## 7. 注意事项

- manifest 变更后需要在客户端重新加载或重启服务。
- 不要把 `.env` 提交版本库；可使用 `env.example` 提示变量名称。
- Figma API 有速率限制，导出大量节点时需做节流。
- 复杂组件（如表格、图表）建议先标记 `// TODO`，避免生成错误页面。
- Flutter 端可结合 `flutter analyze`、`dart format` 保障生成代码质量。

---

按照以上步骤，即可从 manifest 到服务器再到 Flutter 页面形成闭环。后续我可以协助实现 CLI 与 Flutter 页面示例或深入生成算法，按需告知。

## 8. 新手快速上手清单

1. **立即体验官方远程版**
  - 在 VS Code 中按 `⌘⇧P → MCP: Open User Configuration`，粘贴官方示例 `mcp.json`。
  - 点击 MCP 面板的 **Start**，完成浏览器中的授权。
  - 在命令面板输入 `MCP: Run Tool` → 选择 `figma.generate_code`（或其它官方工具），粘贴 Frame 链接进行试用。

2. **准备自定义扩展环境**
  - 运行 `npm init -y` 与 `npm install @modelcontextprotocol/server figma-api dotenv`。
  - 在 `.env` 设置 `FIGMA_PAT` 与默认 `FIGMA_FILE_KEY`。

3. **验证本地服务是否可用**
  - 在 `tools/mcp/figma` 目录执行 `node ./server/index.js`，日志出现 `[figma-mcp] server ready`。
  - 打开 IDE MCP 面板，确认本地服务器显示为 Running。
  - 运行 `figma.get_metadata`，检查能否拿到节点名称或尺寸。

4. **首个 Flutter 预览演示**
  - 使用脚本导出 `Container(/* TODO render Frame */)` 片段到 `lib/presentation/page/test/generated/`。
  - 在 `figma_preview.dart` 中引入该片段，用 `FutureBuilder` 展示，验证页面加载无误。

5. **常见问题排查**
  - **认证失败**：检查 OAuth 授权（官方）或 PAT 是否过期（自建）。
  - **工具列表为空**：确认账号已开放 MCP beta，或 manifest 路径配置正确。
  - **速率限制**：官方服务有节流；自建服务需自行实现兼容逻辑。