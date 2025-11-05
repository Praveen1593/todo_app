import 'dart:async';

import '../models/task.dart';
import 'task_service.dart';

class MemoryTaskService implements TaskService {
  final Map<String, Task> _tasks = {};
  final StreamController<List<Task>> _controller = StreamController.broadcast();

  MemoryTaskService() {
    _emit();
  }

  void _emit() {
    _controller.add(_tasks.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Task> createTask({required Task task}) async {
    _tasks[task.id] = task;
    _emit();
    return task;
  }

  @override
  Future<void> deleteTask({required String taskId}) async {
    _tasks.remove(taskId);
    _emit();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return _tasks[id];
  }

  @override
  Future<void> shareTaskWithUser({required String taskId, required String userId}) async {
    final existing = _tasks[taskId];
    if (existing == null) return;
    if (!existing.sharedWithUserIds.contains(userId)) {
      _tasks[taskId] = existing.copyWith(
        sharedWithUserIds: [...existing.sharedWithUserIds, userId],
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> updateTask({required Task task}) async {
    _tasks[task.id] = task.copyWith(updatedAt: DateTime.now());
    _emit();
  }

  @override
  Stream<List<Task>> watchTasksForUser({required String userId, int limit = 20, String? startAfterId}) {
    return _controller.stream.map((all) {
      final filtered = all
          .where((t) => t.ownerId == userId || t.sharedWithUserIds.contains(userId))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (startAfterId != null) {
        final idx = filtered.indexWhere((t) => t.id == startAfterId);
        final start = idx >= 0 ? idx + 1 : 0;
        final slice = filtered.skip(start).take(limit).toList();
        return slice;
      }
      return filtered.take(limit).toList();
    });
  }

  Stream<Task> watchTaskById({required String taskId}) {
    return _controller.stream.map((allTasks) {
      final task = allTasks.firstWhere((t) => t.id == taskId);
      return task;
    });
  }
}


