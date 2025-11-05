import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/task.dart';
import '../providers.dart';
import '../viewmodels/share_controller.dart';
import '../viewmodels/paginated_task_controller.dart';
import '../viewmodels/task_list_controller.dart';
import '../viewmodels/filter_controller.dart';

import '../viewmodels/task_list_provider.dart';
import '../widgets/task_input.dart';
import '../widgets/task_item.dart';
import 'task_detail_page.dart';

enum TaskStatus { all, completed, pending }

class HomePage extends ConsumerWidget {

  const HomePage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(paginatedTaskControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final id = await _promptForTaskId(context);
              if (id != null) {
                // Join the task
                await ref.read(shareControllerProvider.notifier).joinTask(taskId: id);

                // Refresh task list so the UI updates immediately
                ref.refresh(taskListProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined task successfully!')),
                  );
                }
              }
            },
            icon: const Icon(Icons.link),
            tooltip: 'Join by ID/Link',
          )

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TaskInput(
              onSubmit: (text) => ref.read(taskListControllerProvider.notifier).addTask(text),
            ),
            const SizedBox(height: 12),
            const _FiltersBar(),
            const SizedBox(height: 8),
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (tasks) => Column(
                  children: [
                    TaskSummarySection(tasks: tasks),
                    const SizedBox(height: 8),
                    Expanded(child: _TaskListAsync(tasksAsync: tasksAsync)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForTaskId(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Task ID or Link'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'tasksapp://task/<id> or <id>',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

// -------------------- TASK SUMMARY --------------------
class TaskSummarySection extends ConsumerWidget {
  final List<Task> tasks;

  const TaskSummarySection({super.key, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = tasks.where((t) => !t.isCompleted).length;
    final totalCount = tasks.length;

    final filterCtrl = ref.read(taskFilterControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _AnimatedSummaryBox(
            title: 'Completed',
            count: completedCount,
            color: Colors.green,
            icon: Icons.check_circle,
            onTap: () => filterCtrl.setShowStatus(TaskStatus.completed),
          ),
          _AnimatedSummaryBox(
            title: 'Pending',
            count: pendingCount,
            color: Colors.orange,
            icon: Icons.schedule,
            onTap: () => filterCtrl.setShowStatus(TaskStatus.pending),
          ),
          _AnimatedSummaryBox(
            title: 'Total',
            count: totalCount,
            color: Colors.blueAccent,
            icon: Icons.list_alt,
            onTap: () => filterCtrl.setShowStatus(TaskStatus.all),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSummaryBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _AnimatedSummaryBox({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$count',
                  key: ValueKey(count),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- TASK LIST --------------------
class _TaskListAsync extends ConsumerStatefulWidget {
  final AsyncValue<List<Task>> tasksAsync;

  const _TaskListAsync({required this.tasksAsync});

  @override
  ConsumerState<_TaskListAsync> createState() => _TaskListAsyncState();
}

class _TaskListAsyncState extends ConsumerState<_TaskListAsync> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  StreamSubscription<List<Task>>? _taskUpdatesSub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _listenToTaskUpdates();
  }
  void _listenToTaskUpdates() async {
    final currentUserId = await getCurrentUserId();

    _taskUpdatesSub = ref
        .read(shareControllerProvider.notifier)
        .userTasksStream(currentUserId)
        .listen((updatedTasks) {
      for (final updatedTask in updatedTasks) {
        if (updatedTask.lastUpdatedById != currentUserId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Task "${updatedTask.title}" was updated by another user'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }

        // ✅ Update only that specific task in the paginated list
        ref
            .read(paginatedTaskControllerProvider.notifier)
            .updateTask(updatedTask);
      }
    });
  }

  // void _listenToTaskUpdates() async {
  //   final currentUserId = await ref.read(currentUserIdProvider.future);
  //
  //   _taskUpdatesSub = ref.read(shareControllerProvider.notifier)
  //       .userTasksStream(currentUserId)
  //       .listen((updatedTasks) {
  //     for (final task in updatedTasks) {
  //       if (task.lastUpdatedById != currentUserId) {
  //         // Show SnackBar if task was updated by another user
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Task "${task.title}" was updated by another user'),
  //               duration: const Duration(seconds: 2),
  //               behavior: SnackBarBehavior.floating,
  //               backgroundColor: Colors.blueAccent,
  //             ),
  //           );
  //         }
  //       }
  //       // Update only the edited task in the UI
  //       ref.read(paginatedTaskControllerProvider.notifier).updateTask(task);
  //     }
  //
  //
  //   });
  // }
  void _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200 && !_isLoadingMore) {
      _isLoadingMore = true;
      await ref.read(paginatedTaskControllerProvider.notifier).loadMore();
      _isLoadingMore = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (tasks) {
        final filters = ref.watch(taskFilterControllerProvider);
        final filtered = _applyFilters(tasks, filters);
        if (filtered.isEmpty) return const _EmptyState();

        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final task = filtered[index];
            // Check if the task was updated by another user
            // final isExternalUpdate = task.lastUpdatedBy.isNotEmpty && task.lastUpdatedBy != currentUser.name;
            //
            // if (isExternalUpdate) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: Text('Task "${task.title}" was updated by ${task.lastUpdatedBy}'),
            //         backgroundColor: Colors.blue,
            //       ),
            //     );
            //   });
            // }

            return TaskItem(
              task: task,
              onToggle: () => ref.read(paginatedTaskControllerProvider.notifier).toggleComplete(task),
              onDelete: () async {
                await ref.read(paginatedTaskControllerProvider.notifier).deleteTask(task.id);
                final updatedList = [...tasks]..removeAt(index);
                ref.read(paginatedTaskControllerProvider.notifier).state = AsyncValue.data(updatedList);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${task.title}" deleted'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              onShare: () => ref.read(shareControllerProvider.notifier).shareTaskLink(taskId: task.id),
              onEdit: (updated) => ref.read(paginatedTaskControllerProvider.notifier).updateTask(updated),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
                );
              },

            );
          },
        );
      },
    );
  }
}

List<Task> _applyFilters(List<Task> tasks, TaskFilters f) {
  return tasks.where((t) {
    final matchesText = f.searchText.isEmpty ||
        t.title.toLowerCase().contains(f.searchText.toLowerCase()) ||
        (t.description ?? '').toLowerCase().contains(f.searchText.toLowerCase());

    final matchesPriority = f.priorities.isEmpty || f.priorities.contains(t.priority);
    final matchesLabels = f.labels.isEmpty || f.labels.every((lbl) => t.labels.contains(lbl));
    final matchesDueFrom = f.dueFrom == null || (t.dueDate != null && !t.dueDate!.isBefore(f.dueFrom!));
    final matchesDueTo = f.dueTo == null || (t.dueDate != null && !t.dueDate!.isAfter(f.dueTo!));

    final matchesStatus = switch (f.showStatus) {
      TaskStatus.all => true,
      TaskStatus.completed => t.isCompleted,
      TaskStatus.pending => !t.isCompleted,
    };

    return matchesText && matchesPriority && matchesLabels && matchesDueFrom && matchesDueTo && matchesStatus;
  }).toList();
}

// -------------------- FILTERS & EMPTY STATE --------------------
class _FiltersBar extends ConsumerWidget {
  const _FiltersBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(taskFilterControllerProvider);
    final ctrl = ref.read(taskFilterControllerProvider.notifier);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search tasks...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: ctrl.setSearchText,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildChip('Low', 0, filters, ctrl),
                _buildChip('Normal', 1, filters, ctrl),
                _buildChip('High', 2, filters, ctrl),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  ctrl.setDueFrom(picked.start);
                  ctrl.setDueTo(picked.end);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                filters.dueFrom == null && filters.dueTo == null
                    ? 'Any due date'
                    : '${filters.dueFrom?.toLocal().toString().split(' ').first ?? ''} - ${filters.dueTo?.toLocal().toString().split(' ').first ?? ''}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, int priority, TaskFilters filters, TaskFilterController ctrl) {
    final selected = filters.priorities.contains(priority);
    final color = switch (priority) {
      0 => Colors.green,
      1 => Colors.orange,
      2 => Colors.red,
      _ => Colors.blue,
    };
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      onSelected: (_) => ctrl.togglePriority(priority),
      avatar: Icon(Icons.circle, color: color, size: 10),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start adding tasks to stay organized ✨',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
