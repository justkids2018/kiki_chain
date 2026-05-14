#!/usr/bin/env python3
"""
Hi Kiki 学习卡片场景图生成脚本

使用 Google Gemini API (Imagen 3) 根据主题自动生成场景学习图并保存到项目目录。

用法:
    python scripts/generate_scene_image.py --theme 图书馆一角
    python scripts/generate_scene_image.py --theme 厨房 --palette 暖黄色
    python scripts/generate_scene_image.py --theme 动物园 --count 3

前置条件:
    1. pip install google-genai Pillow
    2. 设置环境变量: export GEMINI_API_KEY="your-api-key"
       或创建文件: kiki_web/.env (内容: GEMINI_API_KEY=your-api-key)
    3. API Key 免费获取: https://aistudio.google.com/apikey
"""

import argparse
import os
import sys
import time
from pathlib import Path

# 项目根目录
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent  # kiki_web/
ASSETS_DIR = PROJECT_ROOT / "assets" / "images"

# 主题到色调的默认映射
THEME_PALETTES = {
    # 晨光乐趣
    "操场晨练": "清新绿、天蓝色",
    "升旗仪式": "红色、金色、天蓝",
    "晨读时光": "暖木色、米白色",
    "课间游戏": "明亮黄、活力橙",
    "手工课": "彩虹色、马卡龙色",
    "校园花园": "嫩绿色、花瓣粉",
    # 数学思维
    "数字乐园": "彩虹渐变、明亮色",
    "形状世界": "几何蓝、明亮黄",
    "水果计数": "水果色系、明亮暖色",
    "量一量": "科学蓝、白色",
    "配对游戏": "积木色、原木暖色",
    "比大小": "对比色、鲜明暖色",
    # 日常生活
    "超市购物": "明亮白、浅蓝色",
    "公园散步": "嫩绿色、天蓝色",
    "生日派对": "糖果粉、金色",
    "洗澡时间": "泡泡蓝、柔和白",
    "穿衣搭配": "衣橱暖木色、柔和彩色",
    "看医生": "洁净白、浅蓝绿",
    # 游乐场景
    "恐龙世界": "丛林绿、火山橙",
    "太空探险": "深紫色、星空蓝",
    "海盗船": "海洋蓝、金色",
    "童话城堡": "梦幻紫、金色",
    "马戏团": "红色、金色",
    "沙滩乐园": "沙滩金、海洋蓝",
    # 已有场景
    "图书馆一角": "暖木色、米白色",
    "图书馆": "暖木色、米白色",
    "厨房": "暖黄色、奶白色",
    "动物园": "草绿色、天蓝色",
    "玩具": "糖果粉、薄荷绿",
}

# 主题到目录名的映射
THEME_DIR_NAMES = {
    # 晨光乐趣
    "操场晨练": "morning_exercise",
    "升旗仪式": "flag_ceremony",
    "晨读时光": "morning_reading",
    "课间游戏": "recess_games",
    "手工课": "craft_class",
    "校园花园": "school_garden",
    # 数学思维
    "数字乐园": "number_park",
    "形状世界": "shape_world",
    "水果计数": "counting_fruits",
    "量一量": "measurement",
    "配对游戏": "matching_game",
    "比大小": "size_comparison",
    # 日常生活
    "超市购物": "supermarket",
    "公园散步": "park_walk",
    "生日派对": "birthday_party",
    "洗澡时间": "bath_time",
    "穿衣搭配": "getting_dressed",
    "看医生": "doctor_visit",
    # 游乐场景
    "恐龙世界": "dinosaur_world",
    "太空探险": "space_adventure",
    "海盗船": "pirate_ship",
    "童话城堡": "fairy_castle",
    "马戏团": "circus",
    "沙滩乐园": "beach_fun",
    # 已有场景
    "图书馆一角": "library",
    "图书馆": "library",
    "厨房": "kitchen",
    "动物园": "zoo",
    "玩具": "toy",
}


def get_api_key() -> str:
    """从环境变量或 .env 文件获取 API Key"""
    key = os.environ.get("GEMINI_API_KEY")
    if key:
        return key

    # 尝试从 .env 文件读取
    env_file = PROJECT_ROOT / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            line = line.strip()
            if line.startswith("GEMINI_API_KEY=") and not line.startswith("#"):
                return line.split("=", 1)[1].strip().strip('"').strip("'")

    print("❌ 未找到 GEMINI_API_KEY")
    print("   设置方式:")
    print("   1. export GEMINI_API_KEY='your-key'")
    print(f"   2. 或创建文件 {env_file} 写入: GEMINI_API_KEY=your-key")
    print("   API Key 获取: https://aistudio.google.com/apikey")
    sys.exit(1)


