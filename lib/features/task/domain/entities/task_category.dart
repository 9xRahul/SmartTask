import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Task category enumeration matching API: Work, Personal, Health, Finance, Education, Shopping, Travel, Others.
enum TaskCategory {
  work('Work'),
  personal('Personal'),
  health('Health'),
  finance('Finance'),
  education('Education'),
  shopping('Shopping'),
  travel('Travel'),
  others('Others');

  final String name;
  const TaskCategory(this.name);

  /// Parse string from API or return Others
  static TaskCategory fromString(dynamic value) {
    if (value == null) return TaskCategory.others;
    final str = value.toString().toLowerCase().trim();
    for (final cat in TaskCategory.values) {
      if (cat.name.toLowerCase() == str) {
        return cat;
      }
    }
    return TaskCategory.others;
  }

  /// Color representation for badges
  Color get color {
    switch (this) {
      case TaskCategory.work:
        return AppColors.categoryWork;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.health:
        return AppColors.categoryHealth;
      case TaskCategory.finance:
        return AppColors.categoryFinance;
      case TaskCategory.education:
        return AppColors.categoryEducation;
      case TaskCategory.shopping:
        return AppColors.categoryShopping;
      case TaskCategory.travel:
        return AppColors.categoryTravel;
      case TaskCategory.others:
        return AppColors.categoryOthers;
    }
  }

  /// Icon representation
  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return Icons.work_outline_rounded;
      case TaskCategory.personal:
        return Icons.person_outline_rounded;
      case TaskCategory.health:
        return Icons.favorite_border_rounded;
      case TaskCategory.finance:
        return Icons.account_balance_wallet_outlined;
      case TaskCategory.education:
        return Icons.school_outlined;
      case TaskCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TaskCategory.travel:
        return Icons.flight_takeoff_rounded;
      case TaskCategory.others:
        return Icons.label_outline_rounded;
    }
  }
}
