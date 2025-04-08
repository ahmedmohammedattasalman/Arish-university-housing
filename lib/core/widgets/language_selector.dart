import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';
import '../localization/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    final localizations = AppLocalizations.of(context);

    return ListTile(
      title: Text(localizations.translate('language')),
      trailing: DropdownButton<String>(
        value: isArabic ? 'ar' : 'en',
        underline: Container(),
        onChanged: (String? value) {
          if (value != null) {
            languageProvider.changeLanguage(Locale(value, ''));
          }
        },
        items: [
          DropdownMenuItem<String>(
            value: 'en',
            child: Text(localizations.translate('english')),
          ),
          DropdownMenuItem<String>(
            value: 'ar',
            child: Text(localizations.translate('arabic')),
          ),
        ],
      ),
    );
  }
}
