import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/subject_model.dart';
import '../repository/subjectRepo.dart';

final subjectRepositoryProvider = Provider((ref) => SubjectRepository());

class SubjectNotifier extends StateNotifier<List<Subject>> {
  final SubjectRepository _repo;

  SubjectNotifier(this._repo) : super([]) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    state = await _repo.getAllSubjects();
  }

  Future<void> addSubject(Subject subject) async {
    await _repo.addSubject(subject);
    await loadSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await _repo.updateSubject(subject);
    await loadSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _repo.deleteSubject(id);
    await loadSubjects();
  }
}

final subjectProvider =
    StateNotifierProvider<SubjectNotifier, List<Subject>>((ref) {
  return SubjectNotifier(ref.watch(subjectRepositoryProvider));
});
