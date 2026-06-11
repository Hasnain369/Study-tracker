import '../model/taskmodel.dart';
import '../../../core/database/database_helper.dart';

class TaskRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Task>> getAllTasks() async {
    final db = await _db.database;
    final result = await db.query('tasks', orderBy: 'due_date ASC');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> addTask(Task task) async {
    final db = await _db.database;
    await db.insert('tasks', task.toMap()..remove('id'));
  }

  Future<void> toggleDone(int id, bool isDone) async {
    final db = await _db.database;
    await db.update(
      'tasks',
      {'is_done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await _db.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTask(Task task) async {
    final db = await _db.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
