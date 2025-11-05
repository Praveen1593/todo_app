import '../models/task.dart';
import '../services/task_service.dart';

class TaskRepository {
  final TaskService service;

  TaskRepository({required this.service});

  Stream<List<Task>> watchTasksForUser({required String userId, int limit = 20, String? startAfterId}) {
    return service.watchTasksForUser(userId: userId, limit: limit, startAfterId: startAfterId);
  }
// Watch a single task for real-time updates
  Stream<Task> watchTaskById({required String taskId}) {
    return service.watchTaskById(taskId: taskId);
  }

  Future<Task> createTask(Task task) => service.createTask(task: task);
  Future<void> updateTask(Task task) => service.updateTask(task: task);
  Future<void> deleteTask(String id) => service.deleteTask(taskId: id);
  Future<Task?> getTaskById(String id) => service.getTaskById(id);
  Future<void> shareTaskWithUser({required String taskId, required String userId}) =>
      service.shareTaskWithUser(taskId: taskId, userId: userId);
}


