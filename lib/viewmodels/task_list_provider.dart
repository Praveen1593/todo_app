import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart'; // make sure you have your Task model

final taskListProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final tasksCollection = FirebaseFirestore.instance.collection('tasks');

  return tasksCollection
      .where('visibleTo', arrayContains: userId) // all tasks the user can see
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
      .toList());
});


