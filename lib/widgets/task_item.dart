// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/task.dart';
//
// class TaskItem extends StatefulWidget {
//   final Task task;
//   final VoidCallback onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback onShare;
//   final ValueChanged<Task>? onEdit;
//
//   const TaskItem({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     required this.onShare,
//     this.onEdit,
//   });
//
//   @override
//   State<TaskItem> createState() => _TaskItemState();
// }
//
// class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
//   late bool isCompleted;
//
//   @override
//   void initState() {
//     super.initState();
//     isCompleted = widget.task.isCompleted;
//   }
//
//   @override
//   void didUpdateWidget(covariant TaskItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.task.isCompleted != widget.task.isCompleted) {
//       setState(() {
//         isCompleted = widget.task.isCompleted;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 300),
//       opacity: isCompleted ? 0.6 : 1.0,
//       child: AnimatedSlide(
//         duration: const Duration(milliseconds: 300),
//         offset: isCompleted ? const Offset(0, 0.02) : Offset.zero,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//           child: ListTile(
//             leading: AnimatedScale(
//               scale: isCompleted ? 1.2 : 1.0,
//               duration: const Duration(milliseconds: 200),
//               child: Checkbox(
//                 value: widget.task.isCompleted,
//                 onChanged: (_) {
//                   widget.onToggle();
//                   setState(() => isCompleted = !isCompleted);
//                 },
//                 shape: const CircleBorder(),
//                 activeColor: Colors.green,
//               ),
//             ),
//             title: AnimatedDefaultTextStyle(
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 decoration:
//                 isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
//                 color: isCompleted ? Colors.grey : Colors.black87,
//                 fontSize: 16,
//               ),
//               duration: const Duration(milliseconds: 300),
//               child: Text(widget.task.title),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (widget.task.description != null &&
//                     widget.task.description!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(widget.task.description!,
//                         style: const TextStyle(fontSize: 13)),
//                   ),
//                 if (widget.task.dueDate != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(
//                       'Due: ${widget.task.dueDate}',
//                       style: TextStyle(color: Colors.grey[700], fontSize: 12),
//                     ),
//                   ),
//                 if (widget.task.labels.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Wrap(
//                       spacing: 6,
//                       runSpacing: -8,
//                       children: widget.task.labels
//                           .map(
//                             (l) => Chip(
//                           label: Text(l),
//                           materialTapTargetSize:
//                           MaterialTapTargetSize.shrinkWrap,
//                           labelStyle: const TextStyle(fontSize: 12),
//                         ),
//                       )
//                           .toList(),
//                     ),
//                   ),
//                 if (widget.task.sharedWithUserIds.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(
//                       'Shared with: ${widget.task.sharedWithUserIds.length}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'ID: ${widget.task.id}',
//                         overflow: TextOverflow.ellipsis,
//                         style:
//                         const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, size: 18),
//                       tooltip: 'Copy ID',
//                       onPressed: () async {
//                         await Clipboard.setData(
//                             ClipboardData(text: widget.task.id));
//                         // ignore: use_build_context_synchronously
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Task ID copied')),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     _PremiumActionButton(
//                       label: 'Edit',
//                       color: Colors.blueAccent,
//                       onTap: () async {
//                         final updated = await _promptEdit(context, widget.task);
//                         if (updated != null) widget.onEdit?.call(updated);
//                       },
//                     ),
//                     const SizedBox(width: 8),
//                     _PremiumActionButton(
//                       label: 'Share',
//                       color: Colors.green,
//                       onTap: widget.onShare,
//                     ),
//                     const SizedBox(width: 8),
//                     _PremiumActionButton(
//                       label: 'Delete',
//                       color: Colors.redAccent,
//                       onTap: widget.onDelete,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PremiumActionButton extends StatefulWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _PremiumActionButton({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   State<_PremiumActionButton> createState() => _PremiumActionButtonState();
// }
//
// class _PremiumActionButtonState extends State<_PremiumActionButton> {
//   bool isHovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovering = true),
//       onExit: (_) => setState(() => isHovering = false),
//       child: InkWell(
//         onTap: widget.onTap,
//         borderRadius: BorderRadius.circular(4),
//         splashColor: widget.color.withOpacity(0.2),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isHovering ? widget.color : Colors.transparent,
//                 width: 1.5,
//               ),
//             ),
//           ),
//           child: Text(
//             widget.label,
//             style: TextStyle(
//               color: widget.color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Future<Task?> _promptEdit(BuildContext context, Task task) async {
//   final titleController = TextEditingController(text: task.title);
//   final descriptionController =
//   TextEditingController(text: task.description ?? '');
//   final result = await showDialog<Task>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Edit Task'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(labelText: 'Title'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: descriptionController,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final t = titleController.text.trim();
//               final d = descriptionController.text.trim();
//               Navigator.pop(
//                 context,
//                 task.copyWith(
//                   title: t.isEmpty ? task.title : t,
//                   description: d,
//                 ),
//               );
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       );
//     },
//   );
//   return result;
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../views/task_detail_page.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final ValueChanged<Task>? onEdit;
  final VoidCallback? onTap; // for navigating to details

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onShare,
    this.onEdit,
    this.onTap,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.isCompleted;
  }

  @override
  void didUpdateWidget(covariant TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      setState(() => isCompleted = widget.task.isCompleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Checkbox + Title + Status badge
              Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (_) {
                      widget.onToggle();
                      setState(() => isCompleted = !isCompleted);
                    },
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : 'Pending',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (widget.task.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.dueDate!.toLocal().toString().split(' ').first,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              // Description
              if (widget.task.description != null && widget.task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4),
                  child: Text(widget.task.description!, style: const TextStyle(fontSize: 13)),
                ),

              // Labels
              if (widget.task.labels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4),
                  child: Wrap(
                    spacing: 6,
                    children: widget.task.labels
                        .map((l) => Chip(
                      label: Text(l),
                      labelStyle: const TextStyle(fontSize: 12),
                    ))
                        .toList(),
                  ),
                ),

              // Task ID
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Text(
                  'ID: ${widget.task.id}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // Shared users avatars
              if (widget.task.sharedWithUserIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4),
                  child: Row(
                    children: widget.task.sharedWithUserIds
                        .map((_) => const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: CircleAvatar(radius: 8, backgroundColor: Colors.blueAccent),
                    ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 4),

              // Actions: Edit / Share / Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskDetailPage(task: widget.task)),
                      );
                    },
                    child: const Text('Edit'),
                  ),

                  // TextButton(
                  //   onPressed: () async {
                  //     final updated = await _promptEdit(context, widget.task);
                  //     if (updated != null) widget.onEdit?.call(updated);
                  //   },
                  //   child: const Text('Edit'),
                  // ),
                  const SizedBox(width: 8),
                  TextButton(onPressed: widget.onShare, child: const Text('Share')),
                  const SizedBox(width: 8),
                  TextButton(
                      onPressed: widget.onDelete,
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Future<Task?> _promptEdit(BuildContext context, Task task) async {
//   final titleController = TextEditingController(text: task.title);
//   final descriptionController = TextEditingController(text: task.description ?? '');
//   DateTime? selectedDate = task.dueDate;
//
//   final result = await showDialog<Task>(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Edit Task'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: titleController,
//                   decoration: const InputDecoration(labelText: 'Title'),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: descriptionController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     const Text('Due Date: '),
//                     Text(
//                       selectedDate != null
//                           ? '${selectedDate?.toLocal().toString().split(' ').first}'
//                           : 'Not set',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const Spacer(),
//                     TextButton(
//                       onPressed: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: selectedDate ?? DateTime.now(),
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => selectedDate = picked);
//                         }
//                       },
//                       child: const Text('Select Date'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   final t = titleController.text.trim();
//                   final d = descriptionController.text.trim();
//                   Navigator.pop(
//                     context,
//                     task.copyWith(
//                       title: t.isEmpty ? task.title : t,
//                       description: d,
//                       dueDate: selectedDate,
//                     ),
//                   );
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
//
//   return result;
// }



