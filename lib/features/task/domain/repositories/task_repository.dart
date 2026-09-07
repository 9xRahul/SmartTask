import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<TaskEntity> getTaskById({
    required String userId,
    required dynamic taskId,
  });

  Future<TaskEntity> createTask({
    required String userId,
    required TaskEntity task,
  });

  Future<TaskEntity> updateTask({
    required String userId,
    required TaskEntity task,
  });

  Future<void> deleteTask({
    required String userId,
    required dynamic taskId,
  });

  /// Synchronize pending offline actions with backend REST API
  Future<int> syncOfflineTasks({required String userId});
}
