@echo off
REM 图片区域 JSON 生成工具启动脚本 (Windows)

echo 检查 Python 环境...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)

echo 检查依赖...
pip list | find "pillow" > nul 2>&1
if %errorlevel% neq 0 (
    echo 安装依赖...
    pip install -r requirements.txt
)

echo 启动应用...
python gui_app.py

if %errorlevel% neq 0 (
    echo.
    echo 应用启动失败！
    echo 请检查上面的错误信息
    pause
)
