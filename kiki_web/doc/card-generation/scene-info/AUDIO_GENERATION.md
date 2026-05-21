# 音频生成工具使用说明

## 功能说明

使用微软 Azure TTS 服务为场景词条生成中英文音频文件。

## 前置要求

### 1. 安装 Azure Speech SDK

```bash
pip install azure-cognitiveservices-speech
```

### 2. 获取 Azure Speech 服务密钥

1. 登录 [Azure Portal](https://portal.azure.com)
2. 创建或选择 "语音服务" (Speech Service)
3. 在 "密钥和终结点" 中获取：
   - **密钥 1** 或 **密钥 2**（任选其一）
   - **区域**（如 `eastasia`, `southeastasia` 等）

### 3. 设置环境变量

```bash
# 必需：设置 API 密钥
export AZURE_SPEECH_KEY='your-subscription-key-here'

# 可选：设置区域（默认为 eastasia）
export AZURE_SPEECH_REGION='eastasia'
```

## 使用方法

### 基本用法

```bash
python generate_audio.py <json_file>
```

示例：
```bash
python generate_audio.py scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json
```

### 指定输出目录

```bash
python generate_audio.py <json_file> <output_dir>
```

示例：
```bash
python generate_audio.py scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json ./audio_output
```

## 输出说明

### 文件命名规则

- 中文音频：`{id}_chinese.mp3`
- 英文音频：`{id}_english.mp3`

示例：
- `chinese_01_chinese.mp3` - "跳绳"
- `chinese_01_english.mp3` - "Jump Rope"

### 默认输出位置

如果不指定输出目录，音频文件将保存在 JSON 文件所在目录的 `audio` 子目录中。

例如：
```
scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/
├── kik_晨光乐趣_01_操场晨练.json
└── audio/
    ├── chinese_01_chinese.mp3
    ├── chinese_01_english.mp3
    ├── chinese_02_chinese.mp3
    ├── chinese_02_english.mp3
    └── ...
```

## 语音配置

### 中文语音
- **语音名称**: `zh-CN-XiaoxiaoNeural`
- **性别**: 女声
- **特点**: 自然、清晰，适合儿童学习

### 英文语音
- **语音名称**: `en-US-JennyNeural`
- **性别**: 女声
- **特点**: 自然、友好，适合儿童学习

## 快速开始示例

```bash
# 1. 安装依赖
pip install azure-cognitiveservices-speech

# 2. 设置环境变量
export AZURE_SPEECH_KEY='your-key-here'
export AZURE_SPEECH_REGION='eastasia'

# 3. 生成音频
cd kiki_web/doc/card-generation/scene-info
python generate_audio.py scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json

# 4. 查看生成的音频
ls scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/audio/
```

## 故障排查

### 错误：请设置环境变量 AZURE_SPEECH_KEY
**原因**: 未设置 Azure Speech API 密钥  
**解决**: 运行 `export AZURE_SPEECH_KEY='your-key'`

### 错误：请先安装 Azure Speech SDK
**原因**: 未安装依赖包  
**解决**: 运行 `pip install azure-cognitiveservices-speech`

### 错误：Authentication failed
**原因**: API 密钥无效或区域不匹配  
**解决**: 
1. 检查密钥是否正确
2. 确认区域设置与 Azure 资源的区域一致

### 错误：Rate limit exceeded
**原因**: 超过 API 调用频率限制  
**解决**: 
1. 等待一段时间后重试
2. 考虑升级 Azure 订阅计划

## 成本说明

Azure Speech TTS 服务按字符数计费：
- 免费层：每月 500 万字符
- 标准层：按使用量计费

本工具生成的音频通常每个词条 2-10 个字符，成本很低。

## 自定义语音

如需更改语音，编辑 `generate_audio.py` 中的语音配置：

```python
# 中文语音选项
self.chinese_voice = "zh-CN-XiaoxiaoNeural"  # 女声
# self.chinese_voice = "zh-CN-YunxiNeural"   # 男声
# self.chinese_voice = "zh-CN-YunyangNeural" # 男声（新闻播报风格）

# 英文语音选项
self.english_voice = "en-US-JennyNeural"     # 女声
# self.english_voice = "en-US-GuyNeural"     # 男声
# self.english_voice = "en-US-AriaNeural"    # 女声（自然）
```

更多语音选项请参考：[Azure TTS 语音列表](https://learn.microsoft.com/azure/cognitive-services/speech-service/language-support?tabs=tts)
