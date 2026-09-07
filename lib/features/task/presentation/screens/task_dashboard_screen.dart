import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/task_search_bar.dart';
import '../widgets/task_sort_bottom_sheet.dart';
import '../widgets/task_summary_card.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

/// Main Dashboard screen presenting task metrics, paginated list, search, and filtering.
class TaskDashboardScreen extends StatefulWidget {
  final UserProfileEntity currentUser;

  const TaskDashboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial fetch of tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(
            FetchTasksEvent(userId: widget.currentUser.id),
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TaskBloc>().add(
            LoadMoreTasksEvent(userId: widget.currentUser.id),
          );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<TaskBloc>().add(
          FetchTasksEvent(userId: widget.currentUser.id, forceRefresh: true),
        );
  }

  void _openSortBottomSheet(TaskSortType currentSort) {
    TaskSortBottomSheet.show(
      context,
      currentSort: currentSort,
      onSortSelected: (newSort) {
        context.read<TaskBloc>().add(SortTasksEvent(sort: newSort));
      },
    );
  }

  void _confirmDeleteTask(dynamic taskId, String title) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<TaskBloc>().add(
                    DeleteTaskEvent(
                      userId: widget.currentUser.id,
                      taskId: taskId,
                    ),
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.actionMessage != null) {
          CustomSnackBar.showSuccess(context, message: state.actionMessage!);
          context.read<TaskBloc>().add(const ClearTaskActionMessageEvent());
        }
        if (state.actionError != null) {
          CustomSnackBar.showError(context, message: state.actionError!);
          context.read<TaskBloc>().add(const ClearTaskActionMessageEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.currentUser.name} 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Manage your tasks effortlessly',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Sync Offline Changes',
                onPressed: state.isSyncing
                    ? null
                    : () {
                        context.read<TaskBloc>().add(
                              SyncOfflineTasksEvent(userId: widget.currentUser.id),
                            );
                      },
              ),
              IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: isDark
                      ? AppColors.primaryContainerDark
                      : AppColors.primaryContainerLight,
                  child: Text(
                    widget.currentUser.name.isNotEmpty
                        ? widget.currentUser.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
                tooltip: 'Profile Settings',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(currentUser: widget.currentUser),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Offline status banner
              OfflineBanner(
                isOffline: state.isOffline,
                isSyncing: state.isSyncing,
                onSyncPressed: () {
                  context.read<TaskBloc>().add(
                        SyncOfflineTasksEvent(userId: widget.currentUser.id),
                      );
                },
              ),

              // Animated Overall Progress Card (collapses when scrolling down, re-appears when scrolling up or at rest)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                clipBehavior: Clip.hardEdge,
                child: _isScrolled
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                        child: TaskSummaryCard(
                          totalCount: state.totalTasksCount,
                          completedCount: state.completedTasksCount,
                          pendingCount: state.pendingCount,
                          completionPercentage: state.completionPercentage,
                        ),
                      ),
              ),

              // Pinned Search Bar & Filter Tabs (solid background, stays fixed on top)
              Container(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskSearchBar(
                      onSearchChanged: (query) {
                        context.read<TaskBloc>().add(SearchTasksEvent(query: query));
                      },
                      onSortPressed: () => _openSortBottomSheet(state.activeSort),
                    ),
                    const SizedBox(height: 6),
                    TaskFilterChips(
                      activeFilter: state.activeFilter,
                      onFilterSelected: (filter) {
                        context.read<TaskBloc>().add(FilterTasksEvent(filter: filter));
                      },
                      totalCount: state.totalTasksCount,
                      pendingCount: state.pendingCount,
                      completedCount: state.completedTasksCount,
                    ),
                  ],
                ),
              ),

              // Scrollable Tasks List with UserScrollNotification listener
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse &&
                        _scrollController.hasClients &&
                        _scrollController.offset > 20) {
                      if (!_isScrolled) {
                        setState(() => _isScrolled = true);
                      }
                    } else if (notification.direction == ScrollDirection.forward ||
                        (_scrollController.hasClients && _scrollController.offset <= 10)) {
                      if (_isScrolled) {
                        setState(() => _isScrolled = false);
                      }
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    child: _buildBodyContent(context, state, isDark),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(
                    userId: widget.currentUser.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, TaskState state, bool isDark) {
    if (state.status == TaskStatus.loading) {
      return const LoadingIndicator(message: 'Loading your tasks...');
    }

    if (state.status == TaskStatus.error && state.allTasks.isEmpty) {
      return ErrorView(
        message: state.errorMessage ?? 'Failed to load tasks',
        onRetry: () {
          context.read<TaskBloc>().add(
                FetchTasksEvent(userId: widget.currentUser.id, forceRefresh: true),
              );
        },
      );
    }

    // Tasks List or Empty State
    if (state.filteredTasks.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: EmptyStateView(
              title: state.searchQuery.isNotEmpty
                  ? 'No matching tasks'
                  : (state.activeFilter == TaskFilterType.completed
                      ? 'No completed tasks yet'
                      : 'No tasks found'),
              message: state.searchQuery.isNotEmpty
                  ? 'We couldn\'t find any task matching "${state.searchQuery}". Try a different keyword.'
                  : 'Start by creating your first task to stay organized.',
              actionText: state.searchQuery.isEmpty ? 'Create Task' : null,
              onAction: state.searchQuery.isEmpty
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTaskScreen(
                            userId: widget.currentUser.id,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 80.0),
      itemCount: state.filteredTasks.length + (state.status == TaskStatus.loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.filteredTasks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        final task = state.filteredTasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(
                  taskId: task.id,
                  userId: widget.currentUser.id,
                  initialTask: task,
                ),
              ),
            );
          },
          onToggleComplete: () {
            context.read<TaskBloc>().add(
                  ToggleTaskCompletionEvent(
                    userId: widget.currentUser.id,
                    task: task,
                  ),
                );
          },
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(
                  userId: widget.currentUser.id,
                  taskToEdit: task,
                ),
              ),
            );
          },
          onDelete: () => _confirmDeleteTask(task.id, task.title),
        );
      },
    );
  }
}
