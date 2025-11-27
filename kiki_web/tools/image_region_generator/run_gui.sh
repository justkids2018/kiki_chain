#!/bin/bash
# 启动脚本 - 图片文字区域生成工具
# 自动检测和使用可用的 OCR 引擎（Tesseract 或 PaddleOCR）

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$SCRIPT_DIR/.venv"
APP_FILE="$SCRIPT_DIR/gui_app_new.py"

# 检查虚拟环境
if [ ! -d "$VENV_DIR" ]; then
    echo "❌ 虚拟环境不存在"
    echo ""
    echo "请先运行以下命令进行首次设置："
    echo "  chmod +x setup_venv.sh"
    echo "  ./setup_venv.sh"
    exit 1
fi

# 激活虚拟环境
source "$VENV_DIR/bin/activate"

# 运行应用
exec python3 "$APP_FILE"
