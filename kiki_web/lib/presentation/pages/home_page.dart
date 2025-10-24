import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'package:kikichain/presentation/controllers/language_controller.dart';
import 'package:kikichain/presentation/pages/settings/language_settings_page.dart';
import 'package:kikichain/utils/localization_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        actions: [
          // 语言切换按钮
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => LocalizationUtils.showLanguageDialog(),
            tooltip: localizations.language,
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const LanguageSettingsPage()),
            tooltip: localizations.settings,
          ),
        ],
      ),
      body: GetBuilder<LanguageController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.welcome,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.appName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 当前语言信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizations.language}:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.getLanguageName(controller.currentLocale),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 快速语言切换按钮
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '快速切换 / Quick Switch / 快速切換',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: controller.supportedLocales.map((locale) {
                            final isSelected = controller.isCurrentLanguage(locale);
                            return ElevatedButton(
                              onPressed: isSelected 
                                ? null 
                                : () => controller.changeLanguage(locale),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected 
                                  ? Theme.of(context).primaryColor.withOpacity(0.8)
                                  : null,
                              ),
                              child: Text(controller.getLanguageName(locale)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 功能演示
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '功能演示 / Function Demo / 功能演示',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          // 按钮演示
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(localizations.login),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(localizations.register),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(localizations.logout),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 状态文本演示
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: Text(localizations.loading)),
                              Chip(label: Text(localizations.success)),
                              Chip(label: Text(localizations.error)),
                              Chip(label: Text(localizations.noData)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => languageController.switchToNextLanguage(),
        tooltip: '${localizations.language} ${localizations.settings}',
        child: const Icon(Icons.translate),
      ),
    );
  }
}
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 