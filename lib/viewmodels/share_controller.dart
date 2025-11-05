// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../main.dart';
// import '../models/task.dart';
// import '../providers.dart';
// import '../repositories/task_repository.dart';
//
// class ShareController extends AutoDisposeNotifier<void> {
//   TaskRepository get _repo => ref.read(taskRepositoryProvider);
//   final _tasks = FirebaseFirestore.instance.collection('tasks');
//
//   @override
//   void build() {}
//
//   Future<void> shareTaskLink({required String taskId}) async {
//     final link = 'tasksapp://task/$taskId';
//     await Share.share('Open this task in Tasks App: $link');
//   }
//
//   // Future<void> joinTask({required String taskId}) async {
//   //   final userId = await ref.read(currentUserIdProvider.future);
//   //   await _repo.shareTaskWithUser(taskId: taskId, userId: userId);
//   // }
//   // Future<bool> joinTask({required String taskId}) async {
//   //   final userId = FirebaseAuth.instance.currentUser!.uid;
//   //   final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
//   //
//   //   try {
//   //     await FirebaseFirestore.instance.runTransaction((tx) async {
//   //       final snap = await tx.get(taskRef);
//   //       if (!snap.exists) return;
//   //
//   //       final data = snap.data()!;
//   //       final visibleTo = List<String>.from(data['visibleTo'] ?? []);
//   //
//   //       if (!visibleTo.contains(userId)) {
//   //         visibleTo.add(userId);
//   //       }
//   //
//   //       tx.update(taskRef, {
//   //         'visibleTo': visibleTo,
//   //         'updatedAt': DateTime.now().millisecondsSinceEpoch,
//   //       });
//   //     });
//   //     return true; // success
//   //   } catch (e) {
//   //     return false; // failed
//   //   }
//   // }
//   Future<void> joinTask({required String taskId}) async {
//     try {
//       final userId = FirebaseAuth.instance.currentUser!.uid;
//       final docRef = _tasks.doc(taskId);
//       final snap = await docRef.get();
//       if (!snap.exists) return;
//
//       final data = snap.data()!;
//       final sharedWith = List<String>.from(data['sharedWithUserIds'] ?? []);
//       if (!sharedWith.contains(userId)) {
//         sharedWith.add(userId);
//         await docRef.update({'sharedWithUserIds': sharedWith, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
//       }
//
//       // Trigger task list refresh
//       state = !state;
//     } catch (e) {
//       print('Error joining task: $e');
//     }
//   }
//
//   // Future<void> joinTask({required String taskId}) async {
//   //   final currentUserId = await getCurrentUserId();
//   //
//   //   // Get current visibleTo list
//   //   final taskSnapshot = await FirebaseFirestore.instance
//   //       .collection('tasks')
//   //       .doc(taskId)
//   //       .get();
//   //
//   //   if (!taskSnapshot.exists) return;
//   //
//   //   final taskData = taskSnapshot.data()!;
//   //   final visibleTo = List<String>.from(taskData['visibleTo'] ?? []);
//   //
//   //   // If user already exists, do nothing
//   //   if (visibleTo.contains(currentUserId)) return;
//   //
//   //   // Add self to visibleTo
//   //   visibleTo.add(currentUserId);
//   //
//   //   await FirebaseFirestore.instance
//   //       .collection('tasks')
//   //       .doc(taskId)
//   //       .update({'visibleTo': visibleTo});
//   //
//   //   // Show confirmation
//   //   // if (ref.mounted) {
//   //   //   // You can use a ScaffoldMessenger or any notification logic
//   //   // }
//   // }
//
//   /// Listen to real-time updates for a task
//   Stream<Task> taskUpdatesStream(String taskId) {
//     return _repo.watchTaskById(taskId: taskId);
//   }
//
//   /// Listen to real-time updates for all tasks of the current user
//   Stream<List<Task>> userTasksStream(String userId) {
//     return _repo.watchTasksForUser(userId: userId);
//   }
// }
//
// final shareControllerProvider = AutoDisposeNotifierProvider<ShareController, void>(
//   ShareController.new,
// );
//
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/task.dart';
import '../providers.dart';
import '../repositories/task_repository.dart';

class ShareController extends AutoDisposeNotifier<bool> {
//  ShareController() : super(false); // Initial state is false
  TaskRepository get _repo => ref.read(taskRepositoryProvider);
  final _tasks = FirebaseFirestore.instance.collection('tasks');

  @override
  bool build() {
    return false; // initial state
  }

  Future<void> shareTaskLink({required String taskId}) async {
    final link = 'tasksapp://task/$taskId';
    await Share.share('Open this task in Tasks App: $link');
  }

  // Future<void> joinTask({required String taskId}) async {
  //   try {
  //     final userId = FirebaseAuth.instance.currentUser!.uid;
  //     final docRef = _tasks.doc(taskId);
  //     final snap = await docRef.get();
  //     if (!snap.exists) return;
  //
  //     final data = snap.data()!;
  //     final sharedWith = List<String>.from(data['sharedWithUserIds'] ?? []);
  //     if (!sharedWith.contains(userId)) {
  //       sharedWith.add(userId);
  //       await docRef.update({
  //         'sharedWithUserIds': sharedWith,
  //         'updatedAt': DateTime.now().millisecondsSinceEpoch
  //       });
  //     }
  //
  //     // Toggle state to trigger refresh
  //     state = !state;
  //   } catch (e) {
  //     print('Error joining task: $e');
  //   }
  // }
  Future<void> joinTask({required String taskId}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final docRef = _tasks.doc(taskId);
      final snap = await docRef.get();
      if (!snap.exists) return;

      final data = snap.data()!;
      final sharedWith = List<String>.from(data['sharedWithUserIds'] ?? []);
      final visibleTo = List<String>.from(data['visibleTo'] ?? []);

      if (!sharedWith.contains(userId)) {
        sharedWith.add(userId);
      }

      if (!visibleTo.contains(userId)) {
        visibleTo.add(userId);
      }

      await docRef.update({
        'sharedWithUserIds': sharedWith,
        'visibleTo': visibleTo,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

    } catch (e) {
      print('Error joining task: $e');
    }
  }

  /// Listen to real-time updates for a task
  Stream<Task> taskUpdatesStream(String taskId) {
    return _repo.watchTaskById(taskId: taskId);
  }

  /// Listen to real-time updates for all tasks of the current user
  Stream<List<Task>> userTasksStream(String userId) {
    return _repo.watchTasksForUser(userId: userId);
  }

}

// Provider
final shareControllerProvider =
AutoDisposeNotifierProvider<ShareController, bool>(ShareController.new);
