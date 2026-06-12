# Kiki 音频生成与管理系统

## 系统概述

为 Kiki 场景词条自动生成中英文音频，上传到七牛云 CDN，通过索引文件统一管理。

**核心特性**：
- 🎵 使用 Edge TTS 生成高质量音频（完全免费）
- ☁️ 自动上传到七牛云 CDN（全球加速访问）
- 📇 智能索引管理（通过汉字/英文快速查找链接）
- 🔄 增量生成（已存在的自动跳过）
- 📦 批量处理（一键处理整个场景）

---

## 快速开始

### 1. 安装依赖

```bash
pip install edge-tts qiniu
```

### 2. 配置七牛

创建配置文件 `audio_config.json`：

```json
{
  "qiniu": {
    "access_key": "your_qiniu_access_key",
    "secret_key": "your_qiniu_secret_key",
    "bucket": "kiki-assets",
    "domain": "https://cdn.yourdomain.com",
    "prefix": "kiki/audio"
  }
}
```

### 3. 生成音频

```bash
# 处理单个场景
python audio_manager.py process scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json

# 批量处理整个场景目录
python audio_manager.py batch scene_01_晨光乐趣/
```

### 4. 查询音频链接

```bash
# 通过汉字查询
python audio_manager.py query "跳绳"
# 输出：https://cdn.yourdomain.com/kiki/audio/跳绳_zh.mp3

# 通过英文查询
python audio_manager.py query "Jump Rope"
# 输出：https://cdn.yourdomain.com/kiki/audio/jump_rope_en.mp3
```

---

## 系统架构

### 目录结构

```
scene-info/
├── audio_index.json              # 全局音频索引（核心）
├── audio_config.json             # 配置文件（七牛、音色）
├── audio_manager.py              # 统一管理脚本（推荐）
├── generate_audio_edge.py        # Edge TTS 生成器
├── upload_to_qiniu.py            # 七牛上传工具
├── query_audio.py                # 音频查询工具
│
└── scene_01_晨光乐趣/
    └── kik_晨光乐趣_01_操场晨练/
        ├── kik_晨光乐趣_01_操场晨练.json    # 场景数据
        └── audio/                            # 本地音频缓存
            ├── 跳绳_zh.mp3
            ├── jump_rope_en.mp3
            └── ...
```

### 核心文件说明

| 文件 | 作用 | 必需 |
|------|------|------|
| `audio_index.json` | 全局音频索引，记录所有音频的七牛链接 | ✅ |
| `audio_config.json` | 七牛配置、音色配置 | ✅ |
| `audio_manager.py` | 统一管理脚本，一键完成所有操作 | ✅ |
| `generate_audio_edge.py` | Edge TTS 生成器 | ✅ |
| `upload_to_qiniu.py` | 七牛上传工具 | ✅ |
| `query_audio.py` | 查询工具 | 可选 |

---

## 文件命名规范

### 中文音频
- **格式**：`{汉字}_zh.mp3`
- **示例**：
  - `跳绳_zh.mp3`
  - `皮球_zh.mp3`
  - `呼啦圈_zh.mp3`

### 英文音频
- **格式**：`{英文小写_下划线}_en.mp3`
- **转换规则**：
  - 全部转小写
  - 空格替换为下划线
  - 移除特殊字符
- **示例**：
  - `Jump Rope` → `jump_rope_en.mp3`
  - `Ball` → `ball_en.mp3`
  - `Hula Hoop` → `hula_hoop_en.mp3`

### 命名优势
✅ 直接通过文本就能找到文件  
✅ 无需记忆 ID 或特殊编码  
✅ 文件名即文档，一目了然  
✅ 支持中文文件名（七牛云支持）  

---

## 索引文件格式

### audio_index.json 结构

