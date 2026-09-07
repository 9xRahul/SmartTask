import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_event.dart';

/// Modal bottom sheet allowing users to customize sorting of tasks.
class TaskSortBottomSheet extends StatelessWidget {
  final TaskSortType currentSort;
  final ValueChanged<TaskSortType> onSortSelected;

  const TaskSortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  static void show(
    BuildContext context, {
    required TaskSortType currentSort,
    required ValueChanged<TaskSortType> onSortSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TaskSortBottomSheet(
        currentSort: currentSort,
        onSortSelected: onSortSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort Tasks By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(
              context,
              title: 'Created Date (Newest first)',
              icon: Icons.access_time_rounded,
              sortType: TaskSortType.createdDate,
              isDark: isDark,
            ),
            _buildSortOption(
              context,
              title: 'Due Date (Earliest first)',
              icon: Icons.calendar_month_outlined,
              sortType: TaskSortType.dueDate,
              isDark: isDark,
            ),
            _buildSortOption(
              context,
              title: 'Priority (High → Low)',
              icon: Icons.flag_outlined,
              sortType: TaskSortType.priority,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required TaskSortType sortType,
    required bool isDark,
  }) {
    final bool isSelected = currentSort == sortType;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              size: 20,
            )
          : null,
      onTap: () {
        onSortSelected(sortType);
        Navigator.of(context).pop();
      },
    );
  }
}
