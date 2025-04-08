import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ??
        (isOutlined ? Colors.transparent : AppTheme.primaryColor);

    final Color txtColor =
        textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white);

    final BorderRadius radius = borderRadius ?? BorderRadius.circular(8.0);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: isOutlined
            ? BorderSide(color: AppTheme.primaryColor)
            : BorderSide.none,
      ),
      elevation: isOutlined ? 0 : 2,
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? _buildLoadingIndicator(txtColor)
            : Text(
                text,
                style: TextStyle(
                  color: txtColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    // Use a safer, simpler loading indicator to avoid initialization issues
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 2.0,
      ),
    );
  }
}
