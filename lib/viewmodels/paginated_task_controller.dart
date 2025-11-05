import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasks_app/viewmodels/task_list_controller.dart';
import '../main.dart';
import '../models/task.dart';
import '../providers.dart';
import '../repositories/task_repository.dart';

class PaginatedTaskController extends AutoDisposeNotifier<AsyncValue<List<Task>>> {
  static const int _pageSize = 20;

  TaskRepository get _repo => ref.read(taskRepositoryProvider);
  String? _userId;
  int _limit = _pageSize;
  StreamSubscription<List<Task>>? _sub;

  /// Local copy of tasks to manage UI updates without refetching
  List<Task> _allTasks = [];

  @override
  AsyncValue<List<Task>> build() {
    _listen();
    return const AsyncValue.loading();
  }

  Future<void> _listen({bool append = false}) async {
    _userId = await ref.read(currentUserIdProvider.future);

    // Cancel previous subscription if this is first load
    if (!append) _sub?.cancel();

    if (!append) state = const AsyncValue.loading();

    _sub = _repo.watchTasksForUser(userId: _userId!, limit: _limit).listen(
          (list) {
        if (append && state is AsyncData<List<Task>>) {
          final oldList = state.value!;
          state = AsyncValue.data([...oldList, ...list.skip(oldList.length)]);
        } else {
          state = AsyncValue.data(list);
        }
      },
      onError: (e, st) => state = AsyncValue.error(e, st),
    );
  }

  Future<void> loadMore() async {
    _limit += _pageSize;
    await _listen(append: true);
  }


  Future<void> refresh() async {
    _limit = _pageSize; // reset pagination
    await _listen();
  }



  Future<void> addTask(String title) async {
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(taskListControllerProvider.notifier).addTask(title);
    // Optionally, we can refresh here to include the new task
     await refresh();
  }

  Future<void> toggleComplete(Task task) async {
    await ref.read(taskListControllerProvider.notifier).toggleComplete(task);
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      state = AsyncValue.data([..._allTasks]);
    }
  }
  /// <-- Add this method for real-time updates
  void setTasks(List<Task> tasks) {
    state = AsyncValue.data(tasks);
  }
  Future<void> deleteTask(String id) async {
    await ref.read(taskListControllerProvider.notifier).deleteTask(id);
    _allTasks.removeWhere((task) => task.id == id);
    state = AsyncValue.data([..._allTasks]);
  }

  // Future<void> updateTask(Task task, {String? title, String? description}) async {
  //   final updated = task.copyWith(
  //     title: title ?? task.title,
  //     description: description ?? task.description,
  //   );
  //   await ref.read(taskListControllerProvider.notifier).updateTask(updated);
  //   final index = _allTasks.indexWhere((t) => t.id == task.id);
  //   if (index != -1) {
  //     _allTasks[index] = updated;
  //     state = AsyncValue.data([..._allTasks]);
  //   }
  // }
  Future<void> updateTask(Task task, {String? title, String? description}) async {
    final updated = task.copyWith(
      title: title ?? task.title,
      description: description ?? task.description,
      updatedAt: DateTime.now(),
      lastUpdatedById: await getCurrentUserId(),
    );

    // 1️⃣ Update Firestore
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(updated.id)
        .update(updated.toMap());

    // 2️⃣ Update local state
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = updated;
      state = AsyncValue.data([..._allTasks]);
    }
  }

  void updateTaskInList(Task updated) {
    state = state.whenData((tasks) {
      final index = tasks.indexWhere((t) => t.id == updated.id);
      if (index == -1) return tasks; // task not in list, do nothing
      final newList = [...tasks];
      newList[index] = updated; // replace only the edited task
      return newList;
    });
  }
  // Inside PaginatedTaskController


}


final paginatedTaskControllerProvider =
AutoDisposeNotifierProvider<PaginatedTaskController, AsyncValue<List<Task>>>(
  PaginatedTaskController.new,
);
