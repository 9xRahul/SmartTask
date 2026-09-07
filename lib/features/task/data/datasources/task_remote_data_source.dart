import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_list_response_model.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskListResponseModel> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  });

  Future<TaskModel> getTaskById({
    required String userId,
    required dynamic taskId,
  });

  Future<TaskModel> createTask({
    required String userId,
    required TaskModel task,
  });

  Future<TaskModel> updateTask({
    required String userId,
    required TaskModel task,
  });

  Future<void> deleteTask({
    required String userId,
    required dynamic taskId,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient dioClient;

  TaskRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<TaskListResponseModel> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    final response = await dioClient.get(
      ApiEndpoints.tasks,
      queryParameters: {
        'user_id': userId,
        'skip': skip,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TaskListResponseModel.fromJson(data);
    } else if (data is List) {
      // Fallback in case raw list is returned
      final tasks = data
          .whereType<Map<String, dynamic>>()
          .map((item) => TaskModel.fromJson(item))
          .toList();
      return TaskListResponseModel(
        status: 'success',
        message: 'Tasks retrieved successfully',
        tasks: tasks,
        total: tasks.length,
      );
    }
    throw Exception('Unexpected response format from getTasks API');
  }

  @override
  Future<TaskModel> getTaskById({
    required String userId,
    required dynamic taskId,
  }) async {
    final response = await dioClient.get(
      ApiEndpoints.taskById(taskId),
      queryParameters: {
        'user_id': userId,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TaskModel.fromJson(data);
    }
    throw Exception('Unexpected response format from getTaskById API');
  }

  @override
  Future<TaskModel> createTask({
    required String userId,
    required TaskModel task,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.tasks,
      data: task.toCreateJson(),
      queryParameters: {
        'user_id': userId,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TaskModel.fromJson(data);
    }
    throw Exception('Unexpected response format from createTask API');
  }

  @override
  Future<TaskModel> updateTask({
    required String userId,
    required TaskModel task,
  }) async {
    final response = await dioClient.put(
      ApiEndpoints.taskById(task.id),
      data: task.toUpdateJson(),
      queryParameters: {
        'user_id': userId,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TaskModel.fromJson(data);
    }
    throw Exception('Unexpected response format from updateTask API');
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required dynamic taskId,
  }) async {
    await dioClient.delete(
      ApiEndpoints.taskById(taskId),
      queryParameters: {
        'user_id': userId,
      },
    );
  }
}
