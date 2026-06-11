import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/dashboard_provider.dart';
import '../../subjects/provider/subject_provider.dart';
import '../../subjects/model/subject_model.dart';
import '../../../shared/widgets/taskCard.dart';
import '../../../shared/widgets/examCard.dart';
import '../../../shared/provider/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    final upcomingExams = ref.watch(upcomingExamsProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final subjects = ref.watch(subjectProvider);
    final theme = Theme.of(context);

    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    Subject? findSubject(int id) {
      try {
        return subjects.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, d MMMM').format(now),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          ref.watch(themeProvider) == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            ref.read(themeProvider.notifier).toggle(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Summary cards
                  Row(
                    children: [
                      _statCard('Done', stats['done']!, Colors.green),
                      const SizedBox(width: 10),
                      _statCard('Pending', stats['pending']!, Colors.orange),
                      const SizedBox(width: 10),
                      _statCard('Overdue', stats['overdue']!, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Upcoming Exams
                if (upcomingExams.isNotEmpty) ...[
                  _sectionHeader(context, '📅 Upcoming Exams', Icons.event),
                  const SizedBox(height: 10),
                  ...upcomingExams.take(3).map((e) => ExamCard(
                        exam: e,
                        subject: findSubject(e.subjectId),
                      )),
                  const SizedBox(height: 20),
                ],

                // Overdue Tasks
                if (overdueTasks.isNotEmpty) ...[
                  _sectionHeader(
                      context, '⚠️ Overdue Tasks', Icons.warning_amber,
                      color: Colors.red),
                  const SizedBox(height: 10),
                  ...overdueTasks.map((t) => TaskCard(
                        task: t,
                        subject: findSubject(t.subjectId),
                      )),
                  const SizedBox(height: 20),
                ],

                // Today's Tasks
                _sectionHeader(context, "📝 Today's Tasks", Icons.today),
                const SizedBox(height: 10),
                if (todayTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        overdueTasks.isEmpty
                            ? '🎉 All caught up for today!'
                            : 'No tasks due today',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                  )
                else
                  ...todayTasks.map((t) => TaskCard(
                        task: t,
                        subject: findSubject(t.subjectId),
                      )),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
