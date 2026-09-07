import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

/// Clean empty state component with icon, title, subtitle, and action button.
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.task_alt_rounded,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainerLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: actionText!,
                icon: Icons.add_rounded,
                width: 170,
                height: 44,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
