import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_tracker/features/subjects/model/subject_model.dart';
import 'package:study_tracker/features/subjects/provider/subject_provider.dart';
import '../model/exam_model.dart';
import '../provider/exam_provider.dart';
import '../../../shared/widgets/examCard.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  void _showAddExamSheet(BuildContext context, WidgetRef ref) {
    final subjects = ref.read(subjectProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a subject first'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final titleController = TextEditingController();
    Subject selectedSubject = subjects.first;
    DateTime? examDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Exam',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Exam title (e.g. Mid Term)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                value: selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: subjects
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: s.displayColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(s.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (s) => setModalState(() => selectedSubject = s!),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => examDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        examDate != null
                            ? DateFormat('d MMM yyyy').format(examDate!)
                            : 'Pick exam date',
                        style: TextStyle(
                          color: examDate != null
                              ? null
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty || examDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final exam = Exam(
                      subjectId: selectedSubject.id!,
                      title: title,
                      examDate:
                          '${examDate!.year}-${examDate!.month.toString().padLeft(2, '0')}-${examDate!.day.toString().padLeft(2, '0')}',
                    );
                    ref.read(examProvider.notifier).addExam(exam);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Exam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = ref.watch(examProvider);
    final subjects = ref.watch(subjectProvider);
    final theme = Theme.of(context);

    final upcoming = exams.where((e) => !e.isPast).toList();
    final past = exams.where((e) => e.isPast).toList();

    Subject? findSubject(int id) {
      try {
        return subjects.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Exams', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExamSheet(context, ref),
          ),
        ],
      ),
      body: exams.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_outlined, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('No exams added yet',
                      style: TextStyle(color: theme.hintColor, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAddExamSheet(context, ref),
                    child: const Text('Add your first exam'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const Text('Upcoming',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...upcoming.map((e) => ExamCard(
                        exam: e,
                        subject: findSubject(e.subjectId),
                        onDelete: () =>
                            ref.read(examProvider.notifier).deleteExam(e.id!),
                      )),
                ],
                if (past.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Past Exams',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...past.map((e) => Opacity(
                        opacity: 0.5,
                        child: ExamCard(
                          exam: e,
                          subject: findSubject(e.subjectId),
                          onDelete: () =>
                              ref.read(examProvider.notifier).deleteExam(e.id!),
                        ),
                      )),
                ],
              ],
            ),
    );
  }
}
