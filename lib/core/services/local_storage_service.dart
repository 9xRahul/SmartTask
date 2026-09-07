import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Central service managing Hive local storage boxes and app preferences.
class LocalStorageService {
  late Box _settingsBox;
  late Box _taskBox;
  late Box _syncQueueBox;

  Box get settingsBox => _settingsBox;
  Box get taskBox => _taskBox;
  Box get syncQueueBox => _syncQueueBox;

  /// Initialize Hive and open all essential application boxes.
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      _taskBox = await Hive.openBox(AppConstants.taskBoxName);
      _syncQueueBox = await Hive.openBox(AppConstants.syncQueueBoxName);
    } catch (e) {
      throw CacheException(message: 'Failed to initialize local Hive storage: $e');
    }
  }

  // --- Theme Mode Preferences ---

  /// Save preferred theme mode ('light', 'dark', 'system')
  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox.put(AppConstants.themeModeKey, themeMode);
  }

  /// Retrieve saved theme mode, defaulting to ThemeMode.system
  ThemeMode getSavedThemeMode() {
    final String? themeStr = _settingsBox.get(AppConstants.themeModeKey) as String?;
    switch (themeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // --- Cached User Profile Information ---

  Future<void> saveCachedUser({required String userId, required String name}) async {
    await _settingsBox.put(AppConstants.cachedUserIdKey, userId);
    await _settingsBox.put(AppConstants.cachedUserNameKey, name);
  }

  String? getCachedUserId() {
    return _settingsBox.get(AppConstants.cachedUserIdKey) as String?;
  }

  String? getCachedUserName() {
    return _settingsBox.get(AppConstants.cachedUserNameKey) as String?;
  }

  Future<void> clearUserCache() async {
    await _settingsBox.delete(AppConstants.cachedUserIdKey);
    await _settingsBox.delete(AppConstants.cachedUserNameKey);
    await _taskBox.clear();
    await _syncQueueBox.clear();
  }
}