```json
{
  "version": "1.0",
  "updated_at": "2026-05-21T10:30:00Z",
  "base_url": "https://cdn.yourdomain.com/kiki/audio",
  "total_items": 8,
  "items": {
    "跳绳": {
      "chinese": {
        "text": "跳绳",
        "pinyin": "tiào shéng",
        "filename": "跳绳_zh.mp3",
        "url": "https://cdn.yourdomain.com/kiki/audio/跳绳_zh.mp3",
        "voice": "zh-CN-XiaoxiaoNeural",
        "size": 12345,
        "duration": 1.2,
        "created_at": "2026-05-21T10:15:00Z"
      },
      "english": {
        "text": "Jump Rope",
        "phonetic": "/dʒʌmp roʊp/",
        "filename": "jump_rope_en.mp3",
        "url": "https://cdn.yourdomain.com/kiki/audio/jump_rope_en.mp3",
        "voice": "en-US-JennyNeural",
        "size": 15678,
        "duration": 1.5,
        "created_at": "2026-05-21T10:15:00Z"
      }
    },
    "皮球": {
      "chinese": { "..." },
      "english": { "..." }
    }
  }
}
```

### 索引文件用途

1. **快速查询**：通过汉字或英文直接查找七牛链接
2. **增量生成**：检查是否已存在，避免重复生成
3. **元数据管理**：记录拼音、音标、文件大小、时长等
4. **版本控制**：追踪音频生成时间和版本

---

## 配置文件格式

### audio_config.json 结构

```json
{
  "qiniu": {
    "access_key": "your_qiniu_access_key",
    "secret_key": "your_qiniu_secret_key",
    "bucket": "kiki-assets",
    "domain": "https://cdn.yourdomain.com",
    "prefix": "kiki/audio"
  },
  "voices": {
    "chinese": {
      "default": "zh-CN-XiaoxiaoNeural",
      "description": "女声，自然，适合儿童",
      "alternatives": [
        {
          "name": "zh-CN-XiaoyiNeural",
          "description": "女声，活泼"
        },
        {
          "name": "zh-CN-YunjianNeural",
          "description": "男声，温和"
        }
      ]
    },
    "english": {
      "default": "en-US-JennyNeural",
      "description": "女声，友好，适合儿童",
      "alternatives": [
        {
          "name": "en-US-AriaNeural",
          "description": "女声，自然"
        },
        {
          "name": "en-US-GuyNeural",
          "description": "男声，清晰"
        }
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

### 配置说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `qiniu.access_key` | 七牛 Access Key | 必填 |
| `qiniu.secret_key` | 七牛 Secret Key | 必填 |
| `qiniu.bucket` | 七牛存储空间名称 | `kiki-assets` |
| `qiniu.domain` | 七牛 CDN 域名 | 必填 |
| `qiniu.prefix` | 文件前缀路径 | `kiki/audio` |
| `voices.chinese.default` | 默认中文音色 | `zh-CN-XiaoxiaoNeural` |
| `voices.english.default` | 默认英文音色 | `en-US-JennyNeural` |
| `audio.format` | 音频格式 | `mp3` |
| `audio.rate` | 采样率 | `24000` |

---

## 使用指南

### 方式 1：统一管理脚本（推荐）

`audio_manager.py` 是一站式解决方案，推荐使用。

#### 处理单个场景

```bash
python audio_manager.py process scene_01_晨光乐趣/kik_晨光乐趣_01_操场晨练/kik_晨光乐趣_01_操场晨练.json
```

**执行流程**：
1. 读取 JSON 文件
2. 检查索引，确定需要生成的音频
3. 使用 Edge TTS 生成音频
4. 上传到七牛云
5. 更新索引文件
6. 输出生成报告

#### 批量处理场景目录

```bash
python audio_manager.py batch scene_01_晨光乐趣/
```

自动处理目录下所有 JSON 文件。

#### 增量生成

```bash
python audio_manager.py process scene.json --incremental
```

只生成索引中不存在的音频，跳过已存在的。

#### 强制重新生成

```bash
python audio_manager.py process scene.json --force
```

忽略索引，重新生成所有音频并覆盖。

#### 查询音频链接

```bash
# 通过汉字查询
python audio_manager.py query "跳绳"

