import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension StringExtension on String {
  // Translate a string using the current context
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}
