import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';

/// Data model representing a Task with JSON serialization for the REST API
/// and Map serialization for Hive local cache.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description = '',
    super.isCompleted = false,
    super.priority = TaskPriority.medium,
    super.category = TaskCategory.others,
    super.dueDate,
    super.createdAt,
    super.updatedAt,
    super.isSynced = true,
  });

  /// Factory constructor to parse JSON response from the REST API
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isCompleted: json['is_completed'] == true,
      priority: TaskPriority.fromString(json['priority']),
      category: TaskCategory.fromString(json['category']),
      dueDate: DateFormatter.parseIsoString(json['due_date']),
      createdAt: DateFormatter.parseIsoString(json['created_at']),
      updatedAt: DateFormatter.parseIsoString(json['updated_at']),
      isSynced: true,
    );
  }

  /// Convert to JSON payload for POST /tasks/
  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority.name,
      'category': category.name,
    };

    if (dueDate != null) {
      map['due_date'] = DateFormatter.toIsoString(dueDate!);
    }

    return map;
  }

  /// Convert to JSON payload for PUT /tasks/{id}
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority.name,
      'category': category.name,
    };

    if (dueDate != null) {
      map['due_date'] = DateFormatter.toIsoString(dueDate!);
    }

    return map;
  }

  /// Serialization for Hive local storage cache
  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority.name,
      'category': category.name,
      'due_date': dueDate != null ? DateFormatter.toIsoString(dueDate!) : null,
      'created_at': createdAt != null ? DateFormatter.toIsoString(createdAt!) : null,
      'updated_at': updatedAt != null ? DateFormatter.toIsoString(updatedAt!) : null,
      'is_synced': isSynced,
    };
  }

  /// Deserialization from Hive local storage cache
  factory TaskModel.fromCacheMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isCompleted: map['is_completed'] == true,
      priority: TaskPriority.fromString(map['priority']),
      category: TaskCategory.fromString(map['category']),
      dueDate: DateFormatter.parseIsoString(map['due_date']),
      createdAt: DateFormatter.parseIsoString(map['created_at']),
      updatedAt: DateFormatter.parseIsoString(map['updated_at']),
      isSynced: map['is_synced'] == true,
    );
  }

  /// Construct a model from a domain entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      category: entity.category,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
