import 'package:flutter/material.dart';

/// Utility class for handling Arabic text in the application
class ArabicTextUtils {
  /// Check if text contains Arabic characters
  static bool containsArabic(String text) {
    // Unicode range for Arabic characters
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }

  /// Validate if a string is valid Arabic (contains only Arabic characters)
  static bool isValidArabic(String text) {
    // Only Arabic characters and common punctuation/spaces
    final arabicPattern = RegExp(r'^[\u0600-\u06FF\s\d.,!?()-:;]*$');
    return arabicPattern.hasMatch(text);
  }

  /// Get proper text direction based on text content
  static TextDirection getTextDirection(String text) {
    if (containsArabic(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Create a FormField validator for Arabic text
  static FormFieldValidator<String> arabicValidator({
    bool required = true,
    String? requiredMessage,
    int minLength = 0,
    String? minLengthMessage,
  }) {
    return (String? value) {
      // Check if empty but required
      if ((value == null || value.isEmpty) && required) {
        return requiredMessage ?? 'This field is required';
      }

      // If value is not empty, check min length
      if (value != null && value.isNotEmpty && value.length < minLength) {
        return minLengthMessage ??
            'Text must be at least $minLength characters';
      }

      return null; // Validation passed
    };
  }

  /// Create an InputDecoration with RTL support for Arabic
  static InputDecoration arabicInputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      // For Arabic (RTL) alignment
      alignLabelWithHint: true,
      // Border styling
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
    );
  }
}
