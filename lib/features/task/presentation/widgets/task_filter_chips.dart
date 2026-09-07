import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_event.dart';

/// Filter selection bar for switching between All, Pending, and Completed tasks.
class TaskFilterChips extends StatelessWidget {
  final TaskFilterType activeFilter;
  final ValueChanged<TaskFilterType> onFilterSelected;
  final int totalCount;
  final int pendingCount;
  final int completedCount;

  const TaskFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    required this.totalCount,
    required this.pendingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'All',
            count: totalCount,
            filter: TaskFilterType.all,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Pending',
            count: pendingCount,
            filter: TaskFilterType.pending,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Completed',
            count: completedCount,
            filter: TaskFilterType.completed,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required int count,
    required TaskFilterType filter,
    required bool isDark,
  }) {
    final bool isSelected = activeFilter == filter;

    return InkWell(
      onTap: () => onFilterSelected(filter),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(64)
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
