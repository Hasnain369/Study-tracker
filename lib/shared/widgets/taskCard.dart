import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../features/tasks/model/taskmodel.dart';
import '../../features/subjects/model/subject_model.dart';
import '../../features/tasks/provider/taskprovider.dart';
import 'subjectChip.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final Subject? subject;
  final bool showSubject;

  const TaskCard({
    super.key,
    required this.task,
    this.subject,
    this.showSubject = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.4)
              : theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => ref
              .read(taskProvider.notifier)
              .toggleDone(task.id!, !task.isDone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone
                  ? (subject?.displayColor ?? Colors.green)
                  : Colors.transparent,
              border: Border.all(
                color: task.isDone
                    ? (subject?.displayColor ?? Colors.green)
                    : theme.dividerColor,
                width: 2,
              ),
            ),
            child: task.isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone
                ? theme.hintColor
                : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (showSubject && subject != null) ...[
                SubjectChip(subject: subject!, small: true),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: isOverdue ? Colors.red : theme.hintColor,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(task.dueDate),
                style: TextStyle(
                  fontSize: 11,
                  color: isOverdue ? Colors.red : theme.hintColor,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isOverdue) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Overdue',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
