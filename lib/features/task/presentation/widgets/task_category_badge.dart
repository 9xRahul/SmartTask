import 'package:flutter/material.dart';
import '../../domain/entities/task_category.dart';

/// Tag displaying task category with icon and distinctive colors.
class TaskCategoryBadge extends StatelessWidget {
  final TaskCategory category;
  final bool isCompact;

  const TaskCategoryBadge({
    super.key,
    required this.category,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: category.color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: isCompact ? 13 : 15,
            color: category.color,
          ),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }
}
