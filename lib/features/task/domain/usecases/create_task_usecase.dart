import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase({required this.repository});

  Future<TaskEntity> call({
    required String userId,
    required TaskEntity task,
  }) async {
    return await repository.createTask(
      userId: userId,
      task: task,
    );
  }
}
