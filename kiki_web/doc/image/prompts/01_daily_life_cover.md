# 日常生活场景 - 分类卡片封面图生成 Prompt（RULES 对齐版）

---

## 📋 基础规格

- 用途: 一级场景分类卡片封面图
- 场景分类: 日常生活 (Daily Life Scenes)
- 输出格式: PNG
- 画幅: 7:9 竖版
- 推荐分辨率: 700 x 900 (@2x)
- 可选分辨率: 350 x 450 (@1x), 1050 x 1350 (@3x)
- 色深: 24-bit RGB
- 适用年龄: 3-6 岁

---

## 🔒 借鉴 RULES.md 的硬约束（封面版）

- 必须是完整页面场景，不是物体陈列板。
- 必须具备前景 / 中景 / 后景分层。
- 必须固定出现 2 个可爱小女孩（10 岁姐姐 + 4 岁双马尾妹妹）。
- 必须固定出现 1 只可爱白色小猫。
- 三个角色必须分布在不同景深层，强化空间感。
- 禁止大标题文字、引用标记、脚注标记。
- 禁止画面裁切导致主体缺失或边缘留白。

---

## 🎨 完整生成 Prompt

```text
Create a premium 3D rendered category cover for "Daily Life Scenes" for children aged 3-6.

Output:
- PNG, portrait 7:9
- Preferred 700x900 px (@2x), keep safe margins
- Full canvas usage, no inner frame, no blank border

Scene goal:
Build a complete warm home-life environment (not a display board), such as a cozy corner combining living room, kitchen hints, and child bedroom elements.

Mandatory character baseline:
- Exactly two cute sister girls: one 10-year-old older sister and one 4-year-old younger sister with two ponytails
- Exactly one cute white kitten
- Place the older sister, younger sister, and kitten in different depth layers (foreground / midground / background)

Depth and composition:
- Foreground: one large readable daily-life object (for example pillow basket, toy cup, or slippers)
- Midground: core home scene objects (small table, lamp, storage box, soft sofa edge)
- Background: light interior anchors (window, curtain, shelf silhouette)
- Keep center readable, edges softly simplified

Visual direction:
- Warm, bright, homey palette (cream, light wood, warm yellow, soft coral)
- Rounded, solid, child-safe forms
- Premium miniature toy diorama feeling
- Gentle natural light + soft contact shadows

Prohibitions:
- No big text title
- No citation-like marks such as [cite:x], [ref:x], [source:x]
- No dark horror mood or messy clutter
- No replacing required sister+kitten baseline

Quality target:
Friendly, clean, warm, instantly recognizable as daily life category cover.
```

---

## ✅ 出图前检查

- [ ] 7:9 竖版、分辨率正确
- [ ] 完整场景而非陈列台
- [ ] 有明确前中后景
- [ ] 10 岁姐姐、4 岁双马尾妹妹、白色小猫全部出现
- [ ] 三个角色在不同景深层
- [ ] 无大标题与脏标记
- [ ] 主体清晰、儿童友好
