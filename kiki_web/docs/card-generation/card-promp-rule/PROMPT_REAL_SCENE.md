# 图片生成 Prompt — 真实场景版

> 适合图书馆学习、厨房认知、公园观察、卧室整理等"强场景"主题。
> 特点：N 个词表物品放在场景中各自真实的位置，而不是集中在一张桌子上。

> 这份文件只负责"真实场景布局骨架"。
> 标签卡片、文字样式、箭头、品牌角标必须引用同目录下的组件规则；生成前自检必须引用检查清单。

---

## 使用说明

1. 打开 Banana (Google AI 图片生成)
2. 先使用本文件确定真实场景布局
3. 再同时引用以下共用规则文件：
	- `components/LABEL_CARDS.md`
	- `components/TEXT_STYLE.md`
	- `components/ARROWS.md`
	- `components/BRANDING_BADGE.md`
4. 生成前执行文末自检清单
5. 将下方 Prompt 模板中的 `[变量]` 替换为实际值
6. 生成图片后进入标注流程

---

## 可替换变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `[SCENE_THEME]` | 场景主题 | 图书馆学习、厨房认知、公园观察 |

---

## 核心理念

**真实场景模式 vs 展示台模式：**

旧模式会把词表物品集中放在一张展示桌上。
本模板将 N 个词表物品放在场景中各自真实的位置——黑板挂墙上、课桌在地面、粉笔在黑板槽里、书包挂椅背。

这样做的教学目的：让小朋友看到"这个东西在真实环境里长什么样、放在哪里"。

---

## 完整 Prompt 模板

