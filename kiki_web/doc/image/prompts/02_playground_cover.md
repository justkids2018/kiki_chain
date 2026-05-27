# 游乐场景 - 分类卡片封面图生成 Prompt（RULES 对齐版）

---

## 📋 基础规格

- 用途: 一级场景分类卡片封面图
- 场景分类: 游乐场景 (Playground Scenes)
- 输出格式: PNG
- 画幅: 7:9 竖版
- 推荐分辨率: 700 x 900 (@2x)
- 可选分辨率: 350 x 450 (@1x), 1050 x 1350 (@3x)
- 色深: 24-bit RGB
- 适用年龄: 3-6 岁

---

## 🔒 借鉴 RULES.md 的硬约束（封面版）

- 必须是完整游乐场景，不是玩具陈列图。
- 必须具备前景 / 中景 / 后景分层。
- 必须固定出现 2 个可爱小女孩（10 岁姐姐 + 4 岁双马尾妹妹）。
- 必须固定出现 1 只可爱白色小猫。
- 三个角色必须分布在不同景深层。
- 禁止大标题文字、引用标记、脚注标记。
- 禁止空白边、内边框、主体裁切。

---

## 🎨 完整生成 Prompt

```text
Create a premium 3D rendered category cover for "Playground Scenes" for children aged 3-6.

Output:
- PNG, portrait 7:9
- Preferred 700x900 px (@2x)
- Full canvas usage, no blank margins

Scene goal:
Build a complete playful amusement environment with recognizable playground energy (slides, small ride elements, colorful path, playful props), not a product display shelf.

Mandatory character baseline:
- Exactly two cute sister girls: one 10-year-old older sister and one 4-year-old younger sister with two ponytails
- Exactly one cute white kitten
- Place them across foreground / midground / background separately

Depth and composition:
- Foreground: one large playful prop (e.g., ball pit edge, mini slide step, or toy wheel)
- Midground: main playground cluster with strongest focus
- Background: softened park or funfair anchors (fence, trees, sky accents)
- Keep motion feeling lively but layout readable

Visual direction:
- Bright energetic palette (sunny yellow, cyan, grass green, coral red)
- Rounded toy-like geometry, polished 3D finish
- Child-safe, cheerful, premium diorama look
- Soft daylight and clean shadows

Prohibitions:
- No big text title
- No [cite:x] / [ref:x] / [source:x] or similar marks
- No replacing required sister+kitten baseline
- No dark, aggressive, or chaotic clutter

Quality target:
Fun, vibrant, easy to identify as playground category cover.
```

---

## ✅ 出图前检查

- [ ] 7:9 竖版、分辨率正确
- [ ] 完整游乐环境
- [ ] 前中后景明确
- [ ] 姐妹 + 白猫均出现
- [ ] 三角色分层放置
- [ ] 无大标题与脏标记
- [ ] 色彩活泼但不杂乱
