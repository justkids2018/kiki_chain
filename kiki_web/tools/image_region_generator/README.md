# 图片文字区域生成工具

一个简洁的 macOS 本地工具，用于识别图片中的文字并生成规范的 JSON 坐标数据。

## ⚡ 3 分钟快速开始

### 首次使用（需要 3 分钟）

```bash
cd tools/image_region_generator

# 1️⃣ 设置虚拟环境（首次）
chmod +x setup_venv.sh
./setup_venv.sh

# 2️⃣ 安装 Tesseract OCR（需要 Homebrew）
brew install tesseract

# 3️⃣ 启动应用
chmod +x run_gui.sh
./run_gui.sh
```

### 后续使用（只需 3 秒）

```bash
cd tools/image_region_generator
./run_gui.sh
```

## 🎯 使用步骤

1. **加载图片** → 点击"加载图片"选择要处理的图片
2. **识别文本** → 点击"识别文本"自动识别所有文字
3. **预览效果** → 点击"预览区域"查看识别框位置
4. **导出 JSON** → 点击"导出 JSON"保存识别结果

## 📊 输出格式

生成的 JSON 包含每个文字区域的：
- `text`: 识别的文字
- `coordinate`: 四个角的坐标 `[x, y]`
- `type`: 文字类型（中文/英文）
- `index`: 编号

示例：
```json
[
  {
    "type": "chinese",
    "id": "text_01",
    "index": 1,
    "text": "文字",
    "text_pinyin": "",
    "text_english": "",
    "coordinate": [
      {"x": 100, "y": 200},
      {"x": 300, "y": 200},
      {"x": 300, "y": 250},
      {"x": 100, "y": 250}
    ]
  }
]
```

## 🔧 系统要求

- macOS 10.15+
- Python 3.8+
- Homebrew（用于安装 Tesseract）

## 🏗️ 架构设计

应用自动选择最优的 OCR 引擎：

- **Tesseract**：默认引擎，兼容所有 macOS 版本
- **PaddleOCR**：可选引擎，如果系统支持会自动使用（精准度更高）

## 📁 文件说明

```
image_region_generator/
├── run_gui.sh              ← 启动脚本
├── setup_venv.sh          ← 虚拟环境设置
├── gui_app_new.py         ← GUI 应用程序
├── ocr_engine.py          ← OCR 引擎抽象层
├── requirements.txt       ← Python 依赖
├── ARCHITECTURE.md        ← 架构详细说明
├── QUICKSTART_30SEC.md    ← 30秒快速开始
└── MANUAL_RUN.md          ← 手动运行指南
```

## ❓ 常见问题

**Q: Tesseract 如何安装？**
```bash
brew install tesseract
```

**Q: 识别不准确怎么办？**
- 使用更清晰的图片
- 调整图片角度和对比度
- 或等待 macOS 升级后自动使用 PaddleOCR

**Q: 可以批量处理吗？**
- 当前版本逐个处理，但可轻松扩展支持批量模式

**Q: 导出的 JSON 中为什么 pinyin 和 english 是空的？**
- 需要手动补充，或使用专门的库来生成

## 🚀 下一步

- 📖 查看 [ARCHITECTURE.md](ARCHITECTURE.md) 了解设计原理
- 📖 查看 [QUICKSTART_30SEC.md](QUICKSTART_30SEC.md) 获得更多细节
- 📖 查看 [MANUAL_RUN.md](MANUAL_RUN.md) 了解故障排查

---

**简洁、高效、易扩展** ✨
