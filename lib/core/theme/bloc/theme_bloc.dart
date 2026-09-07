import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/local_storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC responsible for persisting and dynamically switching application themes.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorageService localStorageService;

  ThemeBloc({required this.localStorageService})
    : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<SyncThemeFromRemoteEvent>(_onSyncThemeFromRemote);
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) {
    final savedMode = localStorageService.getSavedThemeMode();
    emit(state.copyWith(themeMode: savedMode));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    String themeStr = 'system';
    if (event.themeMode == ThemeMode.dark) {
      themeStr = 'dark';
    } else if (event.themeMode == ThemeMode.light) {
      themeStr = 'light';
    }
    await localStorageService.saveThemeMode(themeStr);
  }

  Future<void> _onSyncThemeFromRemote(
    SyncThemeFromRemoteEvent event,
    Emitter<ThemeState> emit,
  ) async {
    ThemeMode mode = ThemeMode.system;
    if (event.themeModeString == 'dark') {
      mode = ThemeMode.dark;
    } else if (event.themeModeString == 'light') {
      mode = ThemeMode.light;
    }
    emit(state.copyWith(themeMode: mode));
    await localStorageService.saveThemeMode(event.themeModeString);
  }
}
