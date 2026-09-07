import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

/// Screen for creating a new task or modifying an existing task.
class AddEditTaskScreen extends StatefulWidget {
  final String userId;
  final TaskEntity? taskToEdit;

  const AddEditTaskScreen({
    super.key,
    required this.userId,
    this.taskToEdit,
  });

  bool get isEditing => taskToEdit != null;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedCategory = task?.category ?? TaskCategory.work;
    _isCompleted = task?.isCompleted ?? false;

    if (task?.dueDate != null) {
      _selectedDueDate = task!.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(task.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDueTime ?? TimeOfDay.now(),
      );

      setState(() {
        _selectedDueDate = pickedDate;
        _selectedDueTime = pickedTime;
      });
    }
  }

  DateTime? _combineDateAndTime() {
    if (_selectedDueDate == null) return null;
    final date = _selectedDueDate!;
    final time = _selectedDueTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      final fullDueDate = _combineDateAndTime();

      if (widget.isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: fullDueDate,
          isCompleted: _isCompleted,
        );

        context.read<TaskBloc>().add(
              UpdateTaskEvent(
                userId: widget.userId,
                task: updatedTask,
              ),
            );
      } else {
        final newTask = TaskEntity(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: fullDueDate,
          isCompleted: _isCompleted,
        );

        context.read<TaskBloc>().add(
              CreateTaskEvent(
                userId: widget.userId,
                task: newTask,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.actionMessage != null) {
          CustomSnackBar.showSuccess(context, message: state.actionMessage!);
          Navigator.of(context).pop();
        } else if (state.actionError != null) {
          CustomSnackBar.showError(context, message: state.actionError!);
        }
      },
      builder: (context, state) {
        final isSaving = state.isSavingTask;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing ? 'Edit Task' : 'Create New Task',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Task Title *',
                    hintText: 'e.g. Finish project proposal',
                    prefixIcon: Icons.title_rounded,
                    validator: Validators.validateTaskTitle,
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 18),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Add details, notes, or checklist items...',
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 20),

                  // Priority Selector
                  Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((priority) {
                      final bool isSelected = _selectedPriority == priority;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: isSaving
                                ? null
                                : () => setState(() => _selectedPriority = priority),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? priority.color.withAlpha(46)
                                    : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? priority.color
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(priority.icon, size: 16, color: priority.color),
                                  const SizedBox(width: 6),
                                  Text(
                                    priority.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected
                                          ? priority.color
                                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskCategory.values.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          category.icon,
                          size: 16,
                          color: isSelected ? Colors.white : category.color,
                        ),
                        label: Text(category.name),
                        selected: isSelected,
                        selectedColor: category.color,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                        onSelected: isSaving
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() => _selectedCategory = category);
                                }
                              },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Due Date & Time Picker
                  Text(
                    'Due Date & Time',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: isSaving ? null : _pickDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDueDate == null
                                  ? 'Set due date (optional)'
                                  : '${DateFormatter.formatDate(_selectedDueDate)}'
                                      '${_selectedDueTime != null ? ' • ${_selectedDueTime!.format(context)}' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDueDate == null
                                    ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                          ),
                          if (_selectedDueDate != null)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedDueDate = null;
                                        _selectedDueTime = null;
                                      });
                                    },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Completion Status (if editing)
                  if (widget.isEditing) ...[
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Mark as Completed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        _isCompleted ? 'Task marked complete' : 'Task is currently pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      value: _isCompleted,
                      activeTrackColor: AppColors.success,
                      onChanged: isSaving ? null : (val) => setState(() => _isCompleted = val),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Save Button with Loading Spinner
                  CustomButton(
                    text: widget.isEditing ? 'Update Task' : 'Create Task',
                    icon: widget.isEditing ? Icons.check_circle_outline_rounded : Icons.add_task_rounded,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : _onSavePressed,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
