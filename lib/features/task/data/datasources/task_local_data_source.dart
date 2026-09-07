import '../../../../core/services/local_storage_service.dart';
import '../models/sync_queue_item.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getCachedTasks();
  Future<TaskModel?> getCachedTaskById(dynamic taskId);
  Future<void> cacheTasks(List<TaskModel> tasks, {bool append = false});
  Future<void> saveCachedTask(TaskModel task);
  Future<void> deleteCachedTask(dynamic taskId);
  Future<void> clearCache();

  // Sync Queue operations
  Future<void> addToSyncQueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getSyncQueue();
  Future<void> removeFromSyncQueue(String queueId);
  Future<void> clearSyncQueue();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final LocalStorageService localStorageService;

  TaskLocalDataSourceImpl({required this.localStorageService});

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    final box = localStorageService.taskBox;
    final List<TaskModel> tasks = [];

    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        tasks.add(TaskModel.fromCacheMap(value));
      }
    }

    // Sort cached tasks by createdAt descending by default
    tasks.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return tasks;
  }

  @override
  Future<TaskModel?> getCachedTaskById(dynamic taskId) async {
    final box = localStorageService.taskBox;
    final value = box.get(taskId.toString());
    if (value is Map) {
      return TaskModel.fromCacheMap(value);
    }
    return null;
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks, {bool append = false}) async {
    final box = localStorageService.taskBox;
    if (!append) {
      // Preserve any pending offline unsynced tasks before clearing
      final unsynced = <TaskModel>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map && val['is_synced'] == false) {
          unsynced.add(TaskModel.fromCacheMap(val));
        }
      }
      await box.clear();
      for (final task in unsynced) {
        await box.put(task.id.toString(), task.toCacheMap());
      }
    }

    for (final task in tasks) {
      await box.put(task.id.toString(), task.toCacheMap());
    }
  }

  @override
  Future<void> saveCachedTask(TaskModel task) async {
    final box = localStorageService.taskBox;
    await box.put(task.id.toString(), task.toCacheMap());
  }

  @override
  Future<void> deleteCachedTask(dynamic taskId) async {
    final box = localStorageService.taskBox;
    await box.delete(taskId.toString());
  }

  @override
  Future<void> clearCache() async {
    final box = localStorageService.taskBox;
    await box.clear();
  }

  // --- Sync Queue Operations ---

  @override
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final box = localStorageService.syncQueueBox;
    await box.put(item.queueId, item.toMap());
  }

  @override
  Future<List<SyncQueueItem>> getSyncQueue() async {
    final box = localStorageService.syncQueueBox;
    final List<SyncQueueItem> queue = [];

    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        queue.add(SyncQueueItem.fromMap(value));
      }
    }

    queue.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return queue;
  }

  @override
  Future<void> removeFromSyncQueue(String queueId) async {
    final box = localStorageService.syncQueueBox;
    await box.delete(queueId);
  }

  @override
  Future<void> clearSyncQueue() async {
    final box = localStorageService.syncQueueBox;
    await box.clear();
  }
}
