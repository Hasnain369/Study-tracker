class Task {
  final int? id;
  final int subjectId;
  final String title;
  final bool isDone;
  final String dueDate; // YYYY-MM-DD
  final String createdAt; // YYYY-MM-DD

  Task({
    this.id,
    required this.subjectId,
    required this.title,
    this.isDone = false,
    required this.dueDate,
    required this.createdAt,
  });

  bool get isOverdue {
    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    final due = DateTime.parse(dueDate);
    return !isDone && due.isBefore(todayClean);
  }

  bool get isDueToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return dueDate == todayStr;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject_id': subjectId,
        'title': title,
        'is_done': isDone ? 1 : 0,
        'due_date': dueDate,
        'created_at': createdAt,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as int?,
        subjectId: map['subject_id'] as int,
        title: map['title'] as String,
        isDone: map['is_done'] == 1,
        dueDate: map['due_date'] as String,
        createdAt: map['created_at'] as String,
      );

  Task copyWith({
    int? id,
    int? subjectId,
    String? title,
    bool? isDone,
    String? dueDate,
    String? createdAt,
  }) =>
      Task(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt ?? this.createdAt,
      );
}