```text
**[SCENE_THEME]** (主题): Hi Kiki

### I. Core Setup
- Target age: 3-6 years old
- Format: exact square 1:1
- Resolution: exact 1024x1024 pixels
- View: slightly elevated 3/4 top-front view, looking into the scene
- Style: realistic base with fuller, softer 3D volume enhancement
- Keep real-world proportions and recognizable shapes
- Do not over-inflate objects into balloon or gummy style
- Keep the image realistic first, but make forms feel rounded, solid, and full-bodied rather than thin or flat
- The final image must fully use the square canvas, with no portrait crop, no landscape crop, no inner frame, no extra border, and no unused blank margin caused by layout drift

### Style Master Lock
- Render everything as a premium miniature toy diorama.
- Indoor Montessori learning room style.
- Rounded educational toy objects.
- Soft polished 3D materials.
- Cute but elegant.
- Like Apple-quality preschool product advertisement.
- NOT realistic outdoor photography.

### II. Real Scene Layout

#### A. Scene Environment
Create a **complete, real [SCENE_THEME] environment** as if the viewer is looking into this room or space.
The entire image IS the scene — there is no separate "display layer" or "display table".

Rules:
- The scene must be immediately recognizable as [SCENE_THEME]
- Fill the full 1024×1024 canvas with this environment
- Use natural lighting that matches the scene (warm indoor light, daylight from windows, etc.)
- The scene should feel lived-in and natural, not staged or empty
- Apply a subtle depth-of-field effect — objects in the scene center are sharpest, edges and far background are slightly softer
- No huge title text anywhere
- The scene must include the same two approved recurring sister characters, not newly designed generic girls: Yuki, the 10-year-old older sister with a soft oval face, deep-brown eyes, long flowing pure-black hair and a taller slender school-age body; and Kiki, the 4-year-old younger sister with a full round face, slightly wide-set round deep-brown eyes, soft cheeks, twin warm chestnut-brown pigtails, a shorter toddler body and a larger head-to-body ratio
- The scene must include exactly one cute white kitten
- The two girls and the white kitten must be placed in different depth layers (foreground/midground/background) to reinforce spatial layering
- Preserve the approved face geometry, eye shape and spacing, skin tone, hair color, age, body proportions, signature silhouette and emotional baseline of Yuki and Kiki across every card. At comparable depth, Yuki must be approximately 1.35-1.45 times Kiki's height. Scene-specific expressions must come from the approved expression library and must not redesign either face
- Character-specific hair colors are fixed: Yuki has pure-black hair, Kiki has warm chestnut-brown hair, and Jack has black hair. Lighting may add soft highlights but must never swap or homogenize these base colors

#### B. Object Placement — N vocabulary objects in their real-world positions
Read the vocabulary list from the current card md. Place exactly N target objects in the scene at the positions where they would naturally exist in real life.

**Closed vocabulary contract:**
- The vocabulary list in the current card md is the only allowed learning target set.
- Use exactly those N vocabulary items; do not substitute, rename, simplify, translate differently, merge, split, or add target items.
- Every label card must copy one exact vocabulary row from the md: `[pinyin] / hanzi / english`.
- Decorative scene props may exist only as unlabeled background elements. They must not receive label cards, arrows, or learning-object emphasis.
- If any label or arrow points to an object that is not in the md vocabulary list, the image fails and must be regenerated.

**Placement principle:**
- Each object must sit where it would truly be found in this scene
- Objects should be spread across the full scene space — front, middle, back, left, right
- Do NOT cluster all objects in the center or on one surface
- Each object must be large enough to be clearly recognizable and tappable — minimum ~8% of the image area per object
- Even small real-world objects (chalk, bookmark, glasses) must be rendered at a size that is clearly visible and identifiable in the image
- Objects keep their real-world colors, materials, and forms — the scene palette controls lighting and atmosphere, not the objects themselves

**Depth distribution:**
- Place some objects in the foreground (closest to viewer, larger)
- Place some objects in the middle ground
- Place some objects in the background (farther away, but still clearly visible and identifiable)
- This creates natural depth and makes the scene feel real

### III. Visual Depth & Atmosphere
- The scene should have clear spatial depth — not a flat arrangement
- Use natural perspective, object size variation, and overlap to create a sense of looking into a real space
- Contact shadows, ambient occlusion, and natural light falloff should reinforce depth
- Objects in the foreground are slightly larger and sharper; objects further back are slightly smaller but still fully recognizable
- Make objects feel visually fuller, rounder, and more dimensional, with soft edge highlights and clear volume
- The overall image should feel like a polished, slightly stylized photograph of a real scene — not a flat illustration or a product display

### IV. Shared Component Rules
- Each of the N objects must receive one compact label card and one correct arrow
- The detailed component rules are maintained in separate files:
- Always apply `components/LABEL_CARDS.md` for card body, border, thickness, and shadow rules
- Always apply `components/TEXT_STYLE.md` for the three-line text structure, hierarchy, and scene-matched text color rules
- Always apply `components/ARROWS.md` for arrow color, shape, thickness, curvature, and landing-point rules
- Always apply `components/BRANDING_BADGE.md` for the top-right `Hi Kiki` badge rules

**Label placement for scattered objects:**
- Since objects are spread across the scene (not clustered on a table), label cards should be placed in nearby empty space — not stacked together
- Each label card should float near its object, with a short arrow connecting them
- Labels for foreground objects can sit above or beside the object
- Labels for background objects can sit in front of or beside them
- No two labels should overlap each other
- Keep labels out of the scene's visual center as much as possible to avoid blocking the environment

### V. Hard Constraints
- Must be exactly 1024×1024 square composition
- No giant title or banner
- No unrelated decorative objects
- No extra labeled objects outside the md vocabulary list
- No substitute vocabulary objects, even if visually similar or contextually natural
- No unified recoloring of all objects
- No balloon-like inflation
- No thin, flat, paper-like object rendering
- No cluttered composition
- No portrait poster layout, no horizontal banner layout, and no large empty edge areas
- The scene must feel like a real environment, not a product display board
- No sharp background competing with the key objects
- No incorrect label-object matching
- Every card must keep the fixed character identity baseline: the same approved Yuki face and taller 10-year-old body + the same approved Kiki face, twin pigtails and shorter 4-year-old toddler body + the same approved Mimi white short-haired round face, blue-green eyes, pink nose and bell collar
- **CRITICAL — No citation markers anywhere in the image:** Every label card must contain ONLY three lines: `[pinyin]` / hanzi / english. Do NOT place `[cite:1]`, `[cite:2]`, `[cite:3]`, `[cite:4]`, `[cite:5]`, `[cite:6]`, or any reference artifact on any label card line, especially not in the pinyin line. If cite artifacts appear, the image fails and must be regenerated.

### VI. Pre-Final Check
- Before finalizing, always apply the full quality gate in this file's "Pre-Final Check"
- At minimum, verify closed vocabulary match, exact object count N, exact label count N, exact arrow count N, no duplicates, no wrong pointing, and no dirty meta text
- If any item is duplicated, missing, mislabeled, visually ambiguous, or incorrectly pointed, regenerate the layout before producing the final image
```

---

## 场景化建议

### 图书馆学习 / 晨读时光
- **场景**：一间温馨的教室或图书馆角落
- **物品真实位置**：黑板挂墙上、讲台在前方、课桌在中间、书包挂椅背或放地上、课本摊在桌面、粉笔在黑板槽里、书签夹在书里、眼镜放在桌角
- **⚠️ 注意**：讲台必须有高度和斜面，明显区别于课桌；粉笔箭头必须指粉笔本身不能指黑板

### 厨房认知
- **场景**：一间真实的家庭厨房
- **物品真实位置**：锅放在灶台上、菜板在台面、围裙挂在钩子上、冰箱立在一侧、杯子在台面上
- **⚠️ 注意**：每个物品在厨房的自然位置

### 公园散步
- **场景**：一个真实的公园
- **物品真实位置**：长椅在路旁、喷泉在广场中央、风筝在天上、鸽子在地面、滑板在路面
- **⚠️ 注意**：远近层次要自然，天上和地面都有物品

### 超市购物
- **场景**：一间真实的超市内部
- **物品真实位置**：货架在两侧、购物车在通道、收银台在尽头、零食在货架上
- **⚠️ 注意**：物品在超市不同区域分散
