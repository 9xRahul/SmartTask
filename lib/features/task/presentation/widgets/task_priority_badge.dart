import 'package:flutter/material.dart';
import '../../domain/entities/task_priority.dart';

/// Tag displaying task priority with color-coded styling and icon.
class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompact;

  const TaskPriorityBadge({
    super.key,
    required this.priority,
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
        color: priority.color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priority.color.withAlpha(89),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: isCompact ? 13 : 15,
            color: priority.color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.name,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}
