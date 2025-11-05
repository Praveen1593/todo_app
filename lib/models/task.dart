import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String ownerId;
  final List<String> sharedWithUserIds;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 0=low,1=normal,2=high
  final List<String> labels;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastUpdatedById;

  Task({
    required this.id,
    required this.ownerId,
    required this.sharedWithUserIds,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 1,
    this.labels = const [],
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastUpdatedById = '',
  });


  factory Task.newTask({
    required String id,
    required String ownerId,
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 1,
    List<String> labels = const [],
  }) {
    final now = DateTime.now();
    return Task(
      id: id,
      ownerId: ownerId,
      sharedWithUserIds: const [],
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      labels: labels,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,

    );
  }

  Task copyWith({
    String? id,
    String? ownerId,
    List<String>? sharedWithUserIds,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    List<String>? labels,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastUpdatedById,
  }) {
    return Task(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sharedWithUserIds: sharedWithUserIds ?? this.sharedWithUserIds,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUpdatedById: lastUpdatedById ?? this.lastUpdatedById,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'sharedWithUserIds': sharedWithUserIds,
      'visibleTo': [ownerId, ...sharedWithUserIds].toSet().toList(),
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'labels': labels,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map,{String? id}) {
    return Task(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      sharedWithUserIds: List<String>.from(map['sharedWithUserIds'] ?? const []),
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: (map['dueDate'] as int?) != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int) : null,
      priority: map['priority'] as int? ?? 1,
      labels: List<String>.from(map['labels'] ?? const []),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int? ?? 0),
    );
  }
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task.fromMap(data, id: doc.id);
  }
}


