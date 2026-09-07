import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase({required this.repository});

  Future<void> call({
    required String userId,
    required dynamic taskId,
  }) async {
    return await repository.deleteTask(
      userId: userId,
      taskId: taskId,
    );
  }
}
