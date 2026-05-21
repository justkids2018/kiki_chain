# Azure Speech 服务快速设置指南

## 免费额度说明

✅ **完全免费开始使用**
- 每月 500 万字符免费
- 不需要信用卡
- 你的场景（8 个词条 × 2 语言 ≈ 100 字符）完全够用

## 注册步骤（5 分钟完成）

### 1. 访问 Azure Portal

打开浏览器访问：https://portal.azure.com

### 2. 登录/注册 Microsoft 账号

- 如果有 Microsoft 账号（Outlook、Hotmail、Xbox 等），直接登录
- 如果没有，点击 "创建账户" 注册一个

### 3. 创建 Speech 服务资源

#### 方法 A：快速创建（推荐）

1. 在 Azure Portal 顶部搜索框输入 **"Speech"** 或 **"语音"**
2. 选择 **"语音服务"** (Speech Services)
3. 点击 **"+ 创建"** 按钮

#### 方法 B：直接链接

访问：https://portal.azure.com/#create/Microsoft.CognitiveServicesSpeechServices

### 4. 填写创建表单

| 字段 | 填写内容 |
|------|---------|
| **订阅** | 选择你的订阅（通常是 "免费试用" 或默认订阅） |
| **资源组** | 点击 "新建"，输入名称如 `kiki-tts-rg` |
| **区域** | 选择 **"East Asia"**（东亚-香港）或 **"Southeast Asia"**（东南亚-新加坡） |
| **名称** | 输入唯一名称，如 `kiki-speech-service` |
| **定价层** | 选择 **"免费 F0"** ⭐ |

> ⚠️ **重要**：一定要选择 **"免费 F0"** 定价层！

### 5. 创建并等待部署

1. 点击 **"查看 + 创建"**
2. 检查配置无误后，点击 **"创建"**
3. 等待 1-2 分钟部署完成

### 6. 获取密钥和区域

部署完成后：

1. 点击 **"转到资源"**
2. 在左侧菜单找到 **"密钥和终结点"** (Keys and Endpoint)
3. 你会看到：
   - **密钥 1** (KEY 1)
   - **密钥 2** (KEY 2)
   - **位置/区域** (Location/Region)

> 💡 **提示**：密钥 1 和密钥 2 任选其一即可

### 7. 复制密钥信息

记录以下信息：

```
密钥: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
区域: eastasia  (或 southeastasia)
```

## 配置环境变量

### macOS / Linux

在终端执行：

```bash
# 设置密钥（替换为你的实际密钥）
export AZURE_SPEECH_KEY='你的密钥'

# 设置区域（根据你选择的区域）
export AZURE_SPEECH_REGION='eastasia'

# 验证设置
echo $AZURE_SPEECH_KEY
echo $AZURE_SPEECH_REGION
```

### 永久保存（可选）

将上述命令添加到 `~/.zshrc` 或 `~/.bashrc`：

```bash
echo "export AZURE_SPEECH_KEY='你的密钥'" >> ~/.zshrc
echo "export AZURE_SPEECH_REGION='eastasia'" >> ~/.zshrc
source ~/.zshrc
```

### Windows (PowerShell)

```powershell
$env:AZURE_SPEECH_KEY='你的密钥'
$env:AZURE_SPEECH_REGION='eastasia'
```

## 测试配置

运行以下命令测试：

```bash
cd kiki_web/doc/card-generation/scene-info

# 安装依赖
pip install azure-cognitiveservices-speech

# 生成音频
python generate_audio.py scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json
```

如果看到类似输出，说明配置成功：

```
开始处理: scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json
输出目录: scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/audio
词条数量: 8

[1] 跳绳 (tiào shéng) - Jump Rope
✓ 生成成功: .../chinese_01_chinese.mp3
✓ 生成成功: .../chinese_01_english.mp3
...
```

## 常见问题

### Q: 需要信用卡吗？
A: 免费层不需要信用卡。

### Q: 免费额度用完了怎么办？
A: 500 万字符/月对你的使用场景来说几乎用不完。即使用完，服务会停止，不会自动扣费。

### Q: 区域选哪个？
A: 推荐 `eastasia`（香港）或 `southeastasia`（新加坡），延迟低。

### Q: 密钥泄露了怎么办？
A: 在 Azure Portal 中可以重新生成密钥。

### Q: 提示 "Authentication failed"
A: 检查：
1. 密钥是否正确复制（没有多余空格）
2. 区域设置是否与 Azure 资源的区域一致

## 下一步

配置完成后，参考 [AUDIO_GENERATION.md](./AUDIO_GENERATION.md) 开始生成音频。

## 有用的链接

- [Azure Portal](https://portal.azure.com)
- [Azure Speech 文档](https://learn.microsoft.com/azure/cognitive-services/speech-service/)
- [支持的语音列表](https://learn.microsoft.com/azure/cognitive-services/speech-service/language-support?tabs=tts)
- [定价详情](https://azure.microsoft.com/pricing/details/cognitive-services/speech-services/)
