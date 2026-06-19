# 球迷广场 — 组件化学习卡片 Prompt

> 分类：世界足球节
> 主题序号：6.5
> 场景文件：kik_世界足球节_05_球迷广场.png
> 热区文件：kik_世界足球节_05_球迷广场.json
> 生成方式：card-promp-rule 组件化合成

---

```text
**球迷广场** (主题): Hi Kiki

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
Create a complete child-friendly soccer fan square inside a cozy Montessori-style play world.

Scene preset rules:
- The children must be part of the fan square: wearing fan items, waving a small flag, or looking at the big screen.
- Do not show FIFA marks, official World Cup logos, real national team crests, real player faces, or sponsor boards.
- Keep the square bright and safe, not crowded or chaotic.

Theme-specific scene elements:
- Yuki wears a fan vest and points toward the big screen.
- Kiki holds a small flag and wears a wristband.
- Mimi the white cat sits beside a backpack near a small sticker stand.
- Keep big screen, hat, horn, ticket, sticker, wristband, vest, and small flag separated.

Scene atmosphere:
- Cheerful, public, festive, safe, colorful, and positive
- Color palette suggestion: 广场白、天空蓝、小旗红、气球黄
- No giant title text anywhere

Depth distribution:
- Foreground: ticket, wristband, backpack area
- Middle ground: children, hat, horn, small flag, vest
- Background: big screen and sticker stand

### III. Character Cast
The scene must include exactly two cute sister girls and exactly one cute white kitten:
1. Yuki: 10-year-old elder sister with long loose hair, wearing a fan vest.
2. Kiki: 4-year-old younger sister with two ponytails, waving a small flag.
3. Mimi: one cute white cat, clearly visible beside the backpack.

Character rules:
- Yuki and Kiki are active child fans in the square.
- Do not add Jack or other people in this card.
- Characters must not cover target objects, label cards, or arrow landing points.

### IV. 8 Target Vocabulary Objects
- [dà píng] / 大屏 / Big Screen (/bɪɡ skriːn/)
- [mào zi] / 帽子 / Hat (/hæt/)
- [lǎ ba] / 喇叭 / Horn (/hɔːrn/)
- [piào gēn] / 票根 / Ticket Stub (/ˈtɪkɪt stʌb/)
- [tiē zhǐ] / 贴纸 / Sticker (/ˈstɪkər/)
- [shǒu huán] / 手环 / Wristband (/ˈrɪstbænd/)
- [bèi xīn] / 背心 / Vest (/vɛst/)
- [xiǎo qí] / 小旗 / Small Flag (/smɔːl flæɡ/)

Object placement map:
1. 大屏 — large outdoor screen showing generic soccer colors only.
2. 帽子 — child fan hat placed on a bench or worn with label landing on hat body.
3. 喇叭 — toy cheering horn in the middle ground.
4. 票根 — small ticket stub on a low table, enlarged enough to see.
5. 贴纸 — small sheet of generic soccer festival stickers on a stand, no official logos.
6. 手环 — colorful wristband on Kiki's wrist or displayed nearby.
7. 背心 — fan vest worn by Yuki or hung on a stand.
8. 小旗 — small handheld flag, separate from big screen and ticket.

Critical placement rules:
- CLOSED VOCABULARY SET: The vocabulary list in section IV is the only allowed learning target set.
- Exactly 8 target objects, 8 label cards, 8 arrows.
- Extra scene props may appear only as unlabeled background elements.

Easy-confusion protection:
- 贴纸 and 票根 must be distinct: sticker sheet has multiple small shapes; ticket stub is one flat paper slip.
- 小旗 and 票根 must not merge: flag has pole; ticket is flat paper.
- 帽子 and 背心 must be visually separate wearable items.
- 大屏 must not show official logos or real teams.

### V. Label Cards
Each object gets exactly one compact floating label card.
Each card must contain exactly these 3 lines and no extra text:
Line 1: [pinyin]
Line 2: 汉字
Line 3: english

The 8 label cards must be:
- [dà píng] / 大屏 / Big Screen
- [mào zi] / 帽子 / Hat
- [lǎ ba] / 喇叭 / Horn
- [piào gēn] / 票根 / Ticket Stub
- [tiē zhǐ] / 贴纸 / Sticker
- [shǒu huán] / 手环 / Wristband
- [bèi xīn] / 背心 / Vest
- [xiǎo qí] / 小旗 / Small Flag

### VI. Arrows
Each label card connects to its object with exactly one arrow.
Arrow precision map:
- 大屏 arrow -> lands on the big screen body.
- 帽子 arrow -> lands on the hat body.
- 喇叭 arrow -> lands on the horn body.
- 票根 arrow -> lands on the ticket stub body.
- 贴纸 arrow -> lands on the sticker sheet body.
- 手环 arrow -> lands on the wristband body.
- 背心 arrow -> lands on the vest body.
- 小旗 arrow -> lands on the small flag fabric.

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

- [ ] 生成 PNG：`kik_世界足球节_05_球迷广场.png`
- [ ] 生成 JSON：`kik_世界足球节_05_球迷广场.json`
- [ ] 通过 `hotspot-preview.html` 叠加校验
- [ ] 同步到运行时 assets