def build_prompt(theme: str, palette: str) -> str:
    """根据主题和色调构建完整 Prompt"""
    return f"""**{theme}** (主题): Hi Kiki

---

### I. 📌 核心配置与色调 (Configuration & Tone)
* **{theme} (主题)**: Hi Kiki
* **3-6 岁儿童学习 (早教)**
* **正方形 (Square, 1:1 Aspect Ratio)**
* **1024x1024 像素**
* **🎨 风格基调 (Tone)**: **精致等距投影 3D 渲染 (Detailed Isometric 3D Projection)**。色彩**明亮、干净、饱和度适中**。背景为**干净的天空蓝**，上方必须有**圆润、厚实的 3D 立体云彩 (Volumetric 3D Clouds)**。
* **➡️ 本次生成主色调**: **{palette}**
* **💡 视角与灯光**: **严格使用等距投影 (Isometric View, 45-degree angle)**。灯光干净、均匀，强调材质的光滑质感。

---

### II. 🖼️ 画面整体与风格固化 (Structure & Fixed Style)

#### 1. 核心视觉风格
* **主体风格**: **精致、光滑的 3D 几何渲染**。物体边缘干净，具有**模型或微缩景观**的质感。
* **背景元素**: 必须包含**体积感强、圆润、卡通的 3D 云彩**，漂浮在蓝天上。画面顶部保持干净，**禁止出现大标题文字**。
* **清晰度**: **全焦段清晰锐利 (Razor Sharp Focus)**，展现微缩模型的高细节。

#### 2. 场景与布局
* **场景焦点**: **画面中央聚焦于场景物品**。所有物品被放置在一个**等距投影的微缩平台**上。
* **场景布置**: 场景布置和颜色必须**严格遵循 {palette}**。**清晰、独立地放置 8 个目标物体**，物体之间保持舒适的间距，避免拥挤。
* **物品尺寸**: 每个物品在画面中应**占据足够的可视面积**（便于用户点击），物品主体区域不小于画面面积的 4%。

---

### III. 🏷️ 精准识字标注系统 (Strict Fixed Format)

AI 必须自动生成并标注场景中的 8 个物体。**所有标注元素必须严格遵循以下固定样式。**

#### 1. 固定箭头样式 (严格执行)
* **形态**: 必须使用**粗壮、圆润、具有光泽的 3D 卡通箭头**。
* **颜色**: 箭头颜色必须**鲜明但柔和**，与背景和卡片颜色形成**中性对比**。
* **指向**: 箭头必须**精准指向**对应的插图对象的**中心位置**，**严禁交叉**。
* **长度**: 箭头保持**短而精准**，避免过长遮挡物品。

#### 2. 固定文字卡片样式 (严格执行)
* **形态**: 必须使用**圆角矩形 3D 贴纸标签牌**，具有**光滑的厚度感**和**马卡龙色系底色**。卡片应悬浮在物品附近。
* **尺寸**: 卡片保持**紧凑小巧**，不遮挡物品主体。
* **内容格式 (严格三行)**:
    1. **第一行 (Hanyu Pinyin)**: 标准汉语拼音 (带声调)，**黑体无衬线**。
    2. **第二行 (Hanzi)**: 简体汉字 (**超粗圆体**，颜色**醒目**)。
    3. **第三行 (English)**: 英文单词 (**无衬线圆体**，小号)。

---

### IV. 📝 词汇生成指令 (Vocabulary Generation Instruction)
* AI **必须**根据 **{theme}** 主题，**自动生成 8 个** 最适合儿童学习的、形状圆润的目标物体。
* **标签内容**: AI 必须为这 8 个生成的物体，**严格地**遵循第三部分定义的**三行式**标签格式来生成所有标签内容（汉字、拼音、英文）。

---

### V. 品牌标记 (Branding Tag)
* **位置**: 画面**右上角**或**左上角**，不遮挡主题内容。
* **样式**: 仅显示一个**小标签**："**Hi Kiki**"（或 "KK Lab"）。
* **尺寸**: **小巧低调**，占画面面积不超过 3%。
* **视觉效果**: **白色或主色调 3D 浮雕**样式，带柔和投影，风格与整体场景一致。
* **⚠️ 禁止**: 不得出现大号标题、横幅 banner 或其他占据画面大面积的文字元素。

---

### VI. ⭐ 画风参数总结 (Style Parameters Summary)
* **Prompt 总结**: **Square 1:1, 1024x1024px**, **Detailed Isometric 3D Projection**, **Volumetric 3D Clouds**, **No Large Title**, **No Human Characters**, **{palette} Tone**, **Strictly Eight Objects Labeled**, **Precise Labeling with Short 3D Arrows and Compact 3-line Cards**, **Small "Hi Kiki" Tag in Corner**.
* **质量**: Ultra High Detail, Cinema 4D cute render, Razor Sharp Focus.
* **核心指令**: **必须严格使用正方形等距投影视角。禁止画面顶部出现大标题。标签卡片保持紧凑。确保 8 个物品清晰独立、便于识别和定位。品牌标记仅为角落小标签。**"""


