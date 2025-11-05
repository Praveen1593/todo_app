// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:app_links/app_links.dart';
//
// import '../viewmodels/paginated_task_controller.dart';
// import '../viewmodels/share_controller.dart';
//
// class LinkListener extends ConsumerStatefulWidget {
//   final Widget child;
//   const LinkListener({super.key, required this.child});
//
//   @override
//   ConsumerState<LinkListener> createState() => _LinkListenerState();
// }
//
// class _LinkListenerState extends ConsumerState<LinkListener> {
//   StreamSubscription? _sub;
//   AppLinks? _appLinks;
//
//   @override
//   void initState() {
//     super.initState();
//     _initLinks();
//   }
//
//   Future<void> _initLinks() async {
//     try {
//       _appLinks = AppLinks();
//       _sub = _appLinks!.uriLinkStream.listen((uri) {
//         if (uri == null) return;
//         _handleUri(uri);
//       }, onError: (_) {});
//     } catch (_) {}
//   }
//
//   // void _handleUri(Uri uri) {
//   //   if (uri.scheme == 'tasksapp' && uri.host == 'task') {
//   //     final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
//   //     if (id != null && id.isNotEmpty) {
//   //       ref.read(shareControllerProvider.notifier).joinTask(taskId: id);
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined shared task')));
//   //       }
//   //     }
//   //   }
//   // }
//   void _handleUri(Uri uri) async {
//     if (uri.scheme == 'tasksapp' && uri.host == 'task') {
//       final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
//       if (id != null && id.isNotEmpty) {
//         await ref.read(shareControllerProvider.notifier).joinTask(taskId: id);
//         // Optionally, show SnackBar here
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Joined shared task successfully')),
//           );
//         }
//       }
//     }
//   }
//
//
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.child;
// }
//
//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import '../viewmodels/share_controller.dart';


class LinkListener extends ConsumerStatefulWidget {
  final Widget child;
  const LinkListener({super.key, required this.child});

  @override
  ConsumerState<LinkListener> createState() => _LinkListenerState();
}

class _LinkListenerState extends ConsumerState<LinkListener> {
  StreamSubscription? _sub;
  AppLinks? _appLinks;

  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    _appLinks = AppLinks();
    _sub = _appLinks!.uriLinkStream.listen((uri) {
      if (uri == null) return;
      _handleUri(uri);
    }, onError: (_) {});
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'tasksapp' && uri.host == 'task') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (id != null && id.isNotEmpty) {
        ref.read(shareControllerProvider.notifier).joinTask(taskId: id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined shared task')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

