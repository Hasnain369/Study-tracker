import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study_tracker/features/subjects/provider/subject_provider.dart';
import '../../tasks/provider/taskprovider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final subjects = ref.watch(subjectProvider);
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 64, color: theme.hintColor),
              const SizedBox(height: 16),
              Text('No data yet',
                  style: TextStyle(color: theme.hintColor, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Add tasks to see your progress',
                  style: TextStyle(color: theme.hintColor, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    final doneCount = tasks.where((t) => t.isDone).length;
    final pendingCount = tasks.where((t) => !t.isDone && !t.isOverdue).length;
    final overdueCount = tasks.where((t) => t.isOverdue).length;
    final total = tasks.length;

    // Per-subject stats
    final subjectStats = <int, Map<String, int>>{};
    for (final subject in subjects) {
      final subjectTasks =
          tasks.where((t) => t.subjectId == subject.id!).toList();
      if (subjectTasks.isEmpty) continue;
      subjectStats[subject.id!] = {
        'total': subjectTasks.length,
        'done': subjectTasks.where((t) => t.isDone).length,
      };
    }

    // Ignored subjects: subjects with tasks but 0 completed in last 5 days
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));
    final ignoredSubjects = subjects.where((s) {
      final recentDone = tasks.where((t) =>
          t.subjectId == s.id &&
          t.isDone &&
          DateTime.tryParse(t.dueDate)?.isAfter(fiveDaysAgo) == true);
      final hasAnyTask = tasks.any((t) => t.subjectId == s.id);
      return hasAnyTask && recentDone.isEmpty;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Donut chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Progress',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              if (doneCount > 0)
                                PieChartSectionData(
                                  value: doneCount.toDouble(),
                                  color: Colors.green,
                                  title: '$doneCount',
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                  radius: 50,
                                ),
                              if (pendingCount > 0)
                                PieChartSectionData(
                                  value: pendingCount.toDouble(),
                                  color: Colors.orange,
                                  title: '$pendingCount',
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                  radius: 50,
                                ),
                              if (overdueCount > 0)
                                PieChartSectionData(
                                  value: overdueCount.toDouble(),
                                  color: Colors.red,
                                  title: '$overdueCount',
                                  titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                  radius: 50,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendItem(Colors.green, 'Done', doneCount),
                          const SizedBox(height: 12),
                          _legendItem(Colors.orange, 'Pending', pendingCount),
                          const SizedBox(height: 12),
                          _legendItem(Colors.red, 'Overdue', overdueCount),
                          const SizedBox(height: 12),
                          Text(
                            '$total total',
                            style:
                                TextStyle(color: theme.hintColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Per subject progress bars
          if (subjectStats.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('By Subject',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  ...subjects
                      .where((s) => subjectStats.containsKey(s.id))
                      .map((subject) {
                    final stats = subjectStats[subject.id!]!;
                    final pct = stats['done']! / stats['total']!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: subject.displayColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(subject.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ],
                              ),
                              Text(
                                '${stats['done']}/${stats['total']}',
                                style: TextStyle(
                                    color: theme.hintColor, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor:
                                  subject.displayColor.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  subject.displayColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(pct * 100).toInt()}% completed',
                            style:
                                TextStyle(fontSize: 11, color: theme.hintColor),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Ignored subjects warning
          if (ignoredSubjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Text('Subjects Being Ignored',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...ignoredSubjects.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: s.displayColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${s.name} — no completed tasks in 5 days',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.orange),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label ($count)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
