import '../model/exam_model.dart';
import '../../../core/database/database_helper.dart';

class ExamRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Exam>> getAllExams() async {
    final db = await _db.database;
    final result = await db.query('exams', orderBy: 'exam_date ASC');
    return result.map((e) => Exam.fromMap(e)).toList();
  }

  Future<void> addExam(Exam exam) async {
    final db = await _db.database;
    await db.insert('exams', exam.toMap()..remove('id'));
  }

  Future<void> updateExam(Exam exam) async {
    final db = await _db.database;
    await db.update(
      'exams',
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  Future<void> deleteExam(int id) async {
    final db = await _db.database;
    await db.delete('exams', where: 'id = ?', whereArgs: [id]);
  }
}
