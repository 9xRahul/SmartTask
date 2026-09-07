import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/sync_offline_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// Central BLoC managing task retrieval, pagination, offline-caching, filtering, and background synchronization.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final SyncOfflineTasksUseCase syncOfflineTasksUseCase;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  String? _activeUserId;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.syncOfflineTasksUseCase,
    required this.connectivityService,
  }) : super(TaskState(isOffline: !connectivityService.isConnected)) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<LoadMoreTasksEvent>(_onLoadMoreTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<SearchTasksEvent>(_onSearchTasks);
    on<FilterTasksEvent>(_onFilterTasks);
    on<SortTasksEvent>(_onSortTasks);
    on<SyncOfflineTasksEvent>(_onSyncOfflineTasks);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    on<ClearTaskActionMessageEvent>(_onClearTaskActionMessage);

    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // 1. Initial state synchronization
    add(ConnectivityChangedEvent(isConnected: connectivityService.isConnected));

    // 2. Perform fresh check asynchronously
    connectivityService.checkConnection().then((isConnected) {
      add(ConnectivityChangedEvent(isConnected: isConnected));
    });

    // 3. Listen to stream for ongoing connectivity changes
    _connectivitySubscription = connectivityService.onConnectivityChanged.listen((isConnected) {
      add(ConnectivityChangedEvent(isConnected: isConnected));
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  // --- Event Handlers ---

  Future<void> _onFetchTasks(
    FetchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    _activeUserId = event.userId;
    final bool isOffline = !connectivityService.isConnected;
    if (!event.forceRefresh && state.allTasks.isEmpty) {
      emit(state.copyWith(status: TaskStatus.loading, isOffline: isOffline));
    }

    try {
      final tasks = await getTasksUseCase(
        userId: event.userId,
        skip: 0,
        limit: AppConstants.defaultPageLimit,
        forceRefresh: event.forceRefresh,
      );

      final filtered = _applyFiltersAndSort(
        tasks,
        state.searchQuery,
        state.activeFilter,
        state.activeSort,
      );

      emit(state.copyWith(
        status: TaskStatus.loaded,
        allTasks: tasks,
        filteredTasks: filtered,
        hasReachedMax: tasks.length < AppConstants.defaultPageLimit,
        isOffline: isOffline,
        clearActionMessage: true,
        clearActionError: true,
      ));

      // Trigger automatic sync if online and had pending offline changes
      if (!isOffline) {
        add(SyncOfflineTasksEvent(userId: event.userId));
      }
    } on AppException catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: e.message,
        isOffline: isOffline,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Failed to load tasks: $e',
        isOffline: isOffline,
      ));
    }
  }

  Future<void> _onLoadMoreTasks(
    LoadMoreTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state.hasReachedMax || state.status == TaskStatus.loadingMore) return;

    emit(state.copyWith(status: TaskStatus.loadingMore));

    try {
      final newTasks = await getTasksUseCase(
        userId: event.userId,
        skip: state.allTasks.length,
        limit: AppConstants.defaultPageLimit,
      );

      if (newTasks.isEmpty) {
        emit(state.copyWith(
          status: TaskStatus.loaded,
          hasReachedMax: true,
        ));
      } else {
        // Merge without duplicate IDs
        final currentMap = {for (final t in state.allTasks) t.id.toString(): t};
        for (final t in newTasks) {
          currentMap[t.id.toString()] = t;
        }
        final mergedTasks = currentMap.values.toList();

        final filtered = _applyFiltersAndSort(
          mergedTasks,
          state.searchQuery,
          state.activeFilter,
          state.activeSort,
        );

        emit(state.copyWith(
          status: TaskStatus.loaded,
          allTasks: mergedTasks,
          filteredTasks: filtered,
          hasReachedMax: newTasks.length < AppConstants.defaultPageLimit,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: TaskStatus.loaded));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(
      isSavingTask: true,
      clearActionMessage: true,
      clearActionError: true,
    ));

    try {
      final created = await createTaskUseCase(
        userId: event.userId,
        task: event.task,
      );

      final updatedList = [created, ...state.allTasks];
      final filtered = _applyFiltersAndSort(
        updatedList,
        state.searchQuery,
        state.activeFilter,
        state.activeSort,
      );

      final message = created.isSynced
          ? 'Task created successfully'
          : 'Task saved offline. Will sync when reconnected.';

      emit(state.copyWith(
        isSavingTask: false,
        allTasks: updatedList,
        filteredTasks: filtered,
        actionMessage: message,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        isSavingTask: false,
        actionError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSavingTask: false,
        actionError: 'Failed to create task: $e',
      ));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(
      isSavingTask: true,
      clearActionMessage: true,
      clearActionError: true,
    ));

    try {
      final updated = await updateTaskUseCase(
        userId: event.userId,
        task: event.task,
      );

      final updatedList = state.allTasks.map((t) {
        return t.id.toString() == updated.id.toString() ? updated : t;
      }).toList();

      final filtered = _applyFiltersAndSort(
        updatedList,
        state.searchQuery,
        state.activeFilter,
        state.activeSort,
      );

      final message = updated.isSynced
          ? 'Task updated successfully'
          : 'Task updated offline. Will sync when reconnected.';

      emit(state.copyWith(
        isSavingTask: false,
        allTasks: updatedList,
        filteredTasks: filtered,
        actionMessage: message,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        isSavingTask: false,
        actionError: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSavingTask: false,
        actionError: 'Failed to update task: $e',
      ));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletionEvent event,
    Emitter<TaskState> emit,
  ) async {
    final bool isOffline = state.isOffline;
    final toggled = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
      isSynced: isOffline ? false : event.task.isSynced,
    );

    // Optimistic UI update
    final optimisticList = state.allTasks.map((t) {
      return t.id.toString() == toggled.id.toString() ? toggled : t;
    }).toList();

    final filtered = _applyFiltersAndSort(
      optimisticList,
      state.searchQuery,
      state.activeFilter,
      state.activeSort,
    );

    emit(state.copyWith(
      allTasks: optimisticList,
      filteredTasks: filtered,
    ));

    try {
      final updatedResult = await updateTaskUseCase(
        userId: event.userId,
        task: toggled,
      );

      final updatedList = state.allTasks.map((t) {
        return t.id.toString() == updatedResult.id.toString() ? updatedResult : t;
      }).toList();

      final updatedFiltered = _applyFiltersAndSort(
        updatedList,
        state.searchQuery,
        state.activeFilter,
        state.activeSort,
      );

      emit(state.copyWith(
        allTasks: updatedList,
        filteredTasks: updatedFiltered,
      ));
    } catch (e) {
      // Revert optimistic update on failure
      final revertedList = state.allTasks.map((t) {
        return t.id.toString() == event.task.id.toString() ? event.task : t;
      }).toList();

      emit(state.copyWith(
        allTasks: revertedList,
        filteredTasks: _applyFiltersAndSort(
          revertedList,
          state.searchQuery,
          state.activeFilter,
          state.activeSort,
        ),
        actionError: 'Could not update completion status: $e',
      ));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final originalList = state.allTasks;
    final updatedList = state.allTasks
        .where((t) => t.id.toString() != event.taskId.toString())
        .toList();

    final filtered = _applyFiltersAndSort(
      updatedList,
      state.searchQuery,
      state.activeFilter,
      state.activeSort,
    );

    // Optimistic deletion
    emit(state.copyWith(
      allTasks: updatedList,
      filteredTasks: filtered,
      actionMessage: 'Task deleted',
    ));

    try {
      await deleteTaskUseCase(
        userId: event.userId,
        taskId: event.taskId,
      );
    } catch (e) {
      // Rollback on fatal error
      emit(state.copyWith(
        allTasks: originalList,
        filteredTasks: _applyFiltersAndSort(
          originalList,
          state.searchQuery,
          state.activeFilter,
          state.activeSort,
        ),
        actionError: 'Failed to delete task: $e',
      ));
    }
  }

  void _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.allTasks,
      event.query,
      state.activeFilter,
      state.activeSort,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredTasks: filtered,
      clearActionMessage: true,
      clearActionError: true,
    ));
  }

  void _onFilterTasks(
    FilterTasksEvent event,
    Emitter<TaskState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.allTasks,
      state.searchQuery,
      event.filter,
      state.activeSort,
    );

    emit(state.copyWith(
      activeFilter: event.filter,
      filteredTasks: filtered,
      clearActionMessage: true,
      clearActionError: true,
    ));
  }

  void _onSortTasks(
    SortTasksEvent event,
    Emitter<TaskState> emit,
  ) {
    final filtered = _applyFiltersAndSort(
      state.allTasks,
      state.searchQuery,
      state.activeFilter,
      event.sort,
    );

    emit(state.copyWith(
      activeSort: event.sort,
      filteredTasks: filtered,
      clearActionMessage: true,
      clearActionError: true,
    ));
  }

  void _onClearTaskActionMessage(
    ClearTaskActionMessageEvent event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      clearActionMessage: true,
      clearActionError: true,
    ));
  }

  Future<void> _onSyncOfflineTasks(
    SyncOfflineTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state.isSyncing || state.isOffline) return;

    emit(state.copyWith(isSyncing: true));

    try {
      final syncedCount = await syncOfflineTasksUseCase(userId: event.userId);
      if (syncedCount > 0) {
        // Refresh task list after syncing offline changes
        final freshTasks = await getTasksUseCase(
          userId: event.userId,
          skip: 0,
          limit: state.allTasks.length > AppConstants.defaultPageLimit
              ? state.allTasks.length
              : AppConstants.defaultPageLimit,
        );

        emit(state.copyWith(
          isSyncing: false,
          allTasks: freshTasks,
          filteredTasks: _applyFiltersAndSort(
            freshTasks,
            state.searchQuery,
            state.activeFilter,
            state.activeSort,
          ),
          actionMessage: 'Synchronized $syncedCount offline item${syncedCount > 1 ? 's' : ''}.',
        ));
      } else {
        emit(state.copyWith(isSyncing: false));
      }
    } catch (_) {
      emit(state.copyWith(isSyncing: false));
    }
  }

  void _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<TaskState> emit,
  ) {
    final wasOffline = state.isOffline;
    final isNowOnline = event.isConnected;

    emit(state.copyWith(isOffline: !isNowOnline));

    // If reconnected to internet, trigger sync
    if (wasOffline && isNowOnline && _activeUserId != null) {
      add(SyncOfflineTasksEvent(userId: _activeUserId!));
    }
  }

  // --- Filtering & Sorting Pure Utility ---

  List<TaskEntity> _applyFiltersAndSort(
    List<TaskEntity> source,
    String query,
    TaskFilterType filter,
    TaskSortType sort,
  ) {
    List<TaskEntity> result = List.from(source);

    // 1. Title Search Filter
    if (query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      result = result.where((t) {
        final titleMatch = t.title.toLowerCase().contains(cleanQuery);
        final descMatch = t.description.toLowerCase().contains(cleanQuery);
        return titleMatch || descMatch;
      }).toList();
    }

    // 2. Completion Status Filter
    switch (filter) {
      case TaskFilterType.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilterType.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilterType.all:
        break;
    }

    // 3. Sorting
    result.sort((a, b) {
      switch (sort) {
        case TaskSortType.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);

        case TaskSortType.priority:
          return b.priority.sortWeight.compareTo(a.priority.sortWeight);

        case TaskSortType.createdDate:
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
      }
    });

    return result;
  }
}
