import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      // First attempt - with assets prefix (standard path)
      String jsonString = await rootBundle
          .loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      try {
        // Second attempt - without assets prefix (for some web configurations)
        String jsonString =
            await rootBundle.loadString('lang/${locale.languageCode}.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);

        _localizedStrings = jsonMap.map((key, value) {
          return MapEntry(key, value.toString());
        });

        return true;
      } catch (e) {
        // Fallback to hardcoded basic strings for critical functionality
        debugPrint('Error loading language file: $e');

        // Extended fallback strings with more Arabic translations
        if (locale.languageCode == 'ar') {
          _localizedStrings = _getArabicFallbackTranslations();
        } else {
          _localizedStrings = _getEnglishFallbackTranslations();
        }
        return false;
      }
    }
  }

  // Comprehensive Arabic fallback translations
  Map<String, String> _getArabicFallbackTranslations() {
    return {
      'app_name': 'سكن الجامعة',
      'login': 'تسجيل الدخول',
      'register': 'التسجيل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'error': 'خطأ',
      'success': 'نجاح',
      'welcome': 'مرحبا بكم',
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'logout': 'تسجيل الخروج',
      'home': 'الرئيسية',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'full_name': 'الاسم الكامل',
      'phone': 'رقم الهاتف',
      'department': 'القسم',
      'room_number': 'رقم الغرفة',
      'building': 'المبنى',
      'student_id': 'رقم الطالب',
      'vacation_request': 'طلب إجازة',
      'submit_request': 'تقديم الطلب',
      'start_date': 'تاريخ البدء',
      'end_date': 'تاريخ الانتهاء',
      'reason': 'السبب',
      'status': 'الحالة',
      'pending': 'قيد الانتظار',
      'approved': 'موافق عليه',
      'rejected': 'مرفوض',
      'select_date': 'اختر التاريخ',
      'attendance': 'الحضور',
      'payments': 'المدفوعات',
      'amount': 'المبلغ',
      'date': 'التاريخ',
      'payment_method': 'طريقة الدفع',
      'payment_status': 'حالة الدفع',
      'paid': 'مدفوع',
      'unpaid': 'غير مدفوع',
      'required_field': 'هذا الحقل مطلوب',
      'invalid_email': 'البريد الإلكتروني غير صالح',
      'password_short': 'كلمة المرور قصيرة جدًا',
      'passwords_not_match': 'كلمات المرور غير متطابقة',
      'loading': 'جاري التحميل...',
      'try_again': 'حاول مرة أخرى',
      'no_data': 'لا توجد بيانات',
      'permission_denied': 'ليس لديك صلاحية',
    };
  }

  // English fallback translations
  Map<String, String> _getEnglishFallbackTranslations() {
    return {
      'app_name': 'University Housing',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'error': 'Error',
      'success': 'Success',
      'welcome': 'Welcome',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'home': 'Home',
      'settings': 'Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'full_name': 'Full Name',
      'phone': 'Phone',
      'department': 'Department',
      'room_number': 'Room Number',
      'building': 'Building',
      'student_id': 'Student ID',
      'vacation_request': 'Vacation Request',
      'submit_request': 'Submit Request',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'reason': 'Reason',
      'status': 'Status',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'select_date': 'Select Date',
      'attendance': 'Attendance',
      'payments': 'Payments',
      'amount': 'Amount',
      'date': 'Date',
      'payment_method': 'Payment Method',
      'payment_status': 'Payment Status',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'required_field': 'This field is required',
      'invalid_email': 'Invalid email',
      'password_short': 'Password is too short',
      'passwords_not_match': 'Passwords do not match',
      'loading': 'Loading...',
      'try_again': 'Try Again',
      'no_data': 'No Data',
      'permission_denied': 'Permission Denied',
    };
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Get direction for current locale
  TextDirection get textDirection {
    return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  // Format a string with Arabic numerals if in Arabic mode
  String formatNumber(int number) {
    if (locale.languageCode != 'ar') return number.toString();

    // Arabic digits ٠١٢٣٤٥٦٧٨٩
    const List<String> arabicDigits = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩'
    ];

    return number.toString().split('').map((digit) {
      if (digit.codeUnitAt(0) >= 48 && digit.codeUnitAt(0) <= 57) {
        // Convert 0-9 to Arabic digits
        return arabicDigits[int.parse(digit)];
      }
      return digit;
    }).join();
  }

  // Get the current locale
  static Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) {
      return supportedLocales.first;
    }

    // Check if the current device locale is supported
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    // If the locale of the device is not supported, use the first one
    // (English in this case)
    return supportedLocales.first;
  }

  // List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];
}

// LocalizationsDelegate is a factory for a set of localized resources
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
