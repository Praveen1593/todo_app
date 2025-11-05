import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../providers.dart';
import '../repositories/task_repository.dart';
import '../views/home_page.dart';

class TaskListController extends AutoDisposeAsyncNotifier<List<Task>> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  String? _lastId;

  @override
  Future<List<Task>> build() async {
    final userId = await ref.read(currentUserIdProvider.future);
    // Initial load from stream provider keeps realtime updates
    final stream = ref.read(taskStreamProvider.stream);
    final first = await stream.first;
    return first;
  }

  Future<void> addTask(String title) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final newTask = Task.newTask(id: const Uuid().v4(), ownerId: userId, title: title);
    await _repo.createTask(newTask);
  }

  Future<void> toggleComplete(Task task) async {
    await _repo.updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
  }

  Future<void> updateTask(Task task) async {
    await _repo.updateTask(task);
  }

}

final taskListControllerProvider = AutoDisposeAsyncNotifierProvider<TaskListController, List<Task>>(
  TaskListController.new,
);


