# 字母认知场景 - 分类卡片封面图生成 Prompt（RULES 对齐版）

---

## 📋 基础规格

- 用途: 一级场景分类卡片封面图
- 场景分类: 字母认知 (Letter Recognition Scenes)
- 输出格式: PNG
- 画幅: 7:9 竖版
- 推荐分辨率: 700 x 900 (@2x)
- 可选分辨率: 350 x 450 (@1x), 1050 x 1350 (@3x)
- 色深: 24-bit RGB
- 适用年龄: 3-6 岁

---

## 🔒 借鉴 RULES.md 的硬约束（封面版）

- 必须是完整字母学习场景，不是字母卡片拼贴。
- 必须具备前景 / 中景 / 后景分层。
- 必须固定出现 2 个可爱小女孩（10 岁姐姐 + 4 岁双马尾妹妹）。
- 必须固定出现 1 只可爱白色小猫。
- 三个角色必须分布在不同景深层。
- 禁止大标题文字、引用标记、脚注标记。
- 禁止内边框和明显空白边。

---

## 🎨 完整生成 Prompt

```text
Create a premium 3D rendered category cover for "Letter Recognition Scenes" for children aged 3-6.

Output:
- PNG, portrait 7:9
- Preferred 700x900 px (@2x)
- Full canvas usage

Scene goal:
Build a complete letter-learning environment with playful alphabet objects (3D letters and matching phonics props) in a real educational space, not a flat poster board.

Mandatory character baseline:
- Exactly two cute sister girls: one 10-year-old older sister and one 4-year-old younger sister with two ponytails
- Exactly one cute white kitten
- Place the three characters across foreground / midground / background separately

Depth and composition:
- Foreground: one prominent letter or phonics prop
- Midground: main alphabet learning cluster (most readable)
- Background: soft classroom anchors (shelf, board, wall shapes)
- Keep composition neat, light, and child-readable

Visual direction:
- Soft bright palette (pastel blue, mint, peach, light yellow)
- Rounded letter forms, polished 3D materials
- Cute educational diorama aesthetic
- Soft daylight and contact shadows

Prohibitions:
- No [cite:x], [ref:x], [source:x] annotation artifacts
- No giant title text
- No citation-like markers [cite:x] / [ref:x] / [source:x]
- No replacing required sister+kitten baseline
- No over-complex scene clutter

Quality target:
Gentle, clear, and playful letter category cover.
```

---

## ✅ 出图前检查

- [ ] 7:9 竖版、分辨率正确
- [ ] 字母学习场景完整
- [ ] 前中后景清晰
- [ ] 姐妹 + 白猫完整出现
- [ ] 三角色分层放置
- [ ] 无大标题与脏标记
- [ ] 字母元素清晰可认
