import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Helper to show stylish modern floating SnackBars throughout the app.
class CustomSnackBar {
  CustomSnackBar._();

  static void showSuccess(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_rounded,
    );
  }

  static void showWarning(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_rounded,
    );
  }

  static void showInfo(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_rounded,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
