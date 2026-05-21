# 音频生成与管理方案设计

## 方案概述

使用 Edge TTS 生成音频，上传到七牛云，通过索引文件管理所有音频链接。

## 核心特性

✅ **智能命名**：直接用汉字和英文命名，无需 ID  
✅ **增量生成**：已存在的音频自动跳过  
✅ **云端存储**：上传七牛，全局可访问  
✅ **快速查找**：通过索引文件秒查链接  
✅ **批量处理**：一键处理整个场景  
✅ **完全免费**：Edge TTS 无需 API 密钥  

## 目录结构

```
scene-info/
├── audio_index.json                    # 全局音频索引（核心）
├── audio_config.json                   # 配置文件（七牛、音色等）
├── generate_audio_edge.py              # Edge TTS 生成脚本
├── upload_to_qiniu.py                  # 七牛上传工具
├── audio_manager.py                    # 统一管理脚本（推荐使用）
│
└── scene_01_晨光乐趣/
    └── kik_晨光乐趣_01_操场晨练/
        ├── kik_晨光乐趣_01_操场晨练.json
        └── audio/                      # 本地音频缓存
            ├── 跳绳_zh.mp3
            ├── jump_rope_en.mp3
            └── ...
```

## 文件命名规范

### 中文音频
- 格式：`{汉字}_zh.mp3`
- 示例：`跳绳_zh.mp3`, `皮球_zh.mp3`

### 英文音频
- 格式：`{英文小写_下划线}_en.mp3`
- 示例：`jump_rope_en.mp3`, `ball_en.mp3`

### 命名转换规则
```python
# 英文转文件名
"Jump Rope" → "jump_rope"
"Ball" → "ball"
"Hula Hoop" → "hula_hoop"
```

## 索引文件格式

### audio_index.json

```json
{
  "version": "1.0",
  "updated_at": "2026-05-20T10:30:00Z",
  "base_url": "https://cdn.qiniu.com/kiki/audio",
  "items": {
    "跳绳": {
      "chinese": {
        "text": "跳绳",
        "pinyin": "tiào shéng",
        "filename": "跳绳_zh.mp3",
        "url": "https://cdn.qiniu.com/kiki/audio/跳绳_zh.mp3",
        "voice": "zh-CN-XiaoxiaoNeural",
        "size": 12345,
        "duration": 1.2
      },
      "english": {
        "text": "Jump Rope",
        "phonetic": "/dʒʌmp roʊp/",
        "filename": "jump_rope_en.mp3",
        "url": "https://cdn.qiniu.com/kiki/audio/jump_rope_en.mp3",
        "voice": "en-US-JennyNeural",
        "size": 15678,
        "duration": 1.5
      }
    }
  }
}
```

## 配置文件格式

### audio_config.json

```json
{
  "qiniu": {
    "access_key": "your_access_key",
    "secret_key": "your_secret_key",
    "bucket": "kiki-assets",
    "domain": "https://cdn.qiniu.com",
    "prefix": "kiki/audio"
  },
  "voices": {
    "chinese": {
      "default": "zh-CN-XiaoxiaoNeural",
      "alternatives": [
        "zh-CN-XiaoyiNeural",
        "zh-CN-YunjianNeural"
      ]
    },
    "english": {
      "default": "en-US-JennyNeural",
      "alternatives": [
        "en-US-AriaNeural",
        "en-US-GuyNeural"
      ]
    }
  },
  "audio": {
    "format": "mp3",
    "rate": "24000",
    "volume": "+0%",
    "pitch": "+0Hz"
  }
}
```

## 工作流程

### 方案 A：统一管理脚本（推荐）

```bash
# 一键完成：生成 → 上传 → 更新索引
python audio_manager.py process scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json

# 批量处理整个场景目录
python audio_manager.py batch scene_01_晨光乐趣/

# 只查询，不生成
python audio_manager.py query "跳绳"
```

### 方案 B：分步执行

```bash
# 1. 生成音频（本地）
python generate_audio_edge.py input.json

# 2. 上传到七牛
python upload_to_qiniu.py audio/

# 3. 更新索引
python audio_manager.py update-index
```

## 使用场景

### 场景 1：首次生成
```bash
python audio_manager.py process scene.json
```
- 生成所有音频
- 上传到七牛
- 更新索引

### 场景 2：增量更新
```bash
# 添加新词条后
python audio_manager.py process scene.json --incremental
```
- 检查索引，跳过已存在的
- 只生成新词条
- 上传并更新索引

### 场景 3：查询链接
```bash
# 通过汉字查询
python audio_manager.py query "跳绳"
# 输出：https://cdn.qiniu.com/kiki/audio/跳绳_zh.mp3

# 通过英文查询
python audio_manager.py query "Jump Rope"
# 输出：https://cdn.qiniu.com/kiki/audio/jump_rope_en.mp3
```

### 场景 4：批量处理
```bash
# 处理整个场景目录
python audio_manager.py batch scene_01_晨光乐趣/
```

## Skill 设计

### Skill 名称
`/just-audio-generator` 或 `/audio-gen`

### Skill 功能
1. 读取场景 JSON
2. 检查索引，确定需要生成的音频
3. 使用 Edge TTS 生成音频
4. 上传到七牛云
5. 更新索引文件
6. 输出生成报告

### Skill 参数
```bash
# 处理单个文件
/audio-gen scene.json

# 批量处理目录
/audio-gen scene_01_晨光乐趣/ --batch

# 强制重新生成
/audio-gen scene.json --force

# 只生成不上传
/audio-gen scene.json --local-only
```

## 优势分析

### vs Azure TTS
| 特性 | Edge TTS | Azure TTS |
|------|----------|-----------|
| 成本 | 完全免费 | 免费额度 500 万字符/月 |
| 音质 | 优秀（Neural） | 优秀（Neural） |
| API 密钥 | 不需要 | 需要 |
| 速度 | 快 | 快 |
| 稳定性 | 高 | 高 |

### vs 本地存储
| 特性 | 七牛云 | 本地存储 |
|------|--------|----------|
| 访问速度 | CDN 加速 | 依赖本地 |
| 全局可用 | ✅ | ❌ |
| 备份安全 | ✅ | 需手动 |
| 成本 | 低（10GB 免费） | 无 |

## 实现优先级

### Phase 1：基础功能（必需）
- [x] Edge TTS 生成脚本
- [ ] 智能文件命名
- [ ] 七牛上传工具
- [ ] 索引文件管理

### Phase 2：增强功能
- [ ] 增量生成（检查索引）
- [ ] 批量处理
- [ ] 查询工具

### Phase 3：Skill 封装
- [ ] 创建 skill 定义
- [ ] 集成到工作流
- [ ] 添加错误处理和重试

## 推荐方案

**最佳实践**：使用统一管理脚本 `audio_manager.py`

```bash
# 1. 配置七牛（首次）
python audio_manager.py config

# 2. 处理场景（自动：生成→上传→索引）
python audio_manager.py process scene.json

# 3. 查询使用
python audio_manager.py query "跳绳"
```

## 下一步

你觉得这个方案如何？我可以立即开始实现：

1. **先实现核心功能**：Edge TTS 生成 + 七牛上传 + 索引管理
2. **再封装 Skill**：方便批量使用
3. **最后优化**：增量生成、错误处理等

需要我现在开始实现吗？
