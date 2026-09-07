import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Task priority enumeration matching the REST API: Low, Medium, High.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  final String name;
  const TaskPriority(this.name);

  /// Parse string from API or return default Medium
  static TaskPriority fromString(dynamic value) {
    if (value == null) return TaskPriority.medium;
    final str = value.toString().toLowerCase().trim();
    if (str == 'high') return TaskPriority.high;
    if (str == 'low') return TaskPriority.low;
    return TaskPriority.medium;
  }

  /// Color representation for chips and badges
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  /// Icon representation
  IconData get icon {
    switch (this) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }

  /// Numeric weight for priority sorting
  int get sortWeight {
    switch (this) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }
}
