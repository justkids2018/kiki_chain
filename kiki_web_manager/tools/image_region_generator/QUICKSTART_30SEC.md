# 快速开始 - 3 步启动

## 🚀 30 秒快速开始

### 第 1 步：打开终端
```bash
# 打开 macOS 终端（Cmd + Space，输入 Terminal）
```

### 第 2 步：复制粘贴下面的命令
```bash
cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator && chmod +x setup_venv.sh && ./setup_venv.sh
```

**等待 3-5 分钟**（首次安装依赖会很慢）

### 第 3 步：运行应用
```bash
chmod +x run_gui_with_venv.sh && ./run_gui_with_venv.sh
```

✅ GUI 窗口会立即打开！

---

## 💡 下次启动（超简单）

```bash
cd /Users/qisd/Documents/development/chain/kiki_chain/kiki_web/tools/image_region_generator && ./run_gui_with_venv.sh
```

---

## 📖 如果遇到问题

- **依赖缺失**：查看 [VENV_SETUP.md](VENV_SETUP.md)
- **运行失败**：查看 [MANUAL_RUN.md](MANUAL_RUN.md)
- **环境问题**：运行 `python3 check_env.py`

---

## 🎯 使用步骤

1. **加载图片** - 点击"加载图片"
2. **识别文本** - 点击"识别文本"
3. **预览区域** - 点击"预览区域"
4. **导出 JSON** - 点击"导出 JSON"

---

## 📁 文件结构

```
image_region_generator/
├── gui_app.py                 # 主应用
├── check_env.py              # 环境检查
├── setup_venv.sh             # 一键设置脚本 ⭐
├── run_gui_with_venv.sh      # 一键启动脚本 ⭐
├── requirements.txt          # 依赖列表
├── kiki_zhiwuyuan.json      # 输出格式示例
├── QUICKSTART.md            # 基础指南
├── VENV_SETUP.md            # 虚拟环境详解
├── MANUAL_RUN.md            # 故障排查
└── .venv/                   # 虚拟环境目录（首次运行会创建）
```

⭐ 标记的文件是你主要需要的

---

## 🎉 就这么简单！

第一次设置需要几分钟，之后每次启动只需一条命令。
