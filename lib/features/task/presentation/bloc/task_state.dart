import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import 'task_event.dart';

enum TaskStatus { initial, loading, loaded, loadingMore, error }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskFilterType activeFilter;
  final TaskSortType activeSort;
  final String searchQuery;
  final bool hasReachedMax;
  final bool isSyncing;
  final bool isOffline;
  final bool isSavingTask;
  final String? errorMessage;
  final String? actionMessage;
  final String? actionError;

  const TaskState({
    this.status = TaskStatus.initial,
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.activeFilter = TaskFilterType.all,
    this.activeSort = TaskSortType.createdDate,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.isSyncing = false,
    this.isOffline = false,
    this.isSavingTask = false,
    this.errorMessage,
    this.actionMessage,
    this.actionError,
  });

  // Summary helper getters
  int get totalTasksCount => allTasks.length;
  int get completedTasksCount => allTasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => allTasks.where((t) => !t.isCompleted).length;
  int get totalCount => totalTasksCount;
  int get completedCount => completedTasksCount;
  int get pendingCount => pendingTasksCount;
  double get completionPercentage =>
      allTasks.isEmpty ? 0.0 : completedTasksCount / totalTasksCount;

  TaskState copyWith({
    TaskStatus? status,
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskFilterType? activeFilter,
    TaskSortType? activeSort,
    String? searchQuery,
    bool? hasReachedMax,
    bool? isSyncing,
    bool? isOffline,
    bool? isSavingTask,
    String? errorMessage,
    String? actionMessage,
    String? actionError,
    bool clearActionMessage = false,
    bool clearActionError = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeFilter: activeFilter ?? this.activeFilter,
      activeSort: activeSort ?? this.activeSort,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      isSavingTask: isSavingTask ?? this.isSavingTask,
      errorMessage: errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTasks,
        filteredTasks,
        activeFilter,
        activeSort,
        searchQuery,
        hasReachedMax,
        isSyncing,
        isOffline,
        isSavingTask,
        errorMessage,
        actionMessage,
        actionError,
      ];
}
