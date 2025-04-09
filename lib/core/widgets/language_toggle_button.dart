import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';
import '../localization/string_extensions.dart';

/// A button widget that toggles between Arabic and English language
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return IconButton(
      icon: Text(
        isArabic ? 'En' : 'Ar',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      tooltip: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      onPressed: () {
        languageProvider.toggleLanguage();
      },
    );
  }
}

// A floating action button version of the language toggle
class LanguageToggleFAB extends StatelessWidget {
  const LanguageToggleFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return FloatingActionButton(
      onPressed: () {
        languageProvider.toggleLanguage();
      },
      tooltip: isArabic ? 'english'.tr(context) : 'arabic'.tr(context),
      child: const Icon(Icons.language),
    );
  }
}
