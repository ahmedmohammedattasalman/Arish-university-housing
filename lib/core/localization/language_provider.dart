import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Default locale is Arabic
  Locale _locale = const Locale('ar', '');
  Locale get locale => _locale;

  // Key for storing language preference
  static const String _languageKey = 'language_code';

  // Initialize language from storage
  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString(_languageKey) ?? 'ar';
    setLocale(Locale(languageCode, ''));
  }

  // Check if current language is Arabic
  bool get isArabic => _locale.languageCode == 'ar';

  // Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLocale =
        isArabic ? const Locale('en', '') : const Locale('ar', '');
    await changeLanguage(newLocale);
  }

  // Change the app language
  Future<void> changeLanguage(Locale locale) async {
    _locale = locale;

    // Save language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);

    notifyListeners();
  }

  // Set locale without saving (used at startup)
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  // Get TextDirection based on current language
  TextDirection get textDirection =>
      _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}
