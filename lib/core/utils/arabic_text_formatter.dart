import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Utility class for formatting Arabic text for display
class ArabicTextFormatter {
  /// Format a date for Arabic display
  static String formatDate(DateTime date, {bool includeTime = false}) {
    // Get the locale-aware formatting based on current language
    final formatter = includeTime
        ? intl.DateFormat.yMMMd().add_jm()
        : intl.DateFormat.yMMMd();

    return formatter.format(date);
  }

  /// Format currency for Arabic display
  static String formatCurrency(double amount, {String currencyCode = 'EGP'}) {
    return intl.NumberFormat.currency(
      symbol: currencyCode,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Get direction-aware text widget
  static Widget directionAwareText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    // Check if text contains Arabic
    bool containsArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);

    return Text(
      text,
      style: style,
      textAlign:
          textAlign ?? (containsArabic ? TextAlign.right : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      textDirection: containsArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  /// Build locale-aware date
  static String getRelativeDateString(DateTime date, BuildContext context) {
    // Get the difference from now
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today / اليوم';
    } else if (difference.inDays == 1) {
      return 'Yesterday / أمس';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago / منذ ${difference.inDays} أيام';
    } else {
      return formatDate(date);
    }
  }

  /// Format Arabic name with proper honorifics
  static String formatArabicName(String name, {String gender = 'unknown'}) {
    if (name.isEmpty) return '';

    // Arabic honorifics
    String honorific = '';
    if (gender == 'male') {
      honorific = 'السيد';
    } else if (gender == 'female') {
      honorific = 'السيدة';
    }

    // If there's an honorific, add it with the name
    if (honorific.isNotEmpty) {
      return '$honorific $name';
    }

    return name;
  }
}
