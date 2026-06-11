class Exam {
  final int? id;
  final int subjectId;
  final String title;
  final String examDate; // YYYY-MM-DD

  Exam({
    this.id,
    required this.subjectId,
    required this.title,
    required this.examDate,
  });

  int get daysLeft {
    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    final exam = DateTime.parse(examDate);
    return exam.difference(todayClean).inDays;
  }

  bool get isPast => daysLeft < 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject_id': subjectId,
        'title': title,
        'exam_date': examDate,
      };

  factory Exam.fromMap(Map<String, dynamic> map) => Exam(
        id: map['id'] as int?,
        subjectId: map['subject_id'] as int,
        title: map['title'] as String,
        examDate: map['exam_date'] as String,
      );

  Exam copyWith({int? id, int? subjectId, String? title, String? examDate}) =>
      Exam(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        examDate: examDate ?? this.examDate,
      );
}
