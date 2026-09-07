import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase({required this.repository});

  Future<TaskEntity> call({
    required String userId,
    required TaskEntity task,
  }) async {
    return await repository.updateTask(
      userId: userId,
      task: task,
    );
  }
}
