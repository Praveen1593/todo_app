import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/task.dart';
import 'repositories/task_repository.dart';
import 'services/firebase_task_service.dart';
import 'services/memory_task_service.dart';
import 'services/task_service.dart';

/// Global app providers (service locator via Riverpod)

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Current user id provider. Uses Firebase Auth if available; otherwise persists a local id.
final currentUserIdProvider = FutureProvider<String>((ref) async {
  try {
    await fb_auth.FirebaseAuth.instance.signInAnonymously();
    return fb_auth.FirebaseAuth.instance.currentUser!.uid;
  } catch (_) {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    const key = 'mock_user_id';
    var id = prefs.getString(key);
    if (id == null) {
      id = ValueKey(DateTime.now().microsecondsSinceEpoch).toString();
      await prefs.setString(key, id);
    }
    return id;
  }
});

/// Decide whether Firebase is available
final firebaseAvailableProvider = Provider<bool>((ref) {
  try {
    // If this does not throw, we consider Firebase configured
    FirebaseFirestore.instance;
    return true;
  } catch (_) {
    return false;
  }
});

final taskServiceProvider = Provider<TaskService>((ref) {
  final isFirebaseAvailable = ref.watch(firebaseAvailableProvider);
  if (isFirebaseAvailable) {
    return FirebaseTaskService(FirebaseFirestore.instance);
  }
  return MemoryTaskService();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final service = ref.watch(taskServiceProvider);
  return TaskRepository(service: service);
});

/// Stream of tasks for current user (owned or shared)
final taskStreamProvider = StreamProvider.autoDispose<List<Task>>((ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* repository.watchTasksForUser(userId: userId);
});


