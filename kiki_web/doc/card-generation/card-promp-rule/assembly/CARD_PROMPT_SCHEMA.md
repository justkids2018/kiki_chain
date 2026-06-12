# 单卡 Prompt 变量协议

每张卡片只维护变量，公共视觉规则由 `card-promp-rule/components/` 和 `scene-presets/` 注入。

## 必填变量

- `category`：一级场景分类，例如 `日常生活`。
- `scene_index`：主题序号，例如 `3.1`。
- `card_name`：卡片名，例如 `kik_日常生活_01_超市购物`。
- `theme`：画面主题，例如 `超市购物`。
- `theme_english`：英文主题，例如 `Supermarket Shopping`。
- `color_palette`：色彩建议，例如 `明亮白、浅蓝色`。
- `scene_preset`：场景预设，例如 `scene_03_日常生活`。
- `object_rule`：对象规则，例如 `supermarket`。
- `vocabulary`：词表数组，每项包含 `pinyin`、`hanzi`、`english`、`phonetic`。
- `vocabulary_count`：由 `vocabulary.length` 计算得到的词条数量 `N`，必须同步写入对象数、标签数、箭头数和质检项。

## 合成顺序

1. 注入 `components/CANVAS_STYLE.md`。
2. 注入对应 `scene-presets/*.md`。
3. 注入 `components/CHARACTER_CAST.md`。
4. 注入当前卡片 `vocabulary`、`vocabulary_count` 与 `object-rules/*.md`。
5. 注入 `components/LABEL_CARDS.md`、`TEXT_STYLE.md`、`ARROWS.md`、`BRANDING_BADGE.md`。
6. 注入 `components/QUALITY_GATE.md`。

## 输出文件

- 主输出：`scene-info/<scene>/<card>/<card>.md`
- 兼容输出：`scene-info/<scene>/<card>/prompt.md`，内容必须与主输出完全一致；若不一致，主输出 `<card>.md` 为唯一可信来源。
- 测试输出：允许使用 `<card>.generated.md`，确认后再覆盖主输出。
