#!/usr/bin/env python3
"""Generate scene card prompt assets from doc/card-generation/SCENES.md.

Output layout:
  doc/card-generation/scene-info/scene_<NN>_<场景>/
    kik_<场景>_<NN>_<功能>/
      kik_<场景>_<NN>_<功能>.md
      prompt.md
      kik_<场景>_<NN>_<功能>.json

Also updates doc/card-generation/scene-info/index.json.
"""

from __future__ import annotations

import json
import re
from pathlib import Path


CAT_PAT = re.compile(r"^##\s+([一二三四])、(.+?)（(.+?)）\s*$")
THEME_PAT = re.compile(r"^###\s+(\d+)\.(\d+)\s+(.+?)（(.+?)）\s*$")
ROW_PAT = re.compile(
    r"^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$"
)
PALETTE_PAT = re.compile(r"^\*\*色调建议\*\*:\s*(.+)$")


def scene_profile(category_cn: str, theme_cn: str) -> dict:
    if category_cn == "晨光乐趣":
        profile = {
            "scene_name": f"real {theme_cn} school environment",
            "elements": [
                "A classroom or school area matching the theme",
                "Student-oriented furniture and learning props",
                "Warm daylight and child-friendly atmosphere",
                "Clean background with clear depth layers",
                "Real-world floor/wall/spatial structure",
            ],
            "atmosphere": "Warm, focused, lively morning campus feeling",
        }

        if theme_cn == "操场晨练":
            profile.update(
                {
                    "scene_name": "real outdoor school playground morning exercise environment",
                    "elements": [
                        "A real outdoor school playground with one clearly visible curved running track and open green field",
                        "Sports props placed across the grass, track edge, and walkway to keep the composition balanced",
                        "Warm morning sunlight, blue sky, and a child-friendly campus atmosphere",
                        "Distinct foreground, midground, and background layers with readable depth",
                        "No classroom furniture, desks, display shelves, or indoor props",
                    ],
                    "atmosphere": "Warm, lively, and clearly outdoor school exercise scene",
                    "focus": [
                        "Treat the scene as an outdoor playground, not an indoor classroom or product display.",
                        "Use one red curved running track and one open green field as the main spatial anchors.",
                        "Keep every target vocabulary item unique; do not duplicate sandbags, hoops, ropes, or track segments.",
                    ],
                    "placement_map": [
                        "1. 跳绳 (tiào shéng / Jump Rope) — foreground left on the track edge, coiled rope with two clearly separated handles.",
                        "2. 皮球 (pí qiú / Ball) — mid-left on the grass near the track, single ball with a simple round silhouette.",
                        "3. 呼啦圈 (hū lā quān / Hula Hoop) — foreground left/lower-left, one large colorful ring lying flat and not touching the track line.",
                        "4. 跑道 (pǎo dào / Track) — the curved red running lane occupying the lower and right edges of the playground.",
                        "5. 哨子 (shào zi / Whistle) — near the upper-right walkway/fence area, small whistle enlarged enough to read clearly.",
                        "6. 操场 (cāo chǎng / Playground) — the open green center field of the scene, clearly showing the playground area itself.",
                        "7. 毽子 (jiàn zi / Shuttlecock) — lower center-right on the grass, one feather shuttlecock standing out from the background.",
                        "8. 沙包 (shā bāo / Sandbag) — lower-right on the grass, one cloth sandbag separated from the shuttlecock and track.",
                    ],
                }
            )

        return profile

    if category_cn == "数学思维":
        return {
            "scene_name": f"real {theme_cn} learning play environment",
            "elements": [
                "Math-learning corners, toys, or activity stations",
                "Balanced tabletop and floor-level layout",
                "Clear geometric or counting visual cues",
                "Soft educational setting with natural depth",
                "Child-safe materials and rounded forms",
            ],
            "atmosphere": "Explorative, playful, and structured cognition space",
        }

    if category_cn == "日常生活":
        return {
            "scene_name": f"real {theme_cn} daily-life environment",
            "elements": [
                "Home/public setting matching the theme",
                "Natural object placement in real use positions",
                "Human-scale furniture and practical props",
                "Simple and clean background separation",
                "Comfortable warm light with realistic materials",
            ],
            "atmosphere": "Natural, familiar, and life-oriented",
        }

    return {
        "scene_name": f"real {theme_cn} adventure environment",
        "elements": [
            "Theme-matching immersive play scene",
            "Foreground-midground-background depth composition",
            "Props distributed across the environment naturally",
            "Whimsical but readable realistic-stylized rendering",
            "Clear visual hierarchy around 8 target objects",
        ],
        "atmosphere": "Fun, imaginative, and clearly navigable",
    }


