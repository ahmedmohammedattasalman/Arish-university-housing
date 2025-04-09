import 'package:flutter/material.dart';
import '../utils/arabic_text_utils.dart';

/// A custom TextField widget optimized for Arabic text input.
/// This widget automatically handles RTL text direction and provides
/// proper input decoration for Arabic text.
class ArabicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final TextInputType keyboardType;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  /// Creates an ArabicTextField.
  const ArabicTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.textInputAction,
    this.onEditingComplete,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current direction of the text in the controller
    TextDirection textDirection =
        TextDirection.rtl; // Default to RTL for Arabic

    // If controller has text, determine direction based on content
    if (controller.text.isNotEmpty) {
      textDirection = ArabicTextUtils.getTextDirection(controller.text);
    }

    return Directionality(
      textDirection: textDirection,
      child: TextFormField(
        controller: controller,
        decoration: ArabicTextUtils.arabicInputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,
        keyboardType: keyboardType,
        autofocus: autofocus,
        focusNode: focusNode,
        // Always handle text changes to update text direction if needed
        onChanged: (String value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onSubmitted,
        // Apply Arabic text styling
        style: const TextStyle(
          fontFamily: 'Arial', // Ensure Arabic-friendly font
        ),
      ),
    );
  }
}
