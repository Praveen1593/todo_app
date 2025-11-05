import '../models/task.dart';

abstract class TaskService {
  Stream<List<Task>> watchTasksForUser({required String userId, int limit, String? startAfterId});
  /// Watch a single task by ID for real-time updates
  Stream<Task> watchTaskById({required String taskId});

  Future<Task> createTask({required Task task});
  Future<void> updateTask({required Task task});
  Future<void> deleteTask({required String taskId});
  Future<Task?> getTaskById(String id);
  Future<void> shareTaskWithUser({required String taskId, required String userId});
}


