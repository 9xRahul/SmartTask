import 'task_model.dart';

/// Represents the paginated response model returned by GET /tasks/
class TaskListResponseModel {
  final String status;
  final String message;
  final List<TaskModel> tasks;
  final int total;

  const TaskListResponseModel({
    required this.status,
    required this.message,
    required this.tasks,
    required this.total,
  });

  factory TaskListResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['data'] as List<dynamic>? ?? [];
    final List<TaskModel> parsedTasks = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => TaskModel.fromJson(item))
        .toList();

    return TaskListResponseModel(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? '',
      tasks: parsedTasks,
      total: json['total'] is int ? json['total'] as int : parsedTasks.length,
    );
  }
}
