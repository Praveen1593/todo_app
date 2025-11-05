import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks_app/core/link_listener.dart';
import 'package:tasks_app/core/splash_screen.dart';
import 'package:uuid/uuid.dart';

import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config not present; continue with in-memory fallback
  }
  runApp(const ProviderScope(child: LinkListener(child: MyApp())));

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasks App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AnimatedSplashScreen(),
    );
  }
}
Future<void> _ensureUserId() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('userId')) {
    final id = const Uuid().v4();
    await prefs.setString('userId', id);
  }
}

// Future<String> getCurrentUserId() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('userId')!;
// }
Future<String> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  // Generate and store if it doesn't exist
  if (userId == null) {
    userId = const Uuid().v4();
    await prefs.setString('userId', userId);
  }

  return userId;
}