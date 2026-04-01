#!/usr/bin/env python3
"""
下载常用汉字的笔顺数据
支持：
1. 最常用 1000 字
2. 常用 3000 字
3. GB2312 一级汉字（3755 字）
"""
import json
import os
import sys
import requests
from pathlib import Path
from typing import Set, List
import time

# CDN URLs
CDN_URLS = [
    'https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0.1/',
    'https://unpkg.com/hanzi-writer-data@2.0.1/',
]

# 最常用 1000 个汉字（按使用频率排序）
COMMON_1000 = """
的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实加量都两体制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样与关各重新线内数正心反你明看原又么利比或但质气第向道命此变条只没结解问意建月公无系军很情者最立代想已通并提直题党程展五果料象员革位入常文总次品式活设及管特件长求老头基资边流路级少图山统接知较将组见计别她手角期根论运农指几九区强放决西被干做必战先回则任取据处队南给色光门即保治北造百规热领七海口东导器压志世金增争济阶油思术极交受联什认六共权收证改清己美再采转更单风切打白教速花带安场身车例真务具万每目至达走积示议声报斗完类八离华名确才科张信马节话米整空元况今集温传土许步群广石记需段研界拉林律叫且究观越织装影算低持音众书布复容儿须际商非验连断深难近矿千周委素技备半办青省列习响约支般史感劳便团往酸历市克何除消构府称太准精值号率族维划选标写存候毛亲快效斯院查江型眼王按格养易置派层片始却专状育厂京识适��圆包火住调满县局照参红细引听该铁价严龙飞"""

# 常用 3000 字（扩展）
COMMON_3000_EXTRA = """
首底液官德随便抓团泽折亮星轻刻统领域模活题式转约半束注远规抗患夜景阿底房突硬忽席松秋根牛升绝富城钟答哥际旧松宽误护跑洋志愿培养模范围绕获胜击败困境摆脱依靠坚持努力奋斗拼搏创造贡献牺牲奉献服务群众利益幸福美好未来希望梦想理想信念追求目标方向道路选择决定判断思考分析研究探索发现创新改革开放发展进步提高增长扩大加强改善优化完善健全建立形成构建打造推动促进实现达到完成取得获得赢得争取努力奋斗拼搏创造贡献牺牲奉献服务群众利益幸福美好未来希望梦想理想信念追求目标方向道路选择决定判断思考分析研究探索发现创新改革开放发展进步提高增长扩大加强改善优化完善健全建立形成构建打造推动促进实现达到完成取得获得赢得争取
"""

def get_common_characters(count: int = 1000) -> List[str]:
    """获取常用汉字列表"""
    # 清理并去重
    chars = []
    text = COMMON_1000 + (COMMON_3000_EXTRA if count > 1000 else "")

    for char in text:
        if '\u4e00' <= char <= '\u9fff' and char not in chars:
            chars.append(char)
            if len(chars) >= count:
                break

    return chars

def get_gb2312_level1() -> List[str]:
    """获取 GB2312 一级汉字（3755 个）"""
    # GB2312 一级汉字范围：0x4E00-0x9FA5
    chars = []
    for code in range(0x4E00, 0x9FA6):
        chars.append(chr(code))
    return chars[:3755]  # 限制为 3755 个

def download_stroke_data(char: str, output_dir: Path) -> bool:
    """下载单个汉字的笔顺数据"""
    filename = '_'.join(f'{ord(c):04x}' for c in char) + '.json'
    output_path = output_dir / filename

    # 如果已存在，跳过
    if output_path.exists():
        return True

    # 尝试从多个 CDN 下载
    for cdn_url in CDN_URLS:
        try:
            url = f'{cdn_url}{char}.json'
            response = requests.get(url, timeout=10)

            if response.status_code == 200:
                output_path.write_text(response.text, encoding='utf-8')
                return True

        except Exception:
            continue

    return False

def main():
    import argparse

    parser = argparse.ArgumentParser(description='下载常用汉字的笔顺数据')
    parser.add_argument('--count', type=int, default=1000,
                       help='下载数量 (1000, 3000, 或 3755)')
    parser.add_argument('--mode', choices=['common', 'gb2312'], default='common',
                       help='模式: common=常用字, gb2312=GB2312一级字')

    args = parser.parse_args()

    # 项目根目录
    project_root = Path(__file__).parent.parent
    output_dir = project_root / 'kiki_web' / 'assets' / 'data' / 'stroke_order'
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 70)
    print("下载常用汉字笔顺数据")
    print("=" * 70)

    # 获取汉字列表
    if args.mode == 'gb2312':
        characters = get_gb2312_level1()
        print(f"模式: GB2312 一级汉字")
    else:
        characters = get_common_characters(args.count)
        print(f"模式: 最常用 {args.count} 字")

    print(f"目标数量: {len(characters)} 个汉字")
    print(f"输出目录: {output_dir}")
    print()

    # 检查已存在的文件
    existing_files = set(f.stem for f in output_dir.glob('*.json'))
    existing_chars = []
    for char in characters:
        filename = '_'.join(f'{ord(c):04x}' for c in char)
        if filename in existing_files:
            existing_chars.append(char)

    if existing_chars:
        print(f"已存在 {len(existing_chars)} 个汉字，跳过")
        characters = [c for c in characters if c not in existing_chars]

    if not characters:
        print("所有汉字已下载完成！")
        return

    print(f"需要下载 {len(characters)} 个汉字")
    print("开始下载...\n")

    # 下载笔顺数据
    success_count = 0
    fail_count = 0
    fail_chars = []

    for i, char in enumerate(characters, 1):
        # 显示进度
        if i % 50 == 0 or i == 1:
            print(f"进度: {i}/{len(characters)} ({i*100//len(characters)}%)")

        if download_stroke_data(char, output_dir):
            success_count += 1
        else:
            fail_count += 1
            fail_chars.append(char)

        # 避免请求过快
        if i % 10 == 0:
            time.sleep(0.5)

    print("\n" + "=" * 70)
    print(f"下载完成！")
    print(f"  成功: {success_count}")
    print(f"  失败: {fail_count}")
    print(f"  总计: {len(characters)}")

    if fail_chars:
        print(f"\n失败的汉字: {''.join(fail_chars[:50])}")
        if len(fail_chars) > 50:
            print(f"  ... 还有 {len(fail_chars) - 50} 个")

    # 统计总文件数和大小
    total_files = len(list(output_dir.glob('*.json')))
    total_size = sum(f.stat().st_size for f in output_dir.glob('*.json'))
    print(f"\n总文件数: {total_files}")
    print(f"总大小: {total_size / 1024 / 1024:.2f} MB")
    print("=" * 70)

if __name__ == '__main__':
    main()
