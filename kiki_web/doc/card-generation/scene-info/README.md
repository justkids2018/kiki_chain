# 场景资料统一目录（scene-info）

此目录用于统一管理学习卡片生产资料，按“场景 -> 卡片”组织。

## 目录规范

```text
scene-info/
  <scene_slug>/
    <card_slug>/
      <card_slug>.jpg|png|webp   # 场景图
      <card_slug>.json           # 热区数据（items_data）
      prompt.md                  # 生图提示词
```

## 命名规则

- 同一卡片的图片与 JSON 必须同名（仅扩展名不同）
- 推荐使用小写英文+下划线命名：`kiki_jiaoshi`
- `prompt.md` 固定文件名，便于脚本读取

## 当前示例

- `demo_animals/kiki_dongwuyuan/`
- `demo_plants/kiki_zhiwuyuan/`
- `demo_classroom/kiki_jiaoshi/`

## 迁移建议

- 生产资料放在本目录维护
- Flutter 运行时资产（`assets/images` 和 `assets/data`）可由脚本从本目录同步生成