# 通过英文查询
python audio_manager.py query "Jump Rope"

# 查询多个
python audio_manager.py query "跳绳" "皮球" "呼啦圈"
```

#### 查看统计信息

```bash
python audio_manager.py stats
```

输出：
- 总词条数
- 已生成音频数
- 缺失音频数
- 存储空间占用

### 方式 2：分步执行

如果需要更细粒度的控制，可以分步执行。

#### 步骤 1：生成音频

```bash
python generate_audio_edge.py scene.json
```

生成音频到本地 `audio/` 目录。

#### 步骤 2：上传到七牛

```bash
python upload_to_qiniu.py audio/
```

上传本地音频到七牛云。

#### 步骤 3：更新索引

```bash
python audio_manager.py update-index
```

扫描七牛云，更新索引文件。

---

## 工作流程

### 场景 1：首次生成音频

```bash
# 1. 配置七牛（首次）
vim audio_config.json  # 填入七牛 AK/SK

# 2. 处理场景
python audio_manager.py process scene.json

# 3. 验证
python audio_manager.py query "跳绳"
```

### 场景 2：添加新词条

```bash
# 1. 编辑 JSON，添加新词条
vim scene.json

# 2. 增量生成（只生成新的）
python audio_manager.py process scene.json --incremental

# 3. 验证新词条
python audio_manager.py query "新词条"
```

### 场景 3：批量处理多个场景

```bash
# 处理整个场景目录
python audio_manager.py batch scene_01_晨光乐趣/

# 或使用通配符
python audio_manager.py batch scene_*/
```

### 场景 4：更换音色

```bash
# 1. 修改配置文件
vim audio_config.json  # 更改 voices.chinese.default

# 2. 强制重新生成
python audio_manager.py process scene.json --force --voice zh-CN-YunjianNeural
```

### 场景 5：在应用中使用

```javascript
// 前端代码示例
async function playAudio(text, language = 'zh') {
  const response = await fetch('/api/audio/query', {
    method: 'POST',
    body: JSON.stringify({ text, language })
  });
  
  const { url } = await response.json();
  const audio = new Audio(url);
  audio.play();
}

// 使用
playAudio('跳绳', 'zh');  // 播放中文
playAudio('Jump Rope', 'en');  // 播放英文
```

---

## Edge TTS 音色列表

### 中文音色（推荐）

| 音色名称 | 性别 | 特点 | 适用场景 |
|---------|------|------|---------|
| `zh-CN-XiaoxiaoNeural` | 女 | 自然、清晰、温柔 | **儿童学习（推荐）** |
| `zh-CN-XiaoyiNeural` | 女 | 活泼、可爱 | 儿童故事 |
| `zh-CN-YunjianNeural` | 男 | 温和、稳重 | 正式场合 |
| `zh-CN-YunxiNeural` | 男 | 年轻、清晰 | 新闻播报 |
| `zh-CN-YunyangNeural` | 男 | 专业、权威 | 教学讲解 |

### 英文音色（推荐）

| 音色名称 | 性别 | 特点 | 适用场景 |
|---------|------|------|---------|
| `en-US-JennyNeural` | 女 | 友好、自然 | **儿童学习（推荐）** |
| `en-US-AriaNeural` | 女 | 清晰、专业 | 正式场合 |
| `en-US-GuyNeural` | 男 | 温和、清晰 | 教学讲解 |
| `en-US-JasonNeural` | 男 | 年轻、活力 | 互动场景 |

### 查看所有可用音色

```bash
edge-tts --list-voices | grep zh-CN
edge-tts --list-voices | grep en-US
```

---

## Skill 集成

### 创建 Skill：/audio-gen

将音频生成功能封装为 Skill，方便在工作流中使用。

#### Skill 定义

```markdown
# just-audio-generator

为 Kiki 场景词条生成中英文音频并上传到七牛云。

