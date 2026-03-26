class TodoStats {
  final int totalTasks;
  final int completedCount;
  final int pendingCount;
  final int missedToday;
  final int currentStreak;
  final int longestStreak;
  final List<DailyStats> weeklyData;

  TodoStats({
    required this.totalTasks,
    required this.completedCount,
    required this.pendingCount,
    required this.missedToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyData,
  });

  double get completionRate =>
      totalTasks > 0 ? (completedCount / totalTasks) * 100 : 0.0;

  factory TodoStats.fromJson(Map<String, dynamic> json) {
    return TodoStats(
      totalTasks: json['total_tasks'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
      missedToday: json['missed_today'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      weeklyData:
          (json['weekly_data'] as List?)
              ?.map((d) => DailyStats.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class DailyStats {
  final DateTime date;
  final int completed;
  final int pending;

  DailyStats({
    required this.date,
    required this.completed,
    required this.pending,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
    );
  }
}
