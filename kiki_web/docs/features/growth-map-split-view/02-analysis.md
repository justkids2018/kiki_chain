# 成长地图分栏学习入口现状分析

## 当前实现

- 路由已将场景列表入口指向 `GrowthMapPage`。
- `GrowthMapPage` 复用 `SceneListController` 完成加载、恢复选择和进入学习页。
- 当前地图使用全屏纵向反向列表，节点通过 `GrowthTreeNode` 左右交替展示。
- 当前点击节点会直接调用 `navigateToSceneDetail`，不存在“选中后预览”的中间状态。
- `restoredSceneIndex` 已能持久化最后选择，可作为当前选择的初始值。
- 旧 `SceneCard` 能显示场景封面，但包含较重渐变和文本层，不适合直接作为完整学习卡片预览的唯一实现依据。

## 可复用点

1. 继续使用 `SceneListController.scenes`、`restoredSceneIndex` 和 `persistSelectedSceneIndex`。
2. 继续使用 `GrowthTreeNode` 的树枝、圆形封面、状态和呼吸动画。
3. 继续使用 `Scene.coverImage` 作为右侧卡片图片，并保留网络失败回退。
4. 继续调用 `navigateToSceneDetail` 进入原互动学习页。

## 需要调整

1. `GrowthMapPage` 改为横向分栏容器。
2. 移除列表 `reverse: true`，让场景索引从上到下排列。
3. 将节点点击行为从“进入学习”改为“更新当前选择并滚动居中”。
4. 增加右侧单卡预览，并把进入学习行为移动到该预览。
5. 根据左侧实际宽度调整节点布局，避免原双侧节点在窄分栏中拥挤。
6. 更新视觉测试为横屏尺寸，并验证节点与右侧卡片同步。

## 风险

- `restoredSceneIndex` 表示最后选择，不等同于服务端真实学习进度。本次文案和状态只表达“当前选择”，不宣称真实学习完成度。
- 原地图为手机竖屏设计。分栏后左侧宽度变小，需要使用响应式节点尺寸与留白。
- 用户工作区中成长地图文件仍为未跟踪改动，本次仅在其基础上增量修改，不覆盖或回退其他改动。

## 文档差异

现有 `growth-map-scene-list.md` 描述“从下向上”和“点击节点直接进入学习”，实现完成后必须同步修订。

最后更新：2026-07-03
