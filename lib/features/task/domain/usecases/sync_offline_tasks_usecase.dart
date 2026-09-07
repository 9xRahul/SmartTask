import '../repositories/task_repository.dart';

class SyncOfflineTasksUseCase {
  final TaskRepository repository;

  SyncOfflineTasksUseCase({required this.repository});

  Future<int> call({required String userId}) async {
    return await repository.syncOfflineTasks(userId: userId);
  }
}
