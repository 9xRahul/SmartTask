import 'package:uuid/uuid.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/sync_queue_item.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid _uuid = const Uuid();

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<TaskEntity>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final bool isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final responseModel = await remoteDataSource.getTasks(
          userId: userId,
          skip: skip,
          limit: limit,
        );

        // Cache newly retrieved tasks locally
        await localDataSource.cacheTasks(
          responseModel.tasks,
          append: skip > 0,
        );

        return await localDataSource.getCachedTasks();
      } catch (e) {
        // Fallback to local cache on API failure
        final cached = await localDataSource.getCachedTasks();
        if (cached.isNotEmpty) {
          return cached;
        }
        if (e is AppException) rethrow;
        throw ServerException(message: 'Failed to retrieve tasks from server: $e');
      }
    } else {
      // Offline mode: load directly from local Hive cache
      final cached = await localDataSource.getCachedTasks();
      return cached;
    }
  }

  @override
  Future<TaskEntity> getTaskById({
    required String userId,
    required dynamic taskId,
  }) async {
    final bool isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final model = await remoteDataSource.getTaskById(
          userId: userId,
          taskId: taskId,
        );
        await localDataSource.saveCachedTask(model);
        return model;
      } catch (_) {
        final cached = await localDataSource.getCachedTaskById(taskId);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = await localDataSource.getCachedTaskById(taskId);
      if (cached != null) return cached;
      throw const NetworkException(
        message: 'Task details are not available offline.',
      );
    }
  }

  @override
  Future<TaskEntity> createTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final bool isOnline = await networkInfo.isConnected;
    final taskModel = TaskModel.fromEntity(task);

    if (isOnline) {
      try {
        final remoteCreated = await remoteDataSource.createTask(
          userId: userId,
          task: taskModel,
        );
        await localDataSource.saveCachedTask(remoteCreated);
        return remoteCreated;
      } catch (e) {
        // Fallback to offline queuing if server call fails
        return await _queueOfflineCreate(taskModel);
      }
    } else {
      return await _queueOfflineCreate(taskModel);
    }
  }

  Future<TaskEntity> _queueOfflineCreate(TaskModel taskModel) async {
    final tempId = 'temp_${_uuid.v4()}';
    final offlineTask = TaskModel(
      id: tempId,
      title: taskModel.title,
      description: taskModel.description,
      isCompleted: taskModel.isCompleted,
      priority: taskModel.priority,
      category: taskModel.category,
      dueDate: taskModel.dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await localDataSource.saveCachedTask(offlineTask);

    final queueItem = SyncQueueItem(
      queueId: _uuid.v4(),
      actionType: SyncActionType.create,
      taskId: tempId,
      payload: offlineTask.toCreateJson(),
      timestamp: DateTime.now(),
    );
    await localDataSource.addToSyncQueue(queueItem);

    return offlineTask;
  }

  @override
  Future<TaskEntity> updateTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final bool isOnline = await networkInfo.isConnected;
    final taskModel = TaskModel.fromEntity(task);

    if (isOnline && !task.id.toString().startsWith('temp_')) {
      try {
        final remoteUpdated = await remoteDataSource.updateTask(
          userId: userId,
          task: taskModel,
        );
        await localDataSource.saveCachedTask(remoteUpdated);
        return remoteUpdated;
      } catch (e) {
        return await _queueOfflineUpdate(taskModel);
      }
    } else {
      return await _queueOfflineUpdate(taskModel);
    }
  }

  Future<TaskEntity> _queueOfflineUpdate(TaskModel taskModel) async {
    final offlineTask = TaskModel(
      id: taskModel.id,
      title: taskModel.title,
      description: taskModel.description,
      isCompleted: taskModel.isCompleted,
      priority: taskModel.priority,
      category: taskModel.category,
      dueDate: taskModel.dueDate,
      createdAt: taskModel.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await localDataSource.saveCachedTask(offlineTask);

    final queueItem = SyncQueueItem(
      queueId: _uuid.v4(),
      actionType: SyncActionType.update,
      taskId: taskModel.id,
      payload: offlineTask.toUpdateJson(),
      timestamp: DateTime.now(),
    );
    await localDataSource.addToSyncQueue(queueItem);

    return offlineTask;
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required dynamic taskId,
  }) async {
    final bool isOnline = await networkInfo.isConnected;

    // Remove from local cache optimistically
    await localDataSource.deleteCachedTask(taskId);

    if (isOnline && !taskId.toString().startsWith('temp_')) {
      try {
        await remoteDataSource.deleteTask(userId: userId, taskId: taskId);
      } catch (_) {
        final queueItem = SyncQueueItem(
          queueId: _uuid.v4(),
          actionType: SyncActionType.delete,
          taskId: taskId,
          payload: {},
          timestamp: DateTime.now(),
        );
        await localDataSource.addToSyncQueue(queueItem);
      }
    } else if (!taskId.toString().startsWith('temp_')) {
      final queueItem = SyncQueueItem(
        queueId: _uuid.v4(),
        actionType: SyncActionType.delete,
        taskId: taskId,
        payload: {},
        timestamp: DateTime.now(),
      );
      await localDataSource.addToSyncQueue(queueItem);
    }
  }

  @override
  Future<int> syncOfflineTasks({required String userId}) async {
    final bool isOnline = await networkInfo.isConnected;
    if (!isOnline) return 0;

    final queue = await localDataSource.getSyncQueue();
    if (queue.isEmpty) return 0;

    int syncedCount = 0;

    for (final item in queue) {
      try {
        switch (item.actionType) {
          case SyncActionType.create:
            final createdTask = await remoteDataSource.createTask(
              userId: userId,
              task: TaskModel.fromJson(item.payload),
            );
            // Replace temporary task in cache with official backend task
            await localDataSource.deleteCachedTask(item.taskId);
            await localDataSource.saveCachedTask(createdTask);
            await localDataSource.removeFromSyncQueue(item.queueId);
            syncedCount++;
            break;

          case SyncActionType.update:
            if (!item.taskId.toString().startsWith('temp_')) {
              final payloadWithId = Map<String, dynamic>.from(item.payload);
              payloadWithId['id'] = item.taskId;
              final updatedTask = await remoteDataSource.updateTask(
                userId: userId,
                task: TaskModel.fromJson(payloadWithId),
              );
              await localDataSource.saveCachedTask(updatedTask);
            }
            await localDataSource.removeFromSyncQueue(item.queueId);
            syncedCount++;
            break;

          case SyncActionType.delete:
            if (!item.taskId.toString().startsWith('temp_')) {
              await remoteDataSource.deleteTask(
                userId: userId,
                taskId: item.taskId,
              );
            }
            await localDataSource.removeFromSyncQueue(item.queueId);
            syncedCount++;
            break;
        }
      } catch (_) {
        // Skip and keep in queue for next sync cycle
      }
    }

    return syncedCount;
  }
}
