# 颁奖时刻 — 组件化学习卡片 Prompt

> 分类：世界足球节
> 主题序号：6.4
> 场景文件：kik_世界足球节_04_颁奖时刻.png
> 热区文件：kik_世界足球节_04_颁奖时刻.json
> 生成方式：card-promp-rule 组件化合成

---

```text
**颁奖时刻** (主题): Hi Kiki

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
Create a complete children's soccer award moment inside a cozy Montessori-style play world.

Scene preset rules:
- The children must be part of the award ceremony: receiving a medal, holding flowers, or standing near the podium.
- Do not show FIFA marks, official World Cup logos, real national team crests, real player faces, or sponsor boards.
- The scene is joyful and gentle, not an adult professional ceremony.

Theme-specific scene elements:
- Yuki gently gives Kiki a medal beside a small podium.
- Kiki stands proudly near the trophy and bouquet.
- Mimi the white cat sits beside the ribbon basket.
- Keep trophy, medal, podium, bouquet, ribbon, camera, microphone, and team badge separated.

Scene atmosphere:
- Joyful, bright, friendly, ceremonial, child-safe, and positive
- Color palette suggestion: 奖杯金、草坪绿、彩带红、晴空蓝
- No giant title text anywhere

Depth distribution:
- Foreground: trophy, medal, ribbon
- Middle ground: podium, bouquet, children
- Background: camera, microphone, team badge

### III. Character Cast
The scene must include exactly two cute sister girls and exactly one cute white kitten:
1. Yuki: 10-year-old elder sister with long loose hair, giving or holding the medal.
2. Kiki: 4-year-old younger sister with two ponytails, standing proudly on or near the podium.
3. Mimi: one cute white cat, clearly visible near the ribbon basket.

Character rules:
- Yuki and Kiki are active participants in the award moment.
- Do not add Jack or other people in this card.
- Characters must not cover target objects, label cards, or arrow landing points.

### IV. 8 Target Vocabulary Objects
- [jiǎng bēi] / 奖杯 / Trophy (/ˈtroʊfi/)
- [jiǎng pái] / 奖牌 / Medal (/ˈmɛdəl/)
- [lǐng jiǎng tái] / 领奖台 / Podium (/ˈpoʊdiəm/)
- [huā shù] / 花束 / Bouquet (/buːˈkeɪ/)
- [cǎi dài] / 彩带 / Ribbon (/ˈrɪbən/)
- [xiàng jī] / 相机 / Camera (/ˈkæmərə/)
- [mài kè fēng] / 麦克风 / Microphone (/ˈmaɪkrəfoʊn/)
- [duì huī] / 队徽 / Team Badge (/tiːm bædʒ/)

Object placement map:
1. 奖杯 — shiny toy trophy in the foreground.
2. 奖牌 — round medal with ribbon, held by Yuki or placed on a cushion.
3. 领奖台 — small three-step podium in the middle ground.
4. 花束 — colorful bouquet in Kiki's hand or beside podium.
5. 彩带 — curled celebration ribbon on the floor or basket.
6. 相机 — small toy camera on a stand, separate from microphone.
7. 麦克风 — microphone on a short stand near the podium.
8. 队徽 — generic child-made team badge on a small round board, with no real logo.

Critical placement rules:
- CLOSED VOCABULARY SET: The vocabulary list in section IV is the only allowed learning target set.
- Exactly 8 target objects, 8 label cards, 8 arrows.
- Extra scene props may appear only as unlabeled background elements.

Easy-confusion protection:
- 奖杯 and 奖牌 must be visually distinct: trophy is cup-shaped; medal is round and flat.
- 花束 and 彩带 must not merge: bouquet has flowers; ribbon is curled strip.
- 相机 and 麦克风 must be separated on different stands.
- 队徽 must be generic and must not show official team, country, FIFA, or World Cup marks.

### V. Label Cards
Each object gets exactly one compact floating label card.
Each card must contain exactly these 3 lines and no extra text:
Line 1: [pinyin]
Line 2: 汉字
Line 3: english

The 8 label cards must be:
- [jiǎng bēi] / 奖杯 / Trophy
- [jiǎng pái] / 奖牌 / Medal
- [lǐng jiǎng tái] / 领奖台 / Podium
- [huā shù] / 花束 / Bouquet
- [cǎi dài] / 彩带 / Ribbon
- [xiàng jī] / 相机 / Camera
- [mài kè fēng] / 麦克风 / Microphone
- [duì huī] / 队徽 / Team Badge

### VI. Arrows
Each label card connects to its object with exactly one arrow.
Arrow precision map:
- 奖杯 arrow -> lands on the trophy body.
- 奖牌 arrow -> lands on the medal body.
- 领奖台 arrow -> lands on the podium body.
- 花束 arrow -> lands on the bouquet body.
- 彩带 arrow -> lands on the ribbon body.
- 相机 arrow -> lands on the camera body.
- 麦克风 arrow -> lands on the microphone body.
- 队徽 arrow -> lands on the team badge board.

### VII. Branding Badge
- Top-right corner
- One line only: Hi Kiki

### VIII. Hard Constraints
- Must be exactly 1024x1024 square composition.
- No official FIFA / World Cup logos, no real national crests, no real player likenesses.
- Every card must keep the fixed character baseline for this card: Yuki + Kiki + Mimi.

### IX. Pre-Final Self-Check
1. DIRTY TEXT SCAN
2. COUNT CHECK: exactly 8 objects, 8 label cards, 8 arrows
3. MAPPING CHECK
4. ARROW PRECISION
5. VISUAL CHECK
```

---

## 生产记录

- [ ] 生成 PNG：`kik_世界足球节_04_颁奖时刻.png`
- [ ] 生成 JSON：`kik_世界足球节_04_颁奖时刻.json`
- [ ] 通过 `hotspot-preview.html` 叠加校验
- [ ] 同步到运行时 assets
