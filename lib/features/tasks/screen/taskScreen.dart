import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/taskmodel.dart';
import '../provider/taskprovider.dart';
import '../../subjects/provider/subject_provider.dart';
import '../../subjects/model/subject_model.dart';
import '../../../shared/widgets/taskCard.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int? _selectedSubjectId; // null = all
  String _statusFilter = 'all'; // all, pending, done, overdue

  void _showAddTaskSheet() {
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
    DateTime? dueDate;

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
              const Text('Add Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Task title',
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
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => dueDate = picked);
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
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        dueDate != null
                            ? DateFormat('d MMM yyyy').format(dueDate!)
                            : 'Pick due date',
                        style: TextStyle(
                          color: dueDate != null
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
                    if (title.isEmpty || dueDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final today = DateTime.now();
                    final task = Task(
                      subjectId: selectedSubject.id!,
                      title: title,
                      dueDate:
                          '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
                      createdAt:
                          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
                    );
                    ref.read(taskProvider.notifier).addTask(task);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final subjects = ref.watch(subjectProvider);
    final theme = Theme.of(context);

    // Filter by subject
    var filtered = _selectedSubjectId == null
        ? allTasks
        : allTasks.where((t) => t.subjectId == _selectedSubjectId).toList();

    // Filter by status
    switch (_statusFilter) {
      case 'pending':
        filtered = filtered.where((t) => !t.isDone && !t.isOverdue).toList();
        break;
      case 'done':
        filtered = filtered.where((t) => t.isDone).toList();
        break;
      case 'overdue':
        filtered = filtered.where((t) => t.isOverdue).toList();
        break;
    }

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
            const Text('Tasks', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject filter chips
          if (subjects.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _filterChip('All', null, subjects),
                  ...subjects.map((s) => _filterChip(s.name, s.id, subjects)),
                ],
              ),
            ),
          // Status filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['all', 'pending', 'done', 'overdue'].map((s) {
                final isSelected = _statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _statusFilter = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Task list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No tasks found',
                        style: TextStyle(color: theme.hintColor)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final task = filtered[i];
                      return Dismissible(
                        key: Key('task_${task.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => ref
                            .read(taskProvider.notifier)
                            .deleteTask(task.id!),
                        child: TaskCard(
                          task: task,
                          subject: findSubject(task.subjectId),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int? subjectId, List<Subject> subjects) {
    final isSelected = _selectedSubjectId == subjectId;
    Subject? subject;
    if (subjectId != null) {
      try {
        subject = subjects.firstWhere((s) => s.id == subjectId);
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubjectId = subjectId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (subject?.displayColor ??
                    Theme.of(context).colorScheme.primary)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (subject?.displayColor ??
                      Theme.of(context).colorScheme.primary)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}
