# 图片生成 Prompt 索引（统一真实场景）

> 当前仅保留真实场景 Prompt 体系。

---

## 统一入口

- 规则总入口：`card-promp-rule/RULES.md`
- 真实场景总模板：`card-promp-rule/PROMPT_REAL_SCENE.md`
- 批量卡片 Prompt：`scene-info/scene_*/kik_*/kik_*.md`
- 每张卡片兼容入口：`scene-info/scene_*/kik_*/prompt.md`
- 端到端生产流程（Prompt -> Admin）：`CARD_PRODUCTION_WORKFLOW.md`

---

## 命名规范

- 文件名：`kik_场景_01_功能.md`
- 目录名：`scene-info/scene_01_场景/kik_场景_01_功能/`
- 同目录资产：
	- `kik_场景_01_功能.md`
	- `prompt.md`
	- `kik_场景_01_功能.png`
	- `kik_场景_01_功能.json`

---

## 批量生成

在 `kiki_web/` 执行：

```bash
python3 scripts/card_generation/generate_prompts_from_scenes.py
```

此命令会基于 `SCENES.md` 一次性生成 4 大场景全部学习卡片 Prompt，并更新 `scene-info/index.json`。
