import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/task.dart';
import '../viewmodels/paginated_task_controller.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  late TextEditingController _title;
  late TextEditingController _description;
  DateTime? _dueDate;
  int _priority = 1;
  final TextEditingController _labelController = TextEditingController();
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _description = TextEditingController(text: widget.task.description ?? '');
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _labels = [...widget.task.labels];
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Color getPriorityColor(int priority) {
    return switch (priority) {
      0 => Colors.green,
      1 => Colors.orange,
      2 => Colors.red,
      _ => Colors.blue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: getPriorityColor(_priority),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _priority == 0
                                    ? 'Low Priority'
                                    : _priority == 1
                                    ? 'Normal Priority'
                                    : 'High Priority',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:

                                  Text(
                                    _dueDate != null
                                        ? _dueDate!.toLocal().toString().split(' ').first
                                        : 'No due date',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildLabel('Title'),
                          const SizedBox(height: 6),
                          _buildTextField(_title, 'Enter task title'),
                          const SizedBox(height: 12),
                          _buildLabel('Description'),
                          const SizedBox(height: 6),
                          _buildTextField(_description, 'Enter description', maxLines: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Labels'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: -8,
                            children: [
                              for (final l in _labels)
                                Chip(
                                  label: Text(l),
                                  onDeleted: () => setState(() => _labels.remove(l)),
                                ),
                              ActionChip(
                                label: const Text('Add'),
                                onPressed: _addLabel,
                                backgroundColor: Colors.blue[50],
                                labelStyle: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF6C63FF),
            ),
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _dueDate ?? now,
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  Future<void> _addLabel() async {
    final txt = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add label'),
        content: TextField(controller: _labelController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, _labelController.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    _labelController.clear();
    if (txt != null && txt.isNotEmpty && !_labels.contains(txt)) {
      setState(() => _labels.add(txt));
    }
  }

  Future<void> _save() async {
    final currentUserId = await getCurrentUserId();
    final updated = widget.task.copyWith(
      title: _title.text.trim().isEmpty ? widget.task.title : _title.text.trim(),
      description: _description.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      labels: _labels,
     updatedAt: DateTime.now(),
      lastUpdatedById: currentUserId,
    );
    await ref.read(paginatedTaskControllerProvider.notifier).updateTask(updated);
    // Hide keyboard before navigating back
    FocusScope.of(context).unfocus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      // 4️⃣ Navigate back after a short delay so the SnackBar is visible
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) Navigator.pop(context);
      });
    }
    //if (mounted) Navigator.pop(context);
  }
}
