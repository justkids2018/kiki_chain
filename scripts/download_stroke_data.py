#!/usr/bin/env python3
"""
提取场景中的所有汉字并下载笔顺数据到 assets
"""
import json
import os
import sys
import requests
from pathlib import Path
from typing import Set

# CDN URLs
CDN_URLS = [
    'https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0.1/',
    'https://unpkg.com/hanzi-writer-data@2.0.1/',
]

def is_chinese(char: str) -> bool:
    """判断是否为中文字符"""
    code = ord(char)
    return 0x4E00 <= code <= 0x9FFF

def extract_characters_from_json(json_path: str) -> Set[str]:
    """从 JSON 文件中提取所有汉字"""
    characters = set()

    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # 处理不同的 JSON 结构
        regions = []

        # 新结构：scene.items_data[].regions
        if isinstance(data, dict) and 'items_data' in data:
            for item in data.get('items_data', []):
                regions.extend(item.get('regions', []))
        # 旧结构：直接是 regions 数组
        elif isinstance(data, list):
            regions = data
        # 其他结构
        elif isinstance(data, dict) and 'regions' in data:
            regions = data['regions']

        # 提取汉字
        for region in regions:
            text = region.get('text', '')
            for char in text:
                if is_chinese(char):
                    characters.add(char)

        print(f"✓ {json_path}: 找到 {len(characters)} 个汉字")

    except Exception as e:
        print(f"✗ {json_path}: 读取失败 - {e}")

    return characters

def download_stroke_data(char: str, output_dir: Path) -> bool:
    """下载单个汉字的笔顺数据"""
    # 生成文件名（Unicode 编码）
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
    # 项目根目录
    project_root = Path(__file__).parent.parent

    # 输出目录
    output_dir = project_root / 'kiki_web' / 'assets' / 'data' / 'stroke_order'
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("提取场景中的汉字并下载笔顺数据")
    print("=" * 60)

    # 收集所有汉字
    all_characters = set()

    # 扫描 assets/data 目录中的 JSON 文件
    data_dir = project_root / 'kiki_web' / 'assets' / 'data'
    if data_dir.exists():
        for json_file in data_dir.rglob('*.json'):
            chars = extract_characters_from_json(str(json_file))
            all_characters.update(chars)

    print(f"\n总共找到 {len(all_characters)} 个唯一汉字")
    print(f"输出目录: {output_dir}")
    print("\n开始下载笔顺数据...")

    # 下载笔顺数据
    success_count = 0
    fail_count = 0

    for i, char in enumerate(sorted(all_characters), 1):
        print(f"[{i}/{len(all_characters)}] 下载 '{char}'...", end=' ')

        if download_stroke_data(char, output_dir):
            print("✓")
            success_count += 1
        else:
            print("✗ 失败")
            fail_count += 1

    print("\n" + "=" * 60)
    print(f"下载完成！")
    print(f"  成功: {success_count}")
    print(f"  失败: {fail_count}")
    print(f"  总计: {len(all_characters)}")
    print("=" * 60)

if __name__ == '__main__':
    main()
