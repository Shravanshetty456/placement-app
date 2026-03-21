import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/todo_service.dart';
import '../../services/quiz_service.dart';
import '../../models/todo_stats.dart';
import '../../models/quiz_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with AutomaticKeepAliveClientMixin {
  TodoStats? _stats;
  QuizStats? _quizStats;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => false; // Don't keep alive - reload each time

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats when screen becomes visible
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await TodoService.getStats();
    final quizStats = await QuizService.getStats();

    print('Loaded quiz stats: ${quizStats?.totalQuizzes ?? "null"}');
    print('Quiz stats object: $quizStats');

    if (mounted) {
      setState(() {
        _stats = stats;
        _quizStats = quizStats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDarkMode
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppTheme.darkText
                                : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your productivity and achievements',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? AppTheme.darkTextLight
                                : AppTheme.textLightColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Streak Cards Row
                        Row(
                          children: [
                            _buildStreakCard(
                              'Current Streak',
                              '${_stats?.currentStreak ?? 0}',
                              Icons.local_fire_department,
                              Colors.orange,
                              isDarkMode,
                            ),
                            const SizedBox(width: 12),
                            _buildStreakCard(
                              'Best Streak',
                              '${_stats?.longestStreak ?? 0}',
                              Icons.emoji_events,
                              Colors.amber,
                              isDarkMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Overview Card
                        _buildStatsOverviewCard(isDarkMode),
                        const SizedBox(height: 16),

                        // Quiz Stats Card
                        _buildQuizStatsCard(isDarkMode),
                        const SizedBox(height: 16),

                        // Completion Rate Pie Chart
                        _buildCompletionRateCard(isDarkMode),
                        const SizedBox(height: 16),

                        // Weekly Bar Chart
                        _buildWeeklyChartCard(isDarkMode),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$value days',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverviewCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkText : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${_stats?.totalTasks ?? 0}',
                'Total Tasks',
                AppTheme.primaryColor,
                isDarkMode,
              ),
              _buildStatItem(
                '${_stats?.completedCount ?? 0}',
                'Completed',
                AppTheme.secondaryColor,
                isDarkMode,
              ),
              _buildStatItem(
                '${_stats?.pendingCount ?? 0}',
                'Pending',
                AppTheme.warningColor,
                isDarkMode,
              ),
              _buildStatItem(
                '${_stats?.missedToday ?? 0}',
                'Missed',
                AppTheme.errorColor,
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode
                ? AppTheme.darkTextLight
                : AppTheme.textLightColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStatsCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Quiz Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.darkText : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_quizStats == null || _quizStats!.totalQuizzes == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No quiz attempts yet. Take your first quiz!',
                  style: TextStyle(
                    color: isDarkMode
                        ? AppTheme.darkTextLight
                        : AppTheme.textLightColor,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '${_quizStats?.totalQuizzes ?? 0}',
                      'Quizzes',
                      Colors.blue,
                      isDarkMode,
                    ),
                    _buildStatItem(
                      '${_quizStats?.totalQuestionsAttempted ?? 0}',
                      'Attempted',
                      AppTheme.primaryColor,
                      isDarkMode,
                    ),
                    _buildStatItem(
                      '${_quizStats?.totalCorrect ?? 0}',
                      'Correct',
                      Colors.green,
                      isDarkMode,
                    ),
                    _buildStatItem(
                      '${_quizStats?.totalIncorrect ?? 0}',
                      'Incorrect',
                      Colors.red,
                      isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_quizStats?.averageAccuracy.toStringAsFixed(1) ?? 0}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          'Avg Accuracy',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? AppTheme.darkTextLight
                                : AppTheme.textLightColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${_quizStats?.bestAccuracy.toStringAsFixed(1) ?? 0}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Best Score',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? AppTheme.darkTextLight
                                : AppTheme.textLightColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${(_quizStats?.averageTime ?? 0).toInt()}s',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Text(
                          'Avg Time',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? AppTheme.darkTextLight
                                : AppTheme.textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(bool isDarkMode) {
    final completionRate = _stats?.completionRate ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Rate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkText : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: completionRate,
                    title: '${completionRate.toStringAsFixed(1)}%',
                    color: AppTheme.secondaryColor,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 100 - completionRate,
                    title: '',
                    color: isDarkMode
                        ? AppTheme.darkDivider
                        : Colors.grey.shade200,
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard(bool isDarkMode) {
    final weeklyData = _stats?.weeklyData ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkText : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: weeklyData.isEmpty
                ? Center(
                    child: Text(
                      'No data for this week',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.darkTextLight
                            : AppTheme.textLightColor,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(weeklyData),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < weeklyData.length) {
                                final date = weeklyData[value.toInt()].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getDayName(date),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDarkMode
                                          ? AppTheme.darkTextLight
                                          : AppTheme.textLightColor,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: weeklyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.completed.toDouble(),
                              color: AppTheme.secondaryColor,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: entry.value.pending.toDouble(),
                              color: AppTheme.warningColor,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Completed', AppTheme.secondaryColor),
              const SizedBox(width: 24),
              _buildLegendItem('Pending', AppTheme.warningColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  double _getMaxY(List<DailyStats> data) {
    double max = 0;
    for (var d in data) {
      if (d.completed > max) max = d.completed.toDouble();
      if (d.pending > max) max = d.pending.toDouble();
    }
    return max + 2;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
