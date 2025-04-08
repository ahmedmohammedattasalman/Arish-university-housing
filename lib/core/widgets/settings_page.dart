import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../localization/language_provider.dart';
import '../localization/string_extensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr(context)),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('language'.tr(context)),
            trailing: DropdownButton<String>(
              value: languageProvider.isArabic ? 'ar' : 'en',
              onChanged: (String? value) {
                if (value != null) {
                  languageProvider.changeLanguage(Locale(value, ''));
                }
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'en',
                  child: Text('english'.tr(context)),
                ),
                DropdownMenuItem<String>(
                  value: 'ar',
                  child: Text('arabic'.tr(context)),
                ),
              ],
            ),
          ),
          const Divider(),
          // Add other settings here
        ],
      ),
    );
  }
}
