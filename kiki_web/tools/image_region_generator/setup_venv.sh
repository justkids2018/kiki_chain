#!/bin/bash
# 虚拟环境设置脚本
# 创建虚拟环境并安装所有依赖

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$SCRIPT_DIR/.venv"

echo "🔧 设置虚拟环境"
echo "================================"
echo ""

# 创建虚拟环境
if [ -d "$VENV_DIR" ]; then
    echo "✅ 虚拟环境已存在"
else
    echo "🔨 创建虚拟环境..."
    python3 -m venv "$VENV_DIR"
    echo "✅ 虚拟环境已创建"
fi

echo ""
echo "📦 激活虚拟环境..."
source "$VENV_DIR/bin/activate"

echo ""
echo "⬆️  升级 pip..."
pip install --upgrade pip setuptools wheel > /dev/null 2>&1

echo ""
echo "📥 安装 Python 依赖..."
pip install -q -r "$SCRIPT_DIR/requirements.txt"

echo ""
echo "🔍 安装 Tesseract OCR..."
if ! command -v tesseract &> /dev/null; then
    echo "   运行以下命令手动安装:"
    echo "   brew install tesseract"
else
    echo "   ✅ Tesseract 已安装"
fi

echo ""
echo "✅ 验证依赖..."
python3 << 'EOF'
import sys

deps = {
    'PIL': 'Pillow',
    'cv2': 'OpenCV',
    'numpy': 'NumPy',
    'pytesseract': 'Pytesseract',
    'pypinyin': 'pypinyin',
    'googletrans': 'googletrans',
    'tkinter': 'Tkinter'
}

all_ok = True
for module, name in deps.items():
    try:
        __import__(module)
        print(f"   ✅ {name}")
    except ImportError:
        print(f"   ❌ {name}")
        all_ok = False

if all_ok:
    print("\n✅ 设置完成！")
    print("\n下一步:")
    print("  1. 安装 Tesseract: brew install tesseract")
    print("  2. 运行应用: ./run_gui.sh")
else:
    print("\n❌ 某些依赖未安装")
    sys.exit(1)
EOF