## 触发条件
- 用户说"生成音频"、"audio"、"音频生成"
- 用户提供场景 JSON 文件路径

## 功能
1. 读取场景 JSON 文件
2. 使用 Edge TTS 生成中英文音频
3. 上传到七牛云 CDN
4. 更新音频索引
5. 输出生成报告

## 使用方式
/audio-gen <json_file> [options]

## 选项
--batch: 批量处理目录
--force: 强制重新生成
--incremental: 增量生成
--voice: 指定音色
```

#### 使用示例

```bash
# 处理单个场景
/audio-gen scene.json

# 批量处理
/audio-gen scene_01_晨光乐趣/ --batch

# 增量生成
/audio-gen scene.json --incremental

# 指定音色
/audio-gen scene.json --voice zh-CN-YunjianNeural
```

---

## API 接口设计

### 查询音频链接

**接口**：`GET /api/audio/query`

**参数**：
```json
{
  "text": "跳绳",
  "language": "zh"  // zh 或 en
}
```

**响应**：
```json
{
  "success": true,
  "data": {
    "text": "跳绳",
    "url": "https://cdn.yourdomain.com/kiki/audio/跳绳_zh.mp3",
    "filename": "跳绳_zh.mp3",
    "duration": 1.2,
    "size": 12345
  }
}
```

### 批量查询

**接口**：`POST /api/audio/batch-query`

**参数**：
```json
{
  "items": [
    { "text": "跳绳", "language": "zh" },
    { "text": "Jump Rope", "language": "en" }
  ]
}
```

**响应**：
```json
{
  "success": true,
  "data": [
    {
      "text": "跳绳",
      "url": "https://cdn.yourdomain.com/kiki/audio/跳绳_zh.mp3"
    },
    {
      "text": "Jump Rope",
      "url": "https://cdn.yourdomain.com/kiki/audio/jump_rope_en.mp3"
    }
  ]
}
```

---

## 七牛云配置

### 获取 Access Key 和 Secret Key

1. 登录 [七牛云控制台](https://portal.qiniu.com)
2. 进入 **个人中心** → **密钥管理**
3. 复制 **AccessKey** 和 **SecretKey**

### 创建存储空间

1. 进入 **对象存储** → **空间管理**
2. 点击 **新建空间**
3. 填写：
   - 空间名称：`kiki-assets`
   - 存储区域：选择离你最近的区域
   - 访问控制：**公开**
4. 创建完成后，获取 **CDN 域名**

### 配置 CDN 加速

1. 进入空间 → **域名管理**
2. 绑定自定义域名（可选）
3. 开启 HTTPS（推荐）

### 成本说明

七牛云免费额度：
- 存储空间：10 GB
- 下载流量：10 GB/月
- PUT/DELETE 请求：10 万次/月
- GET 请求：100 万次/月

对于 Kiki 项目（预计几百个音频文件，每个 10-50 KB），完全在免费额度内。

---

## 故障排查

### 问题 1：Edge TTS 生成失败

**错误信息**：
```
edge_tts.exceptions.NoAudioReceived
```

**原因**：网络问题或音色名称错误

**解决**：
1. 检查网络连接
2. 验证音色名称：`edge-tts --list-voices`
3. 重试或更换音色

### 问题 2：七牛上传失败

**错误信息**：
```
qiniu.exceptions.InvalidToken
```

**原因**：Access Key 或 Secret Key 错误

**解决**：
1. 检查 `audio_config.json` 中的密钥
2. 确认密钥没有多余空格
3. 在七牛控制台重新生成密钥

### 问题 3：索引文件损坏

**错误信息**：
```
json.decoder.JSONDecodeError
```

**原因**：索引文件格式错误

**解决**：
```bash
# 备份旧索引
cp audio_index.json audio_index.json.bak

