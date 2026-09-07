import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

enum TaskFilterType { all, completed, pending }
enum TaskSortType { createdDate, dueDate, priority }

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load the initial batch of tasks or refresh via pull-to-refresh
class FetchTasksEvent extends TaskEvent {
  final String userId;
  final bool forceRefresh;

  const FetchTasksEvent({
    required this.userId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, forceRefresh];
}

/// Dispatched by infinite scroll pagination when user reaches bottom of the list
class LoadMoreTasksEvent extends TaskEvent {
  final String userId;

  const LoadMoreTasksEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Dispatched to create a new task
class CreateTaskEvent extends TaskEvent {
  final String userId;
  final TaskEntity task;

  const CreateTaskEvent({
    required this.userId,
    required this.task,
  });

  @override
  List<Object?> get props => [userId, task];
}

/// Dispatched to update an existing task
class UpdateTaskEvent extends TaskEvent {
  final String userId;
  final TaskEntity task;

  const UpdateTaskEvent({
    required this.userId,
    required this.task,
  });

  @override
  List<Object?> get props => [userId, task];
}

/// Dispatched to toggle task completion status (is_completed) optimistically
class ToggleTaskCompletionEvent extends TaskEvent {
  final String userId;
  final TaskEntity task;

  const ToggleTaskCompletionEvent({
    required this.userId,
    required this.task,
  });

  @override
  List<Object?> get props => [userId, task];
}

/// Dispatched to delete a task
class DeleteTaskEvent extends TaskEvent {
  final String userId;
  final dynamic taskId;

  const DeleteTaskEvent({
    required this.userId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [userId, taskId];
}

/// Dispatched when search query text changes (debounced)
class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Dispatched when switching filter tabs: All, Completed, Pending
class FilterTasksEvent extends TaskEvent {
  final TaskFilterType filter;

  const FilterTasksEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Dispatched when changing sorting criteria: Due Date, Priority, Created Date
class SortTasksEvent extends TaskEvent {
  final TaskSortType sort;

  const SortTasksEvent({required this.sort});

  @override
  List<Object?> get props => [sort];
}

/// Dispatched when internet connection is restored or user taps sync button
class SyncOfflineTasksEvent extends TaskEvent {
  final String userId;

  const SyncOfflineTasksEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Dispatched when device connectivity status changes
class ConnectivityChangedEvent extends TaskEvent {
  final bool isConnected;

  const ConnectivityChangedEvent({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

/// Dispatched to clear transient action messages and errors after presentation
class ClearTaskActionMessageEvent extends TaskEvent {
  const ClearTaskActionMessageEvent();
}

