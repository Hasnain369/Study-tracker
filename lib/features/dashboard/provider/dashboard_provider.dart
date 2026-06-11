import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/model/taskmodel.dart';
import '../../exams/model/exam_model.dart';
import '../../tasks/provider/taskprovider.dart';
import '../../exams/provider/exam_provider.dart';

// Today's tasks (due today, not done)
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((t) => t.isDueToday && !t.isDone).toList();
});

// Overdue tasks (past due date, not done)
final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((t) => t.isOverdue).toList();
});

// Upcoming exams (next 60 days, not past)
final upcomingExamsProvider = Provider<List<Exam>>((ref) {
  final exams = ref.watch(examProvider);
  return exams.where((e) => e.daysLeft >= 0 && e.daysLeft <= 60).toList()
    ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
});

// Summary stats for dashboard cards
final dashboardStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final todayAll = tasks.where((t) => t.dueDate == todayStr).toList();
  final doneTodayCount = todayAll.where((t) => t.isDone).length;
  final pendingTodayCount = todayAll.where((t) => !t.isDone).length;
  final overdueCount = tasks.where((t) => t.isOverdue).length;

  return {
    'done': doneTodayCount,
    'pending': pendingTodayCount,
    'overdue': overdueCount,
  };
});
