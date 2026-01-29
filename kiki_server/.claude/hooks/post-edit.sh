#!/bin/bash
# Post-Edit Hook: 自动格式化 Kotlin 代码
# 在 Claude Code 使用 Edit 或 Write 工具后自动执行

# 获取被编辑的文件路径（由 Claude Code 传入）
FILE_PATH="${FILE_PATH:-$1}"

# 如果没有文件路径，退出
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# 只处理 Kotlin 文件
if [[ "$FILE_PATH" == *.kt ]]; then
    echo "🔧 检测到 Kotlin 文件修改: $FILE_PATH"

    # 检查是否安装 ktlint
    if command -v ktlint &> /dev/null; then
        echo "📝 正在格式化 Kotlin 文件..."
        ktlint -F "$FILE_PATH" 2>/dev/null && echo "✅ 格式化完成" || echo "⚠️ ktlint 未安装或格式化失败"
    else
        echo "ℹ️  ktlint 未安装，跳过自动格式化"
        echo "   安装命令：brew install ktlint 或 下载 ktlint JAR"
    fi
fi

# 只处理 XML 布局文件
if [[ "$FILE_PATH" == */res/layout/*.xml ]]; then
    echo "🎨 检测到布局文件修改: $FILE_PATH"
    # 可以在这里添加 XML 格式化逻辑
fi
