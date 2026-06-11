import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/exams/model/exam_model.dart';
import '../../features/subjects/model/subject_model.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final Subject? subject;
  final VoidCallback? onDelete;

  const ExamCard({
    super.key,
    required this.exam,
    this.subject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = subject?.displayColor ?? theme.colorScheme.primary;
    final daysLeft = exam.daysLeft;

    Color countdownColor;
    if (daysLeft <= 3) {
      countdownColor = Colors.red;
    } else if (daysLeft <= 7) {
      countdownColor = Colors.orange;
    } else {
      countdownColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subject != null)
                        Text(
                          subject!.name,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        exam.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event, size: 13, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(exam.examDate),
                            style:
                                TextStyle(fontSize: 12, color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: countdownColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: countdownColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        daysLeft == 0 ? 'Today!' : '$daysLeft days',
                        style: TextStyle(
                          color: countdownColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(Icons.delete_outline,
                            size: 18, color: theme.hintColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
