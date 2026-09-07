import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_category_badge.dart';
import '../widgets/task_priority_badge.dart';
import 'add_edit_task_screen.dart';

/// Detailed view of a single task with full metadata and actions.
class TaskDetailScreen extends StatelessWidget {
  final dynamic taskId;
  final String userId;
  final TaskEntity initialTask;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.userId,
    required this.initialTask,
  });

  void _onDelete(BuildContext context, TaskEntity currentTask) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${currentTask.title}"?'),
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
                      userId: userId,
                      taskId: currentTask.id,
                    ),
                  );
              Navigator.of(context).pop();
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

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Find latest updated task from state or fallback to initialTask
        final currentTask = state.allTasks
                .where((t) => t.id.toString() == taskId.toString())
                .firstOrNull ??
            initialTask;

        final bool isOverdue = DateFormatter.isOverdue(currentTask.dueDate) && !currentTask.isCompleted;
        final bool isSynced = currentTask.isSynced && !state.isOffline;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Task',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(
                        userId: userId,
                        taskToEdit: currentTask,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                tooltip: 'Delete Task',
                onPressed: () => _onDelete(context, currentTask),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Sync Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTask.isCompleted
                        ? AppColors.success.withAlpha(30)
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentTask.isCompleted
                          ? AppColors.success.withAlpha(102)
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentTask.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: currentTask.isCompleted ? AppColors.success : AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTask.isCompleted ? 'Task Completed' : 'Task In Progress',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: currentTask.isCompleted
                                    ? AppColors.success
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                            Text(
                              currentTask.isCompleted
                                  ? 'All objectives finished'
                                  : (isOverdue ? '⚠️ Overdue deadline' : 'Pending completion'),
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue && !currentTask.isCompleted
                                    ? AppColors.error
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: currentTask.isCompleted,
                        activeTrackColor: AppColors.success,
                        onChanged: (_) {
                          context.read<TaskBloc>().add(
                                ToggleTaskCompletionEvent(
                                  userId: userId,
                                  task: currentTask,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  currentTask.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    decoration: currentTask.isCompleted ? TextDecoration.lineThrough : null,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Tags: Priority & Category
                Row(
                  children: [
                    TaskPriorityBadge(priority: currentTask.priority),
                    const SizedBox(width: 8),
                    TaskCategoryBadge(category: currentTask.category),
                    const Spacer(),
                    // Sync badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSynced
                            ? AppColors.success.withAlpha(30)
                            : AppColors.warning.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                            size: 14,
                            color: isSynced ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSynced ? 'Synced' : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSynced ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    currentTask.description.isNotEmpty
                        ? currentTask.description
                        : 'No additional description provided.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: currentTask.description.isNotEmpty
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Due Date Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: _buildDateRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due Date',
                    value: currentTask.dueDate != null
                        ? DateFormatter.formatDateTime(currentTask.dueDate)
                        : 'No due date set',
                    highlight: isOverdue,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Edit Task',
                        icon: Icons.edit_outlined,
                        type: ButtonType.secondary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(
                                userId: userId,
                                taskToEdit: currentTask,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: currentTask.isCompleted ? 'Mark Pending' : 'Complete',
                        icon: currentTask.isCompleted
                            ? Icons.replay_rounded
                            : Icons.check_circle_outline_rounded,
                        onPressed: () {
                          context.read<TaskBloc>().add(
                                ToggleTaskCompletionEvent(
                                  userId: userId,
                                  task: currentTask,
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight
              ? AppColors.error
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            color: highlight
                ? AppColors.error
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
