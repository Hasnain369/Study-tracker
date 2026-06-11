import '../model/subject_model.dart';
import '../../../core/database/database_helper.dart';

class SubjectRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Subject>> getAllSubjects() async {
    final db = await _db.database;
    final result = await db.query('subjects', orderBy: 'name ASC');
    return result.map((e) => Subject.fromMap(e)).toList();
  }

  Future<void> addSubject(Subject subject) async {
    final db = await _db.database;
    await db.insert('subjects', subject.toMap()..remove('id'));
  }

  Future<void> updateSubject(Subject subject) async {
    final db = await _db.database;
    await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<void> deleteSubject(int id) async {
    final db = await _db.database;
    await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }
}
