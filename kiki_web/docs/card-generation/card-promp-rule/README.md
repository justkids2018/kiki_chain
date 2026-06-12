# card-promp-rule 目录说明

这个目录存放 Hi Kiki 学习卡片图片生成的核心规则文件。

## 文件结构

### 规则入口（推荐）

- [RULES.md](./RULES.md)
  - 统一规则总入口（写死规则 + 场景强化 + 组装流程）

### 核心 Prompt

- [PROMPT_REAL_SCENE.md](./PROMPT_REAL_SCENE.md)
  - 唯一保留的图片生成 Prompt 骨架
  - 适用于全部学习卡片场景（真实场景布局）

### 组件规范

- [components/README.md](./components/README.md)
  - 组件索引
- [components/LABEL_CARDS.md](./components/LABEL_CARDS.md)
  - 卡片底牌、边框、厚度、阴影
- [components/TEXT_STYLE.md](./components/TEXT_STYLE.md)
  - 三行文字格式、字号、字重、字色
- [components/ARROWS.md](./components/ARROWS.md)
  - 箭头粗细、颜色、弯曲、落点
- [components/BRANDING_BADGE.md](./components/BRANDING_BADGE.md)
  - Hi Kiki 品牌角标规则

## 使用建议

- 先使用 `PROMPT_REAL_SCENE.md` 生成每张学习卡片 Prompt
- 再按需查看组件规范微调视觉细节
