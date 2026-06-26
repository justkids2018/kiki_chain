# 现状分析

## 入口

当前学习卡片页面位于 `kiki_web/lib/presentation/pages/interactive_image/`。

可复用数据来自 `InteractiveImageController.vocabularyRegions`，每个 `InteractiveRegion` 已包含：

- `text`：汉字词条
- `textPinyin`：拼音
- `textPhonetic`：备用发音字段

## 方案约束

1. `kiki_web` 新页面需按 `presentation/features/<feature>/pages|widgets|controllers` 组织。
2. 本功能不需要新增 API 或数据库字段。
3. 打印能力需适配移动端系统打印，不能依赖 Web 浏览器打印。

## 风险

1. 移动端 PDF 中文字体需要可用字体。当前实现内置 `assets/fonts/AR-PL-KaitiM-GB.ttf`，避免依赖运行时网络字体。
2. 当前环境没有可用 Flutter SDK，无法在本机完成 `flutter pub get` 和 `flutter analyze`。
