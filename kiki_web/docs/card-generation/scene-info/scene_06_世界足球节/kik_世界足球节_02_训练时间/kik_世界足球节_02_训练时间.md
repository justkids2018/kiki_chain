# 训练时间 — 组件化学习卡片 Prompt

> 分类：世界足球节
> 主题序号：6.2
> 场景文件：kik_世界足球节_02_训练时间.png
> 热区文件：kik_世界足球节_02_训练时间.json
> 生成方式：card-promp-rule 组件化合成

---

```text
**训练时间** (主题): Hi Kiki

### I. Canvas & Style Lock
- Target age: 3-6 years old
- Format: exact square 1:1
- Resolution: exact 1024x1024 pixels
- View: slightly elevated 3/4 top-front view
- The final image must fully use the square canvas, with no portrait crop, no landscape crop, no inner frame, no extra border, and no unused blank margin
- Render everything as a premium miniature toy diorama
- Indoor Montessori learning room style
- Rounded educational toy objects
- Soft polished 3D materials
- Warm contact shadows and soft highlights
- Cute but elegant
- Like Apple-quality preschool product advertisement
- NOT photorealistic documentary
- NOT live-action people

### II. Scene Background
Create a complete children's soccer training scene inside a cozy Montessori-style play world.

Scene preset rules:
- The children must be active participants in a friendly training course.
- Do not show FIFA marks, official World Cup logos, real national team crests, real player faces, or sponsor boards.
- Training objects must be separated and easy to tap.

Theme-specific scene elements:
- Jack leads a playful warm-up path through cones and a low hurdle.
- Yuki holds a stopwatch and encourages Kiki.
- Kiki carries a small water bottle after training.
- Mimi the white cat sits on a soft mat beside the training bag.

Scene atmosphere:
- Bright, healthy, energetic, organized, friendly, and positive
- Color palette suggestion: 草坪绿、训练橙、天空蓝、清爽白
- No giant title text anywhere

Depth distribution:
- Foreground: cone, water bottle, towel
- Middle ground: hurdle, stopwatch, training clothes, soft mat
- Background: backpack and field markers

### III. Character Cast
The scene must include exactly three children and exactly one cute white kitten:
1. Yuki: 10-year-old elder sister with long loose hair, holding or pointing to the stopwatch.
2. Kiki: 4-year-old younger sister with two ponytails, practicing carefully.
3. Jack: 7-year-old cheerful neighbor boy, yellow/orange sports shirt, shorts, white sports shoes, and visible baseball cap.
4. Mimi: one cute white cat, clearly visible near the soft mat.

Character rules:
- Characters must look like they are training together.
- Total people count is exactly 3; do not add extra players.
- Characters must not cover target objects, label cards, or arrow landing points.

### IV. 8 Target Vocabulary Objects
- [biāo zhì tǒng] / 标志桶 / Cone (/koʊn/)
- [kuà lán] / 跨栏 / Hurdle (/ˈhɜːrdəl/)
- [miǎo biǎo] / 秒表 / Stopwatch (/ˈstɑːpwɑːtʃ/)
- [shuǐ píng] / 水瓶 / Water Bottle (/ˈwɔːtər ˈbɑːtəl/)
- [máo jīn] / 毛巾 / Towel (/ˈtaʊəl/)
- [bēi bāo] / 背包 / Backpack (/ˈbækpæk/)
- [xùn liàn fú] / 训练服 / Training Suit (/ˈtreɪnɪŋ suːt/)
- [ruǎn diàn] / 软垫 / Soft Mat (/sɔːft mæt/)

Object placement map:
1. 标志桶 — orange cone in the foreground on the training path.
2. 跨栏 — low child-safe hurdle in the middle ground.
3. 秒表 — stopwatch in Yuki's hand or on a small stand, large enough to see.
4. 水瓶 — clear water bottle beside Kiki, separate from towel.
5. 毛巾 — folded towel on a bench or mat.
6. 背包 — sports backpack at the edge of the training area.
7. 训练服 — folded training suit or small jacket on a bench.
8. 软垫 — soft exercise mat on the ground near Mimi.

Critical placement rules:
- CLOSED VOCABULARY SET: The vocabulary list in section IV is the only allowed learning target set.
- Exactly 8 target objects, 8 label cards, 8 arrows.
- Extra scene props may appear only as unlabeled background elements.

Easy-confusion protection:
- 标志桶 and 水瓶 must be visually distinct: cone is orange and tapered; bottle is clear and cylindrical.
- 毛巾 and 训练服 must not be stacked together.
- 跨栏 must be a low hurdle, not a goal frame.
- 软垫 must be flat and rectangular, not a towel.

### V. Label Cards
Each object gets exactly one compact floating label card.
Each card must contain exactly these 3 lines and no extra text:
Line 1: [pinyin]
Line 2: 汉字
Line 3: english

The 8 label cards must be:
- [biāo zhì tǒng] / 标志桶 / Cone
- [kuà lán] / 跨栏 / Hurdle
- [miǎo biǎo] / 秒表 / Stopwatch
- [shuǐ píng] / 水瓶 / Water Bottle
- [máo jīn] / 毛巾 / Towel
- [bēi bāo] / 背包 / Backpack
- [xùn liàn fú] / 训练服 / Training Suit
- [ruǎn diàn] / 软垫 / Soft Mat

### VI. Arrows
Each label card connects to its object with exactly one arrow.
Arrow precision map:
- 标志桶 arrow -> lands on the cone body.
- 跨栏 arrow -> lands on the hurdle bar.
- 秒表 arrow -> lands on the stopwatch body.
- 水瓶 arrow -> lands on the water bottle body.
- 毛巾 arrow -> lands on the towel body.
- 背包 arrow -> lands on the backpack body.
- 训练服 arrow -> lands on the training suit fabric.
- 软垫 arrow -> lands on the soft mat body.

### VII. Branding Badge
- Top-right corner
- One line only: Hi Kiki

### VIII. Hard Constraints
- Must be exactly 1024x1024 square composition.
- No official FIFA / World Cup logos, no real national crests, no real player likenesses.
- Every card must keep the fixed character baseline for this card: Yuki + Kiki + Jack + Mimi.

### IX. Pre-Final Self-Check
1. DIRTY TEXT SCAN
2. COUNT CHECK: exactly 8 objects, 8 label cards, 8 arrows
3. MAPPING CHECK
4. ARROW PRECISION
5. VISUAL CHECK
```

---

## 生产记录

- [ ] 生成 PNG：`kik_世界足球节_02_训练时间.png`
- [ ] 生成 JSON：`kik_世界足球节_02_训练时间.json`
- [ ] 通过 `hotspot-preview.html` 叠加校验
- [ ] 同步到运行时 assets
