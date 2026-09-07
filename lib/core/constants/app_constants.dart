/// Application-wide constants including pagination limits, cache keys, and collection names.
class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Task Manager';

  // Firestore Collections
  static const String usersCollection = 'users';

  // Hive Box Names
  static const String taskBoxName = 'tasks_cache_box';
  static const String syncQueueBoxName = 'task_sync_queue_box';
  static const String settingsBoxName = 'app_settings_box';

  // Cache Keys
  static const String themeModeKey = 'app_theme_mode';
  static const String cachedUserIdKey = 'cached_user_id';
  static const String cachedUserNameKey = 'cached_user_name';

  // Pagination defaults
  static const int defaultPageLimit = 10;
  static const int defaultInitialSkip = 0;

  // Search debounce duration
  static const Duration searchDebounceDuration = Duration(milliseconds: 400);

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
