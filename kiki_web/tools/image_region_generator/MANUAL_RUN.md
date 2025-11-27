# 手动运行指南

## ⚡ 推荐方式：使用虚拟环境（一键安装）

由于系统 Python 受保护，需要使用虚拟环境安装依赖。

### 1. 打开终端

- 按 `Cmd + Space` 打开 Spotlight
- 输入 "Terminal" 并回车

### 2. 一键设置

```bash
cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator
chmod +x setup_venv.sh
./setup_venv.sh
```

脚本会自动：
- ✅ 创建虚拟环境 (`.venv/`)
- ✅ 安装所有依赖
- ✅ 验证安装结果

### 3. 运行应用

```bash
chmod +x run_gui_with_venv.sh
./run_gui_with_venv.sh
```

---

## 其他方法

### 方法 1：手动创建虚拟环境

1. **进入工具目录**
   ```bash
   cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator
   ```

2. **创建虚拟环境**
   ```bash
   python3 -m venv .venv
   ```

3. **激活虚拟环境**
   ```bash
   source .venv/bin/activate
   ```

4. **安装依赖**
   ```bash
   pip install -r requirements.txt
   ```

5. **运行应用**
   ```bash
   python3 gui_app.py
   ```

### 方法 2：使用启动脚本

1. **进入工具目录**
   ```bash
   cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator
   ```

2. **赋予执行权限**
   ```bash
   chmod +x run_gui_with_venv.sh
   ```

3. **运行脚本**
   ```bash
   ./run_gui_with_venv.sh
   ```

### 方法 3：使用 VS Code 终端

1. 在 VS Code 中按 `` Ctrl+` `` 打开集成终端
2. 激活虚拟环境：
   ```bash
   source /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator/.venv/bin/activate
   ```
3. 运行应用：
   ```bash
   python3 gui_app.py
   ```

## 可能的问题与解决方案

### 问题 1: "externally-managed-environment"
这是 macOS 上系统 Python 的保护机制，解决方案：
1. **推荐**：使用虚拨环境（见上面的推荐方式）
2. 或使用虚拟环境的手动方法（见方法 1）

### 问题 2: "command not found: setup_venv.sh"
**解决方案**：赋予执行权限
```bash
chmod +x setup_venv.sh
./setup_venv.sh
```

### 问题 3: "No module named 'paddleocr'"
**解决方案**：确保虚拟环境已激活
```bash
source .venv/bin/activate
python3 check_env.py
```

### 问题 4: "No module named 'PIL'"
确保依赖已安装：
```bash
source .venv/bin/activate
pip install Pillow
```

### 问题 5: "No module named 'cv2'"
**解决方案**：
```bash
source .venv/bin/activate
pip install opencv-python
```

### 问题 6: tkinter 未安装
在 macOS 上，tkinter 通常随 Python 一起安装。如果遇到问题：
```bash
brew install python-tk@3.12
```

### 问题 7: PaddleOCR 初始化失败
**解决方案**：
- 首次运行会自动下载模型文件（约 100MB）
- 确保网络连接正常
- 如果下载失败，可以多尝试几次
- 检查磁盘空间是否充足

## 使用步骤

1. **启动应用**：运行上述任一命令后，GUI 窗口会打开
2. **加载图片**：点击"加载图片"按钮，选择要识别的图片
3. **识别文本**：点击"识别文本"按钮，等待 OCR 处理
4. **预览结果**：点击"预览区域"查看识别框和文字
5. **导出 JSON**：点击"导出 JSON"保存结果

## 功能说明

- **加载图片**：支持 JPG、PNG、BMP 格式
- **识别文本**：使用 PaddleOCR 识别中文文字
- **预览区域**：在图片上绘制识别框，标注文字
- **导出 JSON**：按照 kiki_zhiwuyuan.json 格式导出
- **清空数据**：重置所有识别结果

## 输出格式

生成的 JSON 文件包含以下字段：
```json
[
  {
    "type": "chinese",
    "id": "chinese_pinyin_01",
    "index": 1,
    "text": "识别的中文文字",
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

## 提示

1. 首次运行会自动下载 PaddleOCR 模型，需要一些时间
2. 识别完成后，`text_pinyin` 和 `text_english` 为空，需要手动编辑 JSON 文件补充
3. 可以多次加载图片、识别和预览，互不影响
4. 建议使用清晰、高分辨率的图片以获得更好的识别效果

## 常见问题

**Q: GUI 窗口无法打开？**
A: 检查 Python 是否正确安装，确保使用 `python3` 命令

**Q: 识别结果不准确？**
A: 尝试使用更高质量的图片，或调整图片尺寸和对比度

**Q: 可以批量处理图片吗？**
A: 当前版本不支持批量处理，需要逐个加载图片

**Q: 如何修改识别结果？**
A: 导出 JSON 后，使用文本编辑器手动编辑 `text_pinyin` 和 `text_english` 字段
