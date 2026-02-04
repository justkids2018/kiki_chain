# 新架构说明（推荐）

## 🏗️ 架构设计

### 三层架构

```
┌────────────────────────────────┐
│      GUI 层 (gui_app_new.py)    │ ← Tkinter UI
├────────────────────────────────┤
│   OCR 工厂层 (ocr_engine.py)    │ ← 自动选择引擎
├────────────────────────────────┤
│   OCR 引擎层                    │
│  - Tesseract (默认，兼容强)    │
│  - PaddleOCR (可选，精准度高)  │
└────────────────────────────────┘
```

### 工作流程

1. **应用启动** → 初始化 `OCRFactory`
2. **自动检测** → 检测系统中可用的 OCR 引擎
3. **优先使用** → 按优先级选择：PaddleOCR > Tesseract
4. **用户交互** → 可通过菜单手动切换引擎
5. **识别文本** → 使用当前选中的引擎进行识别
6. **导出数据** → 统一的 JSON 格式输出

## 📦 文件结构

```
image_region_generator/
├── ocr_engine.py          ← OCR 引擎抽象层（核心）
├── gui_app_new.py         ← GUI 应用（新架构）
├── gui_app.py             ← GUI 应用（旧版本，保留）
├── requirements.txt       ← Python 依赖
├── setup_venv.sh         ← 虚拟环境设置脚本
├── run_gui.sh            ← 启动脚本（已更新）
└── ARCHITECTURE.md       ← 本文件
```

## 🚀 快速开始

### 首次使用

```bash
cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator

# 1. 设置虚拟环境
chmod +x setup_venv.sh
./setup_venv.sh

# 2. 安装 Tesseract（必需）
brew install tesseract

# 3. 启动应用
chmod +x run_gui.sh
./run_gui.sh
```

### 后续使用

```bash
./run_gui.sh
```

## 🔧 OCR 引擎详解

### Tesseract OCR（默认）

- ✅ 兼容所有 macOS 版本
- ✅ 开源、免费、稳定
- ✅ 支持中文（需要安装 tesseract-chi_sim）
- ❌ 精准度略低于 PaddleOCR

**安装方式**：
```bash
brew install tesseract
# 可选：安装中文语言包
brew install tesseract-chi-sim
```

### PaddleOCR（可选）

- ✅ 精准度高（尤其对中文）
- ✅ 自动选择，无需手动配置
- ❌ 需要 macOS 26+ (最新版本)
- ❌ 首次运行会下载约 100MB 的模型

**安装方式**（仅在支持的系统上）：
```bash
pip install paddleocr
```

如果你的 macOS 升级到最新版本，OCR 工厂会自动检测并优先使用 PaddleOCR。

## 📋 使用步骤

1. **启动应用** → `./run_gui.sh`
2. **加载图片** → 点击"加载图片"
3. **识别文本** → 点击"识别文本"
4. **预览效果** → 点击"预览区域"（可选）
5. **导出 JSON** → 点击"导出 JSON"

## 🎯 菜单功能

### 文件菜单
- 打开图片 - 加载要处理的图片
- 导出 JSON - 保存识别结果
- 退出 - 关闭应用

### OCR 引擎菜单
- 列出所有可用的 OCR 引擎
- 点击选择切换到不同引擎

### 帮助菜单
- 关于 - 显示应用信息
- OCR 引擎状态 - 显示当前使用的引擎和所有可用引擎

## 📊 输出格式

```json
[
  {
    "type": "chinese",
    "id": "text_01",
    "index": 1,
    "text": "识别的文字",
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

## 🔄 升级路径

### 当前（macOS 25）
- Tesseract 作为默认引擎
- PaddleOCR 不可用

### 未来（macOS 26+）
- PaddleOCR 自动启用
- 无需修改任何代码
- 应用会自动使用更精准的引擎

## 🛠️ 开发者指南

### 添加新的 OCR 引擎

创建新的引擎类继承 `OCREngine`：

```python
class MyOCREngine(OCREngine):
    def is_available(self) -> bool:
        # 检查引擎是否可用
        pass
    
    def get_name(self) -> str:
        return "My OCR Engine"
    
    def recognize(self, image: np.ndarray) -> List[Dict[str, Any]]:
        # 实现识别逻辑
        pass
```

然后在 `OCRFactory` 中注册：

```python
class OCRFactory:
    ENGINE_CLASSES = [
        MyOCREngine,      # 新引擎
        PaddleOCREngine,
        TesseractOCR,
    ]
```

## 🐛 故障排查

### 问题 1: "Tesseract 未安装"
```bash
brew install tesseract
```

### 问题 2: "No module named 'pytesseract'"
```bash
pip install pytesseract
```

### 问题 3: "PaddleOCR 初始化失败"
- 这是正常的（macOS 版本不支持）
- 应用会自动使用 Tesseract

### 问题 4: "识别结果不准确"
- 使用更高质量的图片
- 或等待 macOS 升级后自动使用 PaddleOCR

## 📚 相关文件

- `QUICKSTART_30SEC.md` - 30秒快速开始
- `MANUAL_RUN.md` - 手动运行指南
- `VENV_SETUP.md` - 虚拟环境详解

---

**架构设计优势**：
1. 灵活性 - 支持多种 OCR 引擎
2. 可扩展性 - 易于添加新引擎
3. 未来兼容 - 系统升级时自动使用新引擎
4. 用户体验 - 完全透明，无需配置

