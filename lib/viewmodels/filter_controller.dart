import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/home_page.dart';

class TaskFilters {
  final String searchText;
  final Set<int> priorities;
  final Set<String> labels;
  final DateTime? dueFrom;
  final DateTime? dueTo;
  final TaskStatus showStatus;

  const TaskFilters({
    this.searchText = '',
    this.priorities = const {},
    this.labels = const {},
    this.dueFrom,
    this.dueTo,
    this.showStatus = TaskStatus.all,
  });

  TaskFilters copyWith({
    String? searchText,
    Set<int>? priorities,
    Set<String>? labels,
    Object? dueFrom = const _NoChange(),
    Object? dueTo = const _NoChange(),
    TaskStatus? showStatus,
  }) {
    return TaskFilters(
      searchText: searchText ?? this.searchText,
      priorities: priorities ?? this.priorities,
      labels: labels ?? this.labels,
      dueFrom: dueFrom is _NoChange ? this.dueFrom : dueFrom as DateTime?,
      dueTo: dueTo is _NoChange ? this.dueTo : dueTo as DateTime?,
      showStatus: showStatus ?? this.showStatus,
    );
  }
}

class _NoChange {
  const _NoChange();
}

class TaskFilterController extends Notifier<TaskFilters> {
  @override
  TaskFilters build() => const TaskFilters();

  void setSearchText(String text) => state = state.copyWith(searchText: text);

  void togglePriority(int p) {
    final set = Set<int>.from(state.priorities);
    set.contains(p) ? set.remove(p) : set.add(p);
    state = state.copyWith(priorities: set);
  }

  void setLabelsFromCommaSeparated(String input) {
    final parts = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    state = state.copyWith(labels: parts);
  }

  void toggleLabel(String label) {
    final set = Set<String>.from(state.labels);
    set.contains(label) ? set.remove(label) : set.add(label);
    state = state.copyWith(labels: set);
  }

  void setDueFrom(DateTime? d) => state = state.copyWith(dueFrom: d);
  void setDueTo(DateTime? d) => state = state.copyWith(dueTo: d);
  void setShowStatus(TaskStatus status) {
    state = state.copyWith(showStatus: status);
  }

  void clear() => state = const TaskFilters();
}

final taskFilterControllerProvider =
NotifierProvider<TaskFilterController, TaskFilters>(
  TaskFilterController.new,
);
