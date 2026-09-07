import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, secondary, outlined, danger }

/// Reusable modern button with loading indicator and icon support.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case ButtonType.secondary:
        backgroundColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
        foregroundColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        borderSide = BorderSide.none;
        break;
      case ButtonType.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        borderSide = BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 1.5,
        );
        break;
      case ButtonType.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: type == ButtonType.primary ? 2 : 0,
          shadowColor: backgroundColor.withAlpha(77),
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