def parse_scenes_md(path: Path):
    lines = path.read_text(encoding="utf-8").splitlines()
    categories = []
    cur_cat = None
    cur_theme = None

    for line in lines:
        mcat = CAT_PAT.match(line)
        if mcat:
            cur_cat = {
                "idx": len(categories) + 1,
                "cn": mcat.group(2).strip(),
                "themes": [],
            }
            categories.append(cur_cat)
            cur_theme = None
            continue

        mtheme = THEME_PAT.match(line)
        if mtheme and cur_cat is not None:
            cur_theme = {
                "major": int(mtheme.group(1)),
                "minor": int(mtheme.group(2)),
                "cn": mtheme.group(3).strip(),
                "vocab": [],
                "palette": "明亮、温暖、真实",
            }
            cur_cat["themes"].append(cur_theme)
            continue

        if cur_theme is None:
            continue

        mrow = ROW_PAT.match(line)
        if mrow:
            idx = int(mrow.group(1))
            if 1 <= idx <= 8:
                cur_theme["vocab"].append(
                    (
                        idx,
                        mrow.group(2).strip(),
                        mrow.group(3).strip(),
                        mrow.group(4).strip(),
                        mrow.group(5).strip(),
                    )
                )
            continue

        mp = PALETTE_PAT.match(line)
        if mp:
            cur_theme["palette"] = mp.group(1).strip()

    return categories


