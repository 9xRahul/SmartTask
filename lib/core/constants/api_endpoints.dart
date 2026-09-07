/// Centralized API endpoint constants for the Task Manager API.
class ApiEndpoints {
  ApiEndpoints._();

  /// Primary base URL as defined in the assessment documentation.
  static const String baseUrl = 'https://taskmanager.uat-lplusltd.com';

  /// Tasks endpoints
  static const String tasks = '/tasks/';

  /// Helper to get single task endpoint or update/delete endpoint
  static String taskById(dynamic taskId) => '/tasks/$taskId';
}
