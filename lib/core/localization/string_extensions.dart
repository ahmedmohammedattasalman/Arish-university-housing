import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Extension on String to easily access translations
extension StringExtension on String {
  /// Translates this string key using the AppLocalizations
  String tr(BuildContext context, {String? defaultValue}) {
    return AppLocalizations.of(context).translate(this) ?? defaultValue ?? this;
  }
}
