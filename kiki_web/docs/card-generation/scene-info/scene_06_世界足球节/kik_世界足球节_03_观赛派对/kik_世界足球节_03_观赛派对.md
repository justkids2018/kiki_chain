# 观赛派对 — 组件化学习卡片 Prompt

> 分类：世界足球节
> 主题序号：6.3
> 场景文件：kik_世界足球节_03_观赛派对.png
> 热区文件：kik_世界足球节_03_观赛派对.json
> 生成方式：card-promp-rule 组件化合成

---

```text
**观赛派对** (主题): Hi Kiki

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
Create a complete family soccer watching party scene inside a cozy Montessori-style play world.

Scene preset rules:
- The children must be part of the viewing party: cheering, holding a flag, sitting on the sofa, or using the remote.
- Do not show FIFA marks, official World Cup logos, real national team crests, real player faces, or sponsor boards.
- The screen may show generic toy soccer colors only, not real teams.

Theme-specific scene elements:
- Yuki sits on the sofa with a scarf and remote control.
- Kiki waves a small flag near the TV.
- Mimi the white cat sits safely near the popcorn bowl.
- Keep TV, sofa, flag, scarf, popcorn, drink, remote control, and poster separated.

Scene atmosphere:
- Warm, cozy, cheerful, festive, family-friendly, and positive
- Color palette suggestion: 客厅暖木、电视蓝、围巾红、爆米花黄
- No giant title text anywhere

Depth distribution:
- Foreground: popcorn, drink, remote control
- Middle ground: sofa, scarf, children
- Background: TV and poster

### III. Character Cast
The scene must include exactly two cute sister girls and exactly one cute white kitten:
1. Yuki: 10-year-old elder sister with long loose hair, sitting on the sofa as a child fan.
2. Kiki: 4-year-old younger sister with two ponytails, waving a small flag.
3. Mimi: one cute white cat, clearly visible near the snack area.

Character rules:
- Yuki and Kiki are active child fans inside the scene, not background decoration.
- Do not add Jack or other people in this card.
- Characters must not cover target objects, label cards, or arrow landing points.

### IV. 8 Target Vocabulary Objects
- [diàn shì] / 电视 / TV (/ˌtiː ˈviː/)
- [shā fā] / 沙发 / Sofa (/ˈsoʊfə/)
- [qí zi] / 旗子 / Flag (/flæɡ/)
- [wéi jīn] / 围巾 / Scarf (/skɑːrf/)
- [bào mǐ huā] / 爆米花 / Popcorn (/ˈpɑːpkɔːrn/)
- [yǐn liào] / 饮料 / Drink (/drɪŋk/)
- [yáo kòng qì] / 遥控器 / Remote (/rɪˈmoʊt/)
- [hǎi bào] / 海报 / Poster (/ˈpoʊstər/)

Object placement map:
1. 电视 — large toy TV screen in the background showing generic soccer colors only.
2. 沙发 — soft small sofa in the middle ground.
3. 旗子 — small handheld flag in Kiki's hand or beside her.
4. 围巾 — fan scarf draped on sofa or held by Yuki.
5. 爆米花 — popcorn bowl in the foreground.
6. 饮料 — child-safe drink cup with straw beside popcorn.
7. 遥控器 — remote control on the sofa arm or low table.
8. 海报 — generic soccer festival poster on the wall, no official logos.

Critical placement rules:
- CLOSED VOCABULARY SET: The vocabulary list in section IV is the only allowed learning target set.
- Exactly 8 target objects, 8 label cards, 8 arrows.
- Extra scene props may appear only as unlabeled background elements.

Easy-confusion protection:
- 电视 and 海报 must be distinct: TV is a screen; poster is flat paper on wall.
- 旗子 and 围巾 must not merge: flag has a small pole; scarf is long fabric.
- 饮料 and 遥控器 must be separated on the table.

### V. Label Cards
Each object gets exactly one compact floating label card.
Each card must contain exactly these 3 lines and no extra text:
Line 1: [pinyin]
Line 2: 汉字
Line 3: english

The 8 label cards must be:
- [diàn shì] / 电视 / TV
- [shā fā] / 沙发 / Sofa
- [qí zi] / 旗子 / Flag
- [wéi jīn] / 围巾 / Scarf
- [bào mǐ huā] / 爆米花 / Popcorn
- [yǐn liào] / 饮料 / Drink
- [yáo kòng qì] / 遥控器 / Remote
- [hǎi bào] / 海报 / Poster

### VI. Arrows
Each label card connects to its object with exactly one arrow.
Arrow precision map:
- 电视 arrow -> lands on the TV body.
- 沙发 arrow -> lands on the sofa body.
- 旗子 arrow -> lands on the flag fabric.
- 围巾 arrow -> lands on the scarf body.
- 爆米花 arrow -> lands on the popcorn bowl.
- 饮料 arrow -> lands on the drink cup.
- 遥控器 arrow -> lands on the remote body.
- 海报 arrow -> lands on the poster body.

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

- [ ] 生成 PNG：`kik_世界足球节_03_观赛派对.png`
- [ ] 生成 JSON：`kik_世界足球节_03_观赛派对.json`
- [ ] 通过 `hotspot-preview.html` 叠加校验
- [ ] 同步到运行时 assets
