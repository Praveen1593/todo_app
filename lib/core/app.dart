import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../views/home_page.dart';
import 'link_listener.dart';

class TasksApp extends ConsumerWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return LinkListener(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tasks App',

        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            secondary: Colors.tealAccent,
          ),
        ),

        onGenerateRoute: (settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null && uri.scheme == 'tasksapp' && uri.host == 'task') {
          // For simplicity, land on Home and prompt join via menu
            return MaterialPageRoute(builder: (_) => const HomePage());
          }
          switch (settings.name) {
            case '/':
            default:
              return MaterialPageRoute(builder: (_) => const HomePage());
          }
        },
      ),
    );
  }
}


