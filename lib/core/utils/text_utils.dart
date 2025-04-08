import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';

class TextUtils {
  // Check if the text contains Arabic characters
  static bool containsArabic(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }

  // Get the appropriate text direction based on content
  static TextDirection getTextDirection(String text) {
    if (containsArabic(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  // Get text align based on language
  static TextAlign getTextAlign(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.isArabic ? TextAlign.right : TextAlign.left;
  }

  // Create a widget with correct text direction based on content
  static Widget directionalText(String text, TextStyle style,
      {TextAlign? textAlign}) {
    return Builder(
      builder: (context) {
        final direction = getTextDirection(text);
        return Text(
          text,
          style: style,
          textAlign: textAlign ??
              (direction == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left),
          textDirection: direction,
        );
      },
    );
  }

  // Helper to create a text input field with proper direction
  static Widget directionalTextField(
    TextEditingController controller, {
    String? labelText,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    return Builder(
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        final isArabic = languageProvider.isArabic;

        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            alignLabelWithHint: true,
          ),
        );
      },
    );
  }
}
