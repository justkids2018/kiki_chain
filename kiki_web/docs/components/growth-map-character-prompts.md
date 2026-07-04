# 学习地图角色素材 Prompt

## 目的

为成长地图页面生成可复用的独立角色素材。角色需要像学习卡片世界里的原生角色，而不是从学习卡片截图裁切出来。

## 共同生成规则

- 用途：移动端学习地图装饰角色。
- 风格：premium miniature toy diorama，圆润、柔和、高质感 3D 儿童学习玩具风。
- 背景：先生成纯色 `#00ff00` chroma-key 背景，再本地转透明 PNG。
- 构图：单个角色，全身可见，留足边距，不能裁切。
- 禁止：文字、Logo、标签卡、箭头、边框、截图感、真人摄影感、额外角色。
- 透明处理命令：

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py" \
  --input <source_chroma.png> \
  --out <final_transparent.png> \
  --auto-key border \
  --soft-matte \
  --transparent-threshold 18 \
  --opaque-threshold 220 \
  --despill \
  --edge-contract 1
```

## Yuki 地图角色 Prompt

```text
Use case: stylized-concept
Asset type: mobile app growth-map character sprite, final will be cut out with transparent background
Primary request: Create a single full-body 3D character asset of Yuki for a children's learning map. Generate on a perfectly flat solid #00ff00 chroma-key background for background removal.
Subject: Yuki, the 10-year-old elder sister from a children's learning card world. She has long flowing dark-brown hair worn down, warm big eyes, soft round childlike face, gentle elder-sister expression. She is sitting naturally on the ground reading a small picture book, angled slightly 3/4 front view, friendly and calm.
Style/medium: premium miniature toy diorama, rounded soft 3D clay / polished toy render, same style as high-quality children's Montessori learning cards, warm tactile materials, not photorealistic, not flat illustration.
Composition/framing: full body visible with generous padding, centered single character only, no crop, no border, no label card, no text, no logo. Slight top-front 3/4 view suitable for placing into a vertical forest learning map.
Lighting/mood: warm soft studio lighting, gentle highlights, cheerful, clean.
Materials/textures: soft hair strands but toy-like, fabric cardigan or simple soft outfit, rounded shoes, child-safe toy texture.
Constraints: background must be one uniform #00ff00 with no shadows, gradients, texture, floor plane, reflections, or lighting variation. No cast shadow, no contact shadow, no text, no watermark. Do not use #00ff00 anywhere in the subject. Only Yuki, no other characters, no cat.
Avoid: screenshot look, rectangular card, label arrows, Chinese or English text, realistic photograph, adult features, twin pigtails, extra people.
```

## Kiki 地图角色 Prompt

```text
Use case: stylized-concept
Asset type: mobile app growth-map character sprite, final will be cut out with transparent background
Primary request: Create a single full-body 3D character asset of Kiki for a children's learning map. Generate on a perfectly flat solid #00ff00 chroma-key background for background removal.
Subject: Kiki, the 4-year-old little sister from a children's learning card world. She has two dark-brown twin pigtails with small pink hair ties, round toddler face, big warm eyes, playful happy expression. She is sitting on the ground playing with a colorful string game between her hands, angled slightly 3/4 front view, lively but gentle.
Style/medium: premium miniature toy diorama, rounded soft 3D clay / polished toy render, same style as high-quality children's Montessori learning cards, warm tactile materials, not photorealistic, not flat illustration.
Composition/framing: full body visible with generous padding, centered single character only, no crop, no border, no label card, no text, no logo. Slight top-front 3/4 view suitable for placing into a vertical forest learning map.
Lighting/mood: warm soft studio lighting, cheerful, innocent, clean.
Materials/textures: soft hair, pink sweater or pink dress-like child outfit, rounded shoes, child-safe toy texture, colorful string toy.
Constraints: background must be one uniform #00ff00 with no shadows, gradients, texture, floor plane, reflections, or lighting variation. No cast shadow, no contact shadow, no text, no watermark. Do not use #00ff00 anywhere in the subject. Only Kiki, no other characters, no cat.
Avoid: screenshot look, rectangular card, label arrows, Chinese or English text, realistic photograph, adult features, long loose hair, single ponytail, extra people.
```

## Mimi 地图角色 Prompt

```text
Use case: stylized-concept
Asset type: mobile app growth-map pet character sprite, final will be cut out with transparent background
Primary request: Create a single full-body 3D pet asset of Mimi for a children's learning map. Generate on a perfectly flat solid #00ff00 chroma-key background for background removal.
Subject: Mimi the white cat, the recurring main pet from a children's learning card world. Cute white short-haired kitten, big clear eyes, small pink nose, soft rounded face, wearing a tiny warm-colored bell collar. Mimi is sitting and looking upward curiously, as if watching Yuki and Kiki learn nearby.
Style/medium: premium miniature toy diorama, rounded soft 3D clay / polished toy render, same style as high-quality children's Montessori learning cards, warm tactile materials, not photorealistic, not flat illustration.
Composition/framing: full body visible with generous padding, centered single pet only, no crop, no border, no label card, no text, no logo. Slight top-front 3/4 view suitable for placing into a vertical forest learning map.
Lighting/mood: warm soft studio lighting, adorable, gentle, clean.
Materials/textures: fluffy but toy-like white fur, soft rounded paws, polished toy-diorama quality.
Constraints: background must be one uniform #00ff00 with no shadows, gradients, texture, floor plane, reflections, or lighting variation. No cast shadow, no contact shadow, no text, no watermark. Do not use #00ff00 anywhere in the subject. Only Mimi, no people, no other animals.
Avoid: screenshot look, rectangular card, label arrows, Chinese or English text, realistic photograph, colored cat, scary expression, standing humanoid cat, clothes on cat.
```

最后更新：2026-06-30
