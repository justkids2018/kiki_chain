# 国际化配置说明

本项目已配置完整的国际化支持，支持**中文简体**、**中文繁体**和**英文**三种语言。

## 🌍 支持的语言

- 🇨🇳 中文简体 (zh_CN)
- 🇭🇰 中文繁体 (zh_TW) 
- 🇺🇸 英文 (en_US)

## 📁 文件结构

```
lib/
├── l10n/                           # 国际化文件目录
│   ├── app_en.arb                  # 英文翻译文件
│   ├── app_zh.arb                  # 中文简体翻译文件
│   └── app_zh_TW.arb               # 中文繁体翻译文件
├── generated/                      # 自动生成的国际化代码
│   ├── app_localizations.dart      # 主要的国际化类
│   ├── app_localizations_en.dart   # 英文国际化实现
│   └── app_localizations_zh.dart   # 中文国际化实现
├── presentation/controllers/
│   └── language_controller.dart    # 语言管理控制器
├── presentation/pages/settings/
│   └── language_settings_page.dart # 语言设置页面
├── utils/
│   └── localization_utils.dart     # 国际化工具类
└── main.dart                       # 主文件（已配置国际化）
```

## 🚀 如何使用

### 1. 在代码中使用翻译

```dart
import 'package:kikichain/generated/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Text(localizations.welcome); // 显示"欢迎"或"Welcome"等
  }
}
```

### 2. 使用工具类快速获取翻译

```dart
import 'package:kikichain/utils/localization_utils.dart';

// 快速获取翻译
String welcomeText = LocalizationUtils.tr((l) => l.welcome);

// 显示语言选择对话框
LocalizationUtils.showLanguageDialog();

// 判断当前语言
if (LocalizationUtils.isChinese) {
  // 当前是中文
}
```

### 3. 编程方式切换语言

```dart
import 'package:get/get.dart';
import 'package:kikichain/presentation/controllers/language_controller.dart';

final languageController = Get.find<LanguageController>();

// 切换到英文
await languageController.changeLanguage(const Locale('en', 'US'));

// 切换到中文简体
await languageController.changeLanguage(const Locale('zh', 'CN'));

// 切换到中文繁体
await languageController.changeLanguage(const Locale('zh', 'TW'));

// 切换到下一个语言
await languageController.switchToNextLanguage();
```

## ➕ 添加新的翻译

### 1. 在 .arb 文件中添加新的文本

在 `lib/l10n/app_en.arb` 中添加：
```json
{
  "newKey": "New Text",
  "@newKey": {
    "description": "Description for new text"
  }
}
```

在 `lib/l10n/app_zh.arb` 中添加：
```json
{
  "newKey": "新文本"
}
```

在 `lib/l10n/app_zh_TW.arb` 中添加：
```json
{
  "newKey": "新文本"
}
```

### 2. 重新生成国际化文件

```bash
flutter gen-l10n
```

### 3. 在代码中使用

```dart
final localizations = AppLocalizations.of(context)!;
Text(localizations.newKey);
```

## 🔧 配置文件说明

### `l10n.yaml`
```yaml
arb-dir: lib/l10n                    # .arb 文件目录
template-arb-file: app_en.arb        # 模板文件（英文）
output-localization-file: app_localizations.dart  # 输出文件名
output-class: AppLocalizations       # 生成的类名
output-dir: lib/generated           # 输出目录
synthetic-package: false            # 不使用合成包
```

### `pubspec.yaml` 依赖
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true  # 启用代码生成
```

## 🎯 功能特性

- ✅ **自动语言检测**：首次启动时自动检测系统语言
- ✅ **语言持久化**：用户选择的语言会被保存，重启应用后保持
- ✅ **实时切换**：切换语言后立即生效，无需重启应用
- ✅ **完整UI支持**：包括Material Design组件的本地化
- ✅ **语言设置页面**：提供用户友好的语言设置界面
- ✅ **快速切换**：提供浮动按钮和工具栏按钮快速切换语言
- ✅ **工具类支持**：提供便捷的工具方法简化使用

## 📱 用户体验

用户可以通过以下方式切换语言：

1. **设置页面**：进入设置 -> 语言设置，选择所需语言
2. **快速对话框**：点击工具栏的语言图标，弹出语言选择对话框
3. **快速按钮**：在首页点击相应的语言快速切换按钮
4. **浮动按钮**：点击首页的翻译浮动按钮循环切换语言

## 🛠 开发注意事项

1. **所有用户可见的文本都应该使用国际化**
2. **添加新的翻译时，确保在所有 .arb 文件中都有对应的翻译**
3. **图片和其他资源如果需要本地化，可以使用不同的资源文件夹**
4. **数字、日期等格式化也会根据当前语言自动调整**
5. **记得在修改 .arb 文件后运行 `flutter gen-l10n` 重新生成代码**

## 🔍 调试

如果遇到问题，可以检查：

1. `flutter gen-l10n` 是否成功执行
2. `lib/generated/` 目录下是否有生成的文件
3. `pubspec.yaml` 中的依赖是否正确配置
4. GetX控制器是否正确注册（在 main.dart 中）

---

现在你的应用已经完全支持国际化了！🎉