import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  
  // 当前选中的语言
  final Rx<Locale> _currentLocale = const Locale('zh', 'CN').obs;
  Locale get currentLocale => _currentLocale.value;
  
  // 支持的语言列表
  final List<Locale> supportedLocales = const [
    Locale('zh', 'CN'), // 中文简体
    Locale('zh', 'TW'), // 中文繁体
    Locale('en', 'US'), // 英文
  ];
  
  // 语言显示名称映射
  final Map<String, String> languageNames = {
    'zh_CN': '简体中文',
    'zh_TW': '繁體中文',
    'en_US': 'English',
  };
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }
  
  // 加载保存的语言设置
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        final parts = savedLanguage.split('_');
        if (parts.length == 2) {
          final locale = Locale(parts[0], parts[1]);
          if (supportedLocales.contains(locale)) {
            _currentLocale.value = locale;
            Get.updateLocale(locale);
          }
        }
      } else {
        // 如果没有保存的语言，使用系统语言
        _setSystemLanguage();
      }
    } catch (e) {
      print('Error loading saved language: $e');
      _setSystemLanguage();
    }
  }
  
  // 设置系统语言
  void _setSystemLanguage() {
    final systemLocale = Get.deviceLocale ?? const Locale('zh', 'CN');
    final supportedLocale = _findSupportedLocale(systemLocale);
    _currentLocale.value = supportedLocale;
    Get.updateLocale(supportedLocale);
  }
  
  // 查找支持的语言
  Locale _findSupportedLocale(Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        if (supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
      }
    }
    
    // 如果找不到完全匹配的，尝试只匹配语言代码
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    // 默认返回中文简体
    return const Locale('zh', 'CN');
  }
  
  // 更改语言
  Future<void> changeLanguage(Locale locale) async {
    if (supportedLocales.contains(locale)) {
      _currentLocale.value = locale;
      Get.updateLocale(locale);
      await _saveLanguage(locale);
    }
  }
  
  // 保存语言设置
  Future<void> _saveLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (e) {
      print('Error saving language: $e');
    }
  }
  
  // 获取语言显示名称
  String getLanguageName(Locale locale) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    return languageNames[key] ?? locale.toString();
  }
  
  // 是否为当前语言
  bool isCurrentLanguage(Locale locale) {
    return _currentLocale.value == locale;
  }
  
  // 切换到下一个语言
  Future<void> switchToNextLanguage() async {
    final currentIndex = supportedLocales.indexOf(_currentLocale.value);
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await changeLanguage(supportedLocales[nextIndex]);
  }
}