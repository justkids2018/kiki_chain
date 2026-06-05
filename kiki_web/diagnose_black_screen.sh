#!/bin/bash

# 学习卡片黑屏诊断脚本
# 使用方法: ./diagnose_black_screen.sh

echo "🔍 学习卡片黑屏诊断"
echo "===================="
echo ""

# 检查1: 音频文件
echo "📁 检查音频文件..."
if [ -d "./assets/audio" ]; then
    echo "✓ assets/audio 目录存在"
    ls -lh ./assets/audio/*.mp3 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
else
    echo "✗ assets/audio 目录不存在！"
fi
echo ""

# 检查2: pubspec.yaml配置
echo "📝 检查pubspec.yaml配置..."
if grep -q "assets/audio/" ./pubspec.yaml; then
    echo "✓ pubspec.yaml包含assets/audio/"
else
    echo "✗ pubspec.yaml缺少assets/audio/配置！"
    echo "  需要添加: - assets/audio/"
fi
echo ""

# 检查3: 必要的Dart文件
echo "📄 检查Dart文件..."
FILES=(
    "./lib/data/models/learning/scene_progress.dart"
    "./lib/data/services/learning/learning_progress_service.dart"
    "./lib/presentation/pages/interactive_image/interactive_image_controller.dart"
    "./lib/presentation/pages/interactive_image/interactive_image_page.dart"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file 不存在！"
    fi
done
echo ""

# 检查4: 依赖包
echo "📦 检查依赖包..."
if grep -q "dio:" ./pubspec.yaml; then
    echo "✓ dio已添加到pubspec.yaml"
else
    echo "⚠️  dio未添加，但可能不影响"
fi

if grep -q "shared_preferences:" ./pubspec.yaml; then
    echo "✓ shared_preferences已添加"
else
    echo "✗ shared_preferences缺失！"
fi
echo ""

# 检查5: Flutter分析
echo "🔬 运行Flutter分析..."
flutter analyze ./lib/presentation/pages/interactive_image/ 2>&1 | grep -E "error|Error" | head -5

if [ $? -eq 1 ]; then
    echo "✓ 没有发现错误"
else
    echo "⚠️  发现错误，请查看上面的输出"
fi
echo ""

# 建议
echo "💡 建议步骤:"
echo "1. 确保所有文件都存在"
echo "2. 运行: flutter clean"
echo "3. 运行: flutter pub get"
echo "4. 重启应用"
echo "5. 如果还是黑屏，查看控制台错误日志"
echo ""
echo "📱 运行应用并查看日志:"
echo "   flutter run -d <device> -v"
