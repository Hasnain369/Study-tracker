import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/exam_model.dart';
import '../repository/exam_repository.dart';

final examRepositoryProvider = Provider((ref) => ExamRepository());

class ExamNotifier extends StateNotifier<List<Exam>> {
  final ExamRepository _repo;

  ExamNotifier(this._repo) : super([]) {
    loadExams();
  }

  Future<void> loadExams() async {
    state = await _repo.getAllExams();
  }

  Future<void> addExam(Exam exam) async {
    await _repo.addExam(exam);
    await loadExams();
  }

  Future<void> updateExam(Exam exam) async {
    await _repo.updateExam(exam);
    await loadExams();
  }

  Future<void> deleteExam(int id) async {
    await _repo.deleteExam(id);
    await loadExams();
  }
}

final examProvider = StateNotifierProvider<ExamNotifier, List<Exam>>((ref) {
  return ExamNotifier(ref.watch(examRepositoryProvider));
});
