import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'package:kikichain/presentation/controllers/language_controller.dart';

class LocalizationUtils {
  /// 获取当前的本地化实例
  static AppLocalizations get localizations {
    final context = Get.context;
    if (context == null) {
      throw Exception('Get.context is null. Make sure GetMaterialApp is used.');
    }
    return AppLocalizations.of(context)!;
  }
  
  /// 快捷方式获取翻译文本
  static String tr(String Function(AppLocalizations) selector) {
    return selector(localizations);
  }
  
  /// 获取语言控制器
  static LanguageController get languageController => Get.find<LanguageController>();
  
  /// 显示语言选择对话框
  static Future<void> showLanguageDialog() async {
    final context = Get.context;
    if (context == null) return;
    
    final controller = languageController;
    final localizations = AppLocalizations.of(context)!;
    
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.supportedLocales.map((locale) {
              return ListTile(
                title: Text(controller.getLanguageName(locale)),
                leading: Radio<Locale>(
                  value: locale,
                  groupValue: controller.currentLocale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  controller.changeLanguage(locale);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }
  
  /// 格式化多语言文本（带参数）
  static String format(String text, List<dynamic> args) {
    String result = text;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i].toString());
    }
    return result;
  }
  
  /// 判断当前是否为中文
  static bool get isChinese {
    final locale = languageController.currentLocale;
    return locale.languageCode == 'zh';
  }
  
  /// 判断当前是否为英文
  static bool get isEnglish {
    final locale = languageController.currentLocale;
    return locale.languageCode == 'en';
  }
  
  /// 判断当前是否为繁体中文
  static bool get isTraditionalChinese {
    final locale = languageController.currentLocale;
    return locale.languageCode == 'zh' && locale.countryCode == 'TW';
  }
  
  /// 判断当前是否为简体中文
  static bool get isSimplifiedChinese {
    final locale = languageController.currentLocale;
    return locale.languageCode == 'zh' && locale.countryCode == 'CN';
  }
}