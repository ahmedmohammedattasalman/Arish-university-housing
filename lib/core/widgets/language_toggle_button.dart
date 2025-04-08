import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return ElevatedButton(
      onPressed: () {
        languageProvider.toggleLanguage();
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, size: 18),
          const SizedBox(width: 8),
          Text(isArabic ? 'English' : 'العربية'),
        ],
      ),
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
      tooltip: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      child: const Icon(Icons.language),
    );
  }
}
