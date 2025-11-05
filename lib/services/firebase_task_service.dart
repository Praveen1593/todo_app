import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import 'task_service.dart';

class FirebaseTaskService implements TaskService {
  final FirebaseFirestore firestore;

  FirebaseTaskService(this.firestore);

  CollectionReference<Map<String, dynamic>> get _tasks =>
      firestore.collection('tasks');

  @override
  Future<Task> createTask({required Task task}) async {
    await _tasks.doc(task.id).set(task.toMap());
    return task;
  }

  @override
  Future<void> deleteTask({required String taskId}) async {
    await _tasks.doc(taskId).delete();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final doc = await _tasks.doc(id).get();
    if (!doc.exists) return null;
    return Task.fromMap(doc.data()!);
  }

   @override

  // Future<void> shareTaskWithUser({
  //   required String taskId,
  //   required String userId,
  // }) async {
  //   final ref = _tasks.doc(taskId);
  //
  //   try {
  //     await ref.update({
  //       'sharedWithUserIds': FieldValue.arrayUnion([userId]),
  //       'updatedAt': DateTime.now().millisecondsSinceEpoch,
  //     });
  //   } catch (e) {
  //     print('Error sharing task: $e');
  //   }
  // }
   Future<void> shareTaskWithUser({
     required String taskId,
     required String userId,
   }) async {
     final taskRef = _tasks.doc(taskId);

     try {
       await firestore.runTransaction((tx) async {
         final snap = await tx.get(taskRef);
         if (!snap.exists) return;

         final data = snap.data()!;
         final visibleList = List<String>.from(data['visibleTo'] ?? []);
         final sharedList = List<String>.from(data['sharedWithUserIds'] ?? []);

         if (!visibleList.contains(userId)) visibleList.add(userId);
         if (!sharedList.contains(userId)) sharedList.add(userId);

         tx.update(taskRef, {
           'visibleTo': visibleList,
           'sharedWithUserIds': sharedList,
           'updatedAt': DateTime.now().millisecondsSinceEpoch,
         });
       });

       // Only show snackbar if transaction succeeded
       print('Task shared successfully');
     } catch (e) {
       print('Error sharing task: $e');
     }
   }


  // Future<void> shareTaskWithUser(
  //     {required String taskId, required String userId}) async {
  //   await firestore.runTransaction((tx) async {
  //     final ref = _tasks.doc(taskId);
  //     final snap = await tx.get(ref);
  //     if (!snap.exists) return;
  //     final data = snap.data()!;
  //     final list = List<String>.from(data['sharedWithUserIds'] ?? []);
  //     if (!list.contains(userId)) {
  //       list.add(userId);
  //       tx.update(ref, {
  //         'sharedWithUserIds': list,
  //         'updatedAt': DateTime
  //             .now()
  //             .millisecondsSinceEpoch,
  //       });
  //     }
  //   });
  // }

  @override
  Future<void> updateTask({required Task task}) async {
    await _tasks.doc(task.id).update(
        task.copyWith(updatedAt: DateTime.now()).toMap());
  }

  @override
  Stream<List<Task>> watchTasksForUser(
      {required String userId, int limit = 20, String? startAfterId}) async* {
    Query<Map<String, dynamic>> q = _tasks
        .where('visibleTo', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (startAfterId != null) {
      final doc = await _tasks.doc(startAfterId).get();
      final data = doc.data();
      if (data != null) {
        q = q.startAfter([data['updatedAt'] ?? 0]);
      }
    }

    yield* q.snapshots().map((snap) =>
        snap.docs.map((d) => Task.fromMap(d.data())).toList());
  }

  @override
  // Stream<Task> watchTaskById({required String taskId}) {
  //   return _tasks.doc(taskId).snapshots().map((doc) {
  //     final data = doc.data();
  //     if (data == null) throw Exception('Task not found');
  //     return Task.fromMap(data);
  //   });
  // }
  Stream<Task> watchTaskById({required String taskId}) {
    return _tasks.doc(taskId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception("Task not found or deleted");
      }
      return Task.fromMap(doc.data()!);
    });
  }
}
