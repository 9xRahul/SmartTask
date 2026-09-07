import 'package:equatable/equatable.dart';
import 'task_category.dart';
import 'task_priority.dart';

/// Domain entity representing a Task in the application.
class TaskEntity extends Equatable {
  final dynamic id; // Can be int (from API) or temp string for offline creations
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced; // Local synchronization state

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.others,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.isSynced = true,
  });

  TaskEntity copyWith({
    dynamic id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        priority,
        category,
        dueDate,
        createdAt,
        updatedAt,
        isSynced,
      ];
}
