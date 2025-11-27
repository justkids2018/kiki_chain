#!/usr/bin/env python3
"""
简单的环境检查脚本
检查所有必需的依赖是否已安装
"""

import sys
from pathlib import Path

def check_dependencies():
    """检查依赖项"""
    print("🔍 检查 Python 环境...\n")
    print(f"Python 版本: {sys.version}")
    print(f"Python 路径: {sys.executable}\n")
    
    dependencies = {
        'tkinter': 'Tkinter GUI 库',
        'PIL': 'Pillow 图像处理库',
        'cv2': 'OpenCV 计算机视觉库',
        'paddleocr': 'PaddleOCR 文字识别库',
        'numpy': 'NumPy 数值计算库'
    }
    
    missing = []
    installed = []
    
    for module, description in dependencies.items():
        try:
            __import__(module)
            installed.append(f"✅ {module:15} - {description}")
        except ImportError:
            missing.append(f"❌ {module:15} - {description}")
    
    print("=" * 60)
    print("已安装的依赖：")
    print("=" * 60)
    for item in installed:
        print(item)
    
    if missing:
        print("\n" + "=" * 60)
        print("缺失的依赖：")
        print("=" * 60)
        for item in missing:
            print(item)
        
        print("\n" + "=" * 60)
        print("安装命令：")
        print("=" * 60)
        print("pip3 install -r requirements.txt")
        print("\n或者单独安装：")
        if any('tkinter' in m for m in missing):
            print("  macOS: tkinter 通常随 Python 安装，如有问题尝试: brew install python-tk")
        if any('PIL' in m for m in missing):
            print("  pip3 install Pillow")
        if any('cv2' in m for m in missing):
            print("  pip3 install opencv-python")
        if any('paddleocr' in m for m in missing):
            print("  pip3 install paddleocr")
        if any('numpy' in m for m in missing):
            print("  pip3 install numpy")
        
        return False
    
    print("\n✅ 所有依赖已安装！可以运行 GUI 应用了。")
    print("\n运行命令：")
    print("  python3 gui_app.py")
    return True

def check_sample_file():
    """检查示例文件"""
    sample_file = Path(__file__).parent / "kiki_zhiwuyuan.json"
    if sample_file.exists():
        print(f"\n✅ 找到示例文件: {sample_file.name}")
    else:
        print(f"\n⚠️  未找到示例文件: {sample_file.name}")
        print("   但不影响程序运行")

def main():
    print("=" * 60)
    print(" 图片文字区域生成器 - 环境检查")
    print("=" * 60)
    print()
    
    success = check_dependencies()
    check_sample_file()
    
    print("\n" + "=" * 60)
    if success:
        print("🎉 环境检查完成，一切正常！")
    else:
        print("⚠️  请先安装缺失的依赖")
    print("=" * 60)

if __name__ == "__main__":
    main()
