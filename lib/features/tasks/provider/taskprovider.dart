import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/taskmodel.dart';
import '../repository/taskrepo.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repo;

  TaskNotifier(this._repo) : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = await _repo.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    await _repo.addTask(task);
    await loadTasks();
  }

  Future<void> toggleDone(int id, bool isDone) async {
    await _repo.toggleDone(id, isDone);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _repo.deleteTask(id);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repo.updateTask(task);
    await loadTasks();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});