# 重建索引
python audio_manager.py rebuild-index
```

### 问题 4：音频无法播放

**原因**：七牛域名配置错误或文件未上传

**解决**：
1. 检查七牛 CDN 域名是否正确
2. 在七牛控制台验证文件是否存在
3. 检查文件访问权限（应为公开）

### 问题 5：中文文件名乱码

**原因**：系统编码问题

**解决**：
```bash
# 设置环境变量
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 重新运行脚本
python audio_manager.py process scene.json
```

---

## 最佳实践

### 1. 版本控制

将 `audio_index.json` 纳入 Git 版本控制：

```bash
git add audio_index.json
git commit -m "chore: update audio index"
```

### 2. 备份策略

定期备份索引文件：

```bash
# 自动备份脚本
cp audio_index.json audio_index.$(date +%Y%m%d).json
```

### 3. 增量生成

始终使用 `--incremental` 模式，避免重复生成：

```bash
python audio_manager.py process scene.json --incremental
```

### 4. 批量处理

处理多个场景时，使用批量模式提高效率：

```bash
python audio_manager.py batch scene_*/
```

### 5. 监控与日志

记录生成日志，便于追踪问题：

```bash
python audio_manager.py process scene.json 2>&1 | tee audio_gen.log
```

### 6. CDN 缓存

配置七牛 CDN 缓存策略：
- 音频文件：缓存 1 年（不会变更）
- 索引文件：缓存 1 小时（可能更新）

---

## 性能优化

### 并发生成

使用多线程加速生成：

```bash
python audio_manager.py process scene.json --workers 4
```

### 本地缓存

保留本地音频缓存，避免重复下载：

```bash
# 不删除本地文件
python audio_manager.py process scene.json --keep-local
```

### 压缩优化

使用更高的压缩率减小文件大小：

```json
{
  "audio": {
    "format": "mp3",
    "rate": "16000",  // 降低采样率
    "bitrate": "64k"  // 降低比特率
  }
}
```

---

## 扩展功能

### 1. 多语言支持

扩展支持更多语言：

```json
{
  "voices": {
    "japanese": {
      "default": "ja-JP-NanamiNeural"
    },
    "korean": {
      "default": "ko-KR-SunHiNeural"
    }
  }
}
```

### 2. 音频后处理

添加音效、调整音量等：

```bash
# 使用 ffmpeg 后处理
ffmpeg -i input.mp3 -af "volume=1.5" output.mp3
```

### 3. 自动化 CI/CD

在 GitHub Actions 中自动生成音频：

```yaml
name: Generate Audio
on:
  push:
    paths:
      - 'scene-info/**/*.json'
jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Generate Audio
        run: |
          pip install edge-tts qiniu
          python audio_manager.py batch scene-info/
```

---

## 总结

### 系统优势

✅ **完全免费**：Edge TTS 无需 API 密钥  
✅ **高质量音频**：Neural 音色，接近真人  
✅ **智能命名**：直接用汉字和英文，无需记忆 ID  
✅ **增量生成**：自动跳过已存在的音频  
✅ **全球加速**：七牛 CDN，访问速度快  
✅ **易于维护**：统一索引管理，清晰可追溯  

### 推荐工作流

```bash
# 1. 首次配置（一次性）
vim audio_config.json

# 2. 日常使用（增量生成）
python audio_manager.py process scene.json --incremental

# 3. 查询使用
python audio_manager.py query "跳绳"
```

### 下一步

- [ ] 实现 `audio_manager.py` 核心脚本
- [ ] 实现 `generate_audio_edge.py` 生成器
- [ ] 实现 `upload_to_qiniu.py` 上传工具
- [ ] 封装为 Skill：`/audio-gen`
- [ ] 集成到 Kiki 应用中

---

## 相关文档

- [Edge TTS 官方文档](https://github.com/rany2/edge-tts)
- [七牛云对象存储文档](https://developer.qiniu.com/kodo)
- [音频生成方案设计](./AUDIO_SOLUTION_DESIGN.md)
- [Azure TTS 设置指南](./AZURE_SETUP_GUIDE.md)（备选方案）

---

**最后更新**：2026-05-21  
**维护者**：Kiki Team