def render_prompt_md(category_cn: str, theme: dict, card_slug: str) -> str:
    vocab = sorted(theme["vocab"], key=lambda x: x[0])[:8]
    vocab_lines = [f"- [{py}] / {zh} / {en} ({pho})" for _, zh, py, en, pho in vocab]
    vocab_block = "\n".join(vocab_lines) if vocab_lines else "- 待补充 8 词表"
    profile = scene_profile(category_cn, theme["cn"])
    placement_source = profile.get("placement_map")
    placement_lines = placement_source or [
        f"{idx}. {zh} ({py} / {en}) — place naturally at a real-world position in this scene."
        for idx, zh, py, en, _ in vocab
    ]
    placement_block = "\n".join(placement_lines) if placement_lines else "1. 待补充真实位置映射"
    card_lines = [f"- [{py}] / {zh} / {en}" for _, zh, py, en, _ in vocab]
    card_block = "\n".join(card_lines) if card_lines else "- 待补充 8 张卡片三行文本"
    arrow_lines = [
        f"- {zh} arrow -> lands on {en} object body (not nearby blank/background)."
        for _, zh, _, en, _ in vocab
    ]
    arrow_block = "\n".join(arrow_lines) if arrow_lines else "- 待补充箭头精确落点"
    scene_elements_block = "\n".join([f"- {e}" for e in profile["elements"]])
    scene_focus_block = "\n".join([f"- {e}" for e in profile.get("focus", [])])

    return f"""# {theme['cn']} — 真实场景学习卡片 Prompt

> 分类：{category_cn}
> 主题序号：{theme['major']}.{theme['minor']}
> 场景文件：{card_slug}.png
> 热区文件：{card_slug}.json

---

```text
**{theme['cn']}** (主题): Hi Kiki

### I. Core Setup
- Target age: 3-6 years old
- Format: exact square 1:1
- Resolution: exact 1024x1024 pixels
- View: slightly elevated 3/4 top-front view, looking into a {profile['scene_name']}
- Style: realistic base with fuller, softer 3D volume enhancement
- Keep real-world proportions and recognizable shapes
- Do not over-inflate objects into balloon or gummy style
- Keep the image realistic first, but forms should feel rounded, solid, and full-bodied
- Color palette suggestion: {theme['palette']}
- The final image must fully use the square canvas, with no portrait crop, no landscape crop, no inner frame, no extra border, and no unused blank margin

### II. Real Scene Requirement
Create a complete, real {theme['cn']} environment. The entire image IS this scene — there is no separate display table or product shelf.

Scene elements:
{scene_elements_block}

Scene atmosphere:
- {profile['atmosphere']}
- The 8 vocabulary items form a closed set: use exactly one instance of each item, with no duplicates or substitutions.
- Keep the object identities stable before adding labels or arrows.
{scene_focus_block}
- Subtle depth-of-field: center sharper, far edges slightly softer
- Natural light direction and contact shadows
- No giant title text anywhere

Depth distribution:
- Place some objects in foreground (larger and clearer)
- Place some in middle ground
- Place some in background (still identifiable)
- Avoid clustering all objects on one surface

### III. 8 Target Vocabulary Objects
{vocab_block}

Object placement map:
{placement_block}

Critical placement rules:
- Exactly 8 target objects, 8 label cards, 8 arrows
- Each target object must appear exactly once; do not duplicate sandbags, hoops, ropes, tracks, or any other vocab item.
- Every object must be clearly visible and identifiable
- Small objects must still be enlarged enough for child recognition
- Avoid heavy overlap that hides object identity
- Keep directional separation when two nearby objects might be confused
- No two objects should overlap so much that either becomes hard to identify

### IV. Label Cards (exactly 8)
Each object gets exactly one compact floating label card.

Card style:
- Rounded rectangle with warm-white base
- Gentle thickness and soft shadow
- Very thin low-contrast border
- Keep cards compact; do not cover object body

Each card must contain exactly these 3 lines (no extra text):
Line 1: [pinyin]
Line 2: 汉字
Line 3: english

The 8 label cards must be:
{card_block}

Text rules:
- Hanzi largest and boldest
- Pinyin and english smaller
- Same color family across three lines on each card
- Ensure high contrast and readability
- ABSOLUTE PROHIBITION: Do NOT place [cite:1], [cite:2], [cite:3], [cite:4], [cite:5], [cite:6], [ref:x], [source:x], superscript numbers, parenthesized numbers, or ANY extra marker

Label placement for scattered objects:
- Labels should float in nearby empty space, not stacked together
- Keep each label close enough for clear mapping
- No two labels should overlap
- Keep labels from covering core object body

### V. Arrows (exactly 8)
Each label card connects to its object with one arrow.

Arrow rules:
- Clean and short, prefer gentle curves
- Arrowhead clearly visible
- Must touch target object body (not nearby background)
- Avoid crossing and ambiguous endpoints
- All arrows should share one consistent accent color family

Arrow precision map:
{arrow_block}

### VI. Branding Badge
- Top-right corner
- One line only: Hi Kiki
- Warm-white rounded badge with subtle depth
- Low visual weight; must not dominate the scene

### VII. Hard Constraints
- Must be exactly 1024x1024 square composition
- No large title/banner
- No duplicated or missing vocabulary objects
- No wrong label-object mapping
- No unrelated decorative objects that distract learning
- No citation markers anywhere in label text
- The scene must feel like a real environment, not a product display board

### VIII. Pre-Final Self-Check
Before final output, verify all checks:
1. DIRTY TEXT SCAN: each card is exactly 3 lines [pinyin] / hanzi / english, no cite/reference artifacts
2. COUNT CHECK: exactly 8 objects, 8 label cards, 8 arrows, no duplicates
3. MAPPING CHECK: every card matches the correct object and every arrow lands on that object body
4. ARROW PRECISION: no floating arrows, no crossing, no ambiguous endpoints
5. VISUAL CHECK: scene realism, object readability, label readability, full 1024x1024 canvas utilization
If any check fails, regenerate the layout before finalizing.
```

---

## 生产记录

- [ ] 生成 PNG：`{card_slug}.png`
- [ ] 生成 JSON：`{card_slug}.json`
- [ ] 通过 `hotspot-preview.html` 叠加校验
- [ ] 同步到运行时 assets
"""


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    card_root = repo_root / "doc" / "card-generation"
    scene_info = card_root / "scene-info"
    scenes_md = card_root / "SCENES.md"

    categories = parse_scenes_md(scenes_md)
    entries = []

    for cat in categories:
        scene_slug = f"scene_{cat['idx']:02d}_{cat['cn']}"
        scene_dir = scene_info / scene_slug
        scene_dir.mkdir(parents=True, exist_ok=True)

        for theme in cat["themes"]:
            card_slug = f"kik_{cat['cn']}_{theme['minor']:02d}_{theme['cn']}"
            card_dir = scene_dir / card_slug
            card_dir.mkdir(parents=True, exist_ok=True)

            md_path = card_dir / f"{card_slug}.md"
            prompt_path = card_dir / "prompt.md"
            json_path = card_dir / f"{card_slug}.json"

            content = render_prompt_md(cat["cn"], theme, card_slug)
            md_path.write_text(content, encoding="utf-8")
            prompt_path.write_text(content, encoding="utf-8")
            if not json_path.exists():
                json_path.write_text("[]\n", encoding="utf-8")

            entries.append(
                {
                    "scene_slug": scene_slug,
                    "card_slug": card_slug,
                    "prompt_md": str(md_path.relative_to(repo_root)).replace("\\\\", "/"),
                    "prompt": str(prompt_path.relative_to(repo_root)).replace("\\\\", "/"),
                    "image": str((card_dir / f"{card_slug}.png").relative_to(repo_root)).replace("\\\\", "/"),
                    "json": str(json_path.relative_to(repo_root)).replace("\\\\", "/"),
                    "source": "SCENES.md",
                }
            )

    index_file = scene_info / "index.json"
    existing = []
    if index_file.exists():
        try:
            existing = json.loads(index_file.read_text(encoding="utf-8"))
        except Exception:
            existing = []

    kept = [e for e in existing if not str(e.get("scene_slug", "")).startswith("scene_")]
    new_index = kept + entries
    index_file.write_text(json.dumps(new_index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"Generated {len(entries)} cards from {len(categories)} scene groups.")


if __name__ == "__main__":
    main()
