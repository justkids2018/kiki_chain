# 任务拆分

## Task 01：入口与练字页

影响文件：

- `kiki_web/lib/presentation/pages/interactive_image/interactive_image_page.dart`
- `kiki_web/lib/presentation/pages/interactive_image/interactive_image_controller.dart`
- `kiki_web/lib/config/app_routes.dart`
- `kiki_web/lib/core/constants/app_constants.dart`
- `kiki_web/lib/presentation/features/writing_practice/pages/writing_practice_page.dart`
- `kiki_web/lib/presentation/features/writing_practice/widgets/traceable_tianzi_cell.dart`

验证：

- 学习卡片页入口可见。
- 点击后进入练字页。
- 汉字、拼音、田字格、描写轨迹正常显示。

## Task 02：移动端系统打印

影响文件：

- `kiki_web/pubspec.yaml`
- `kiki_web/lib/presentation/features/writing_practice/services/writing_practice_print_service.dart`

验证：

- 点击打印生成 A4 PDF。
- Android/iOS 调起系统打印面板。
