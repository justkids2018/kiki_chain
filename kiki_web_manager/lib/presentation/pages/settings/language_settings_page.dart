import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'package:kikichain/presentation/controllers/language_controller.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<LanguageController>(
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.supportedLocales.length,
            itemBuilder: (context, index) {
              final locale = controller.supportedLocales[index];
              final isSelected = controller.isCurrentLanguage(locale);
              
              return ListTile(
                title: Text(
                  controller.getLanguageName(locale),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                trailing: isSelected 
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
                onTap: () async {
                  if (!isSelected) {
                    await controller.changeLanguage(locale);
                    // 可选：显示切换成功的提示
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${localizations.language} ${localizations.success}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}