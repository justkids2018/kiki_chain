# Figma MCP 配置验证

## 环境要求
- GitHub Copilot 扩展已安装并激活
- VS Code 版本 ≥ 1.80
- 网络连接正常

## 配置验证步骤

### 1. 检查 Copilot 状态
```bash
# 在 VS Code 终端中运行
echo "Copilot 状态检查："
code --list-extensions | grep copilot
```

### 2. 验证 MCP 服务
```bash
# 检查 MCP 服务端口
echo "检查 MCP 服务端口："
lsof -i :3845 || echo "端口 3845 未被占用"

# 测试 MCP 连接
echo "测试 MCP 连接："
curl -s http://127.0.0.1:3845/mcp || echo "MCP 服务未响应"
```

### 3. Figma 文件信息
```bash
# 当前配置的 Figma 信息
echo "Figma 配置："
echo "File Key: aJ59iGjgPbww580nuopwfG"
echo "Node ID: 22680-8117"
echo "URL: https://www.figma.com/proto/aJ59iGjgPbww580nuopwfG/EDA-UI?node-id=22680-8117"
```

## 常用命令

### 启动 MCP 服务
1. 打开 VS Code
2. `Cmd+Shift+P` → "Developer: Reload Window"
3. 确认右下角 Copilot 图标为绿色

### 测试 MCP 工具
在支持 MCP 的环境中运行：
```javascript
// 获取 Figma 代码
const result = await mcp_figma_get_code({
  fileKey: "aJ59iGjgPbww580nuopwfG",
  nodeId: "22680-8117",
  clientFrameworks: "flutter",
  clientLanguages: "dart"
});
console.log(result);
```

## 故障排除

### MCP 服务未启动
1. 重启 VS Code
2. 检查 Copilot 订阅状态
3. 更新 Copilot 扩展到最新版本

### 权限问题
1. 确认登录正确的 GitHub 账号
2. 检查 Figma 文件访问权限
3. 验证网络连接

### 端口冲突
```bash
# 查找并停止占用端口的进程
sudo lsof -ti:3845 | xargs kill -9
```

## 成功标志
- VS Code 右下角 Copilot 图标为绿色
- `curl http://127.0.0.1:3845/mcp` 有响应
- MCP 工具调用返回预期结果