import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  GetTaskByIdUseCase({required this.repository});

  Future<TaskEntity> call({
    required String userId,
    required dynamic taskId,
  }) async {
    return await repository.getTaskById(
      userId: userId,
      taskId: taskId,
    );
  }
}
