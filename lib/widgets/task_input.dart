import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const TaskInput({super.key, required this.onSubmit});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Add a task...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}


