import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on startup to load saved theme mode from local Hive storage.
class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

/// Dispatched when the user explicitly changes the theme mode.
class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

/// Dispatched after Firestore user profile is loaded with the remote theme setting.
class SyncThemeFromRemoteEvent extends ThemeEvent {
  final String themeModeString; // 'light', 'dark', 'system'

  const SyncThemeFromRemoteEvent({required this.themeModeString});

  @override
  List<Object?> get props => [themeModeString];
}