def get_dir_name(theme: str) -> str:
    """获取主题对应的目录名"""
    if theme in THEME_DIR_NAMES:
        return THEME_DIR_NAMES[theme]
    # 默认用拼音首字母或直接用主题名
    return theme.replace(" ", "_").replace("一角", "")


def generate_image(theme: str, palette: str, output_dir: Path, count: int = 1):
    """调用 Gemini API 生成图片"""
    try:
        from google import genai
        from google.genai import types
    except ImportError:
        print("❌ 请先安装依赖: pip install google-genai Pillow")
        sys.exit(1)

    api_key = get_api_key()
    client = genai.Client(api_key=api_key)

    # 确保输出目录存在
    output_dir.mkdir(parents=True, exist_ok=True)

    prompt = build_prompt(theme, palette)

    print(f"🎨 主题: {theme}")
    print(f"🎨 色调: {palette}")
    print(f"📁 输出: {output_dir}")
    print(f"📦 数量: {count}")
    print()

    for i in range(count):
        suffix = f"_{i+1}" if count > 1 else ""
        filename = f"kiki_{get_dir_name(theme)}{suffix}.png"
        filepath = output_dir / filename

        print(f"⏳ [{i+1}/{count}] 正在生成 {filename} ...")

        try:
            # 使用 Gemini 3 Pro Image 生成图片
            response = client.models.generate_content(
                model="gemini-3-pro-image-preview",
                contents=f"请根据以下 Prompt 生成一张图片：\n\n{prompt}",
                config=types.GenerateContentConfig(
                    response_modalities=["IMAGE", "TEXT"],
                ),
            )

            # 从响应中提取图片
            image_saved = False
            if response.candidates:
                for part in response.candidates[0].content.parts:
                    if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                        with open(filepath, "wb") as f:
                            f.write(part.inline_data.data)
                        print(f"✅ 已保存: {filepath}")
                        print(f"   大小: {filepath.stat().st_size / 1024:.1f} KB")
                        image_saved = True
                        break

            if not image_saved:
                print(f"⚠️  生成失败，API 未返回图片")
                # 打印文本响应（如果有）
                if response.candidates:
                    for part in response.candidates[0].content.parts:
                        if part.text:
                            print(f"   AI 回复: {part.text[:200]}")

        except Exception as e:
            error_msg = str(e)
            if "PERMISSION_DENIED" in error_msg or "API_KEY_INVALID" in error_msg:
                print(f"❌ API Key 无效或权限不足")
                print(f"   请检查 Key 是否启用了 Gemini API")
                sys.exit(1)
            elif "RESOURCE_EXHAUSTED" in error_msg:
                print(f"⚠️  API 配额用完，请稍后重试")
                sys.exit(1)
            else:
                print(f"❌ 生成出错: {e}")

        # 多张图之间加间隔避免限流
        if i < count - 1:
            time.sleep(2)

    print()
    print(f"🎉 完成! 图片保存在: {output_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Hi Kiki 场景学习卡片图片生成",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python scripts/generate_scene_image.py --theme 图书馆一角
  python scripts/generate_scene_image.py --theme 厨房 --palette 暖黄色
  python scripts/generate_scene_image.py --theme 动物园 --count 3
  python scripts/generate_scene_image.py --list-themes

预置主题: 图书馆一角, 厨房, 动物园, 玩具, 公园, 海洋, 太空, 农场, 超市
        """,
    )
    parser.add_argument("--theme", "-t", type=str, help="场景主题 (如: 图书馆一角)")
    parser.add_argument("--palette", "-p", type=str, help="色调 (可选，有默认)")
    parser.add_argument("--count", "-c", type=int, default=1, help="生成数量 (默认 1)")
    parser.add_argument("--output", "-o", type=str, help="自定义输出目录")
    parser.add_argument("--list-themes", action="store_true", help="列出预置主题")

    args = parser.parse_args()

    if args.list_themes:
        print("📋 预置主题列表:")
        print()
        for theme, palette in THEME_PALETTES.items():
            dir_name = THEME_DIR_NAMES.get(theme, theme)
            print(f"  {theme:<10} → 色调: {palette:<16} 目录: assets/images/{dir_name}/")
        return

    if not args.theme:
        parser.print_help()
        print()
        print("❌ 请指定 --theme 参数")
        sys.exit(1)

    theme = args.theme
    palette = args.palette or THEME_PALETTES.get(theme, "明亮柔和色")

    if args.output:
        output_dir = Path(args.output)
    else:
        dir_name = get_dir_name(theme)
        output_dir = ASSETS_DIR / dir_name

    generate_image(theme, palette, output_dir, args.count)


if __name__ == "__main__":
    main()
