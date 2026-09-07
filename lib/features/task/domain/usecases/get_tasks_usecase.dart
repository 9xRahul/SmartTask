import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase({required this.repository});

  Future<List<TaskEntity>> call({
    required String userId,
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    return await repository.getTasks(
      userId: userId,
      skip: skip,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
