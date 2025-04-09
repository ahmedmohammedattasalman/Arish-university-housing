import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A helper class to provide consistent font handling across platforms
class FontHelper {
  /// Get a TextStyle with the Poppins font family
  static TextStyle poppins({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  /// Get a TextStyle with the Roboto font family
  static TextStyle roboto({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  /// Create a fallback font stack for web platforms
  static TextStyle withFallback(TextStyle style) {
    if (kIsWeb) {
      // Add system font fallbacks for web platform
      return style.copyWith(
        fontFamilyFallback: [
          'Segoe UI',
          'Roboto',
          'Helvetica Neue',
          'Arial',
          'sans-serif',
        ],
      );
    }
    return style;
  }
}
