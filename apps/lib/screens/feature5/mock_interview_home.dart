import 'package:apps/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/interview_provider.dart';
import '../../theme/app_theme.dart';
import 'interview_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockInterviewHome extends StatefulWidget {
  const MockInterviewHome({super.key});

  @override
  State<MockInterviewHome> createState() => _MockInterviewHomeState();
}

class _MockInterviewHomeState extends State<MockInterviewHome> {
  final TextEditingController _topicController = TextEditingController();
  final List<String> _quickTopics = [
    'Flutter Development',
    'React.js',
    'Node.js & Express',
    'Data Structures',
    'System Design',
    'SQL & Databases',
    'Python',
    'Machine Learning',
    'OOP Concepts',
    'API Design',
  ];

  @override
  void initState() {
    super.initState();
    _loadLastTopic();
  }

  Future<void> _loadLastTopic() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTopic = prefs.getString('last_interview_topic');
    if (lastTopic != null && lastTopic.isNotEmpty) {
      _topicController.text = lastTopic;
    }
  }

  Future<void> _saveLastTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_interview_topic', topic);
  }

  void _startInterview() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a topic first'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    await _saveLastTopic(topic);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InterviewSession(topic: topic),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final history = interviewProvider.interviewHistory;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Interview History',
          style: TextStyle(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: history.isEmpty
            ? Text(
                'No interviews taken yet',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final interview = history[index];
                    final percentage = interview['percentage'] as double;
                    Color scoreColor = percentage >= 70
                        ? AppTheme.secondaryColor
                        : percentage >= 50
                            ? AppTheme.warningColor
                            : AppTheme.errorColor;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          interview['topic'],
                          style: TextStyle(
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${interview['totalScore']}/${interview['maxScore']}',
                              style: TextStyle(
                                color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}% - ${_formatDate(DateTime.parse(interview['date']))}',
                              style: TextStyle(
                                color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: AppTheme.primaryColor,
                        ),
                        onTap: () => _showInterviewDetails(context, interview),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                interviewProvider.clearHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  void _showInterviewDetails(BuildContext context, Map<String, dynamic> interview) {
    final isDark = Provider.of<ThemeProvider>(context, listen: true).isDarkMode;
    final results = interview['results'] as List<Map<String, dynamic>>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          interview['topic'],
          style: TextStyle(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final q = results[index];
              final score = q['score'] as int;
              Color scoreColor = score >= 8
                  ? AppTheme.secondaryColor
                  : score >= 5
                      ? AppTheme.warningColor
                      : AppTheme.errorColor;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Question ${index + 1}',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    q['question'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scoreColor),
                    ),
                    child: Text(
                      '$score/10',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Answer:',
                            style: TextStyle(
                              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q['answer'],
                            style: TextStyle(
                              color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'AI Feedback:',
                            style: TextStyle(
                              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q['feedback'],
                            style: TextStyle(
                              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppTheme.darkText : Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mock Interview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: isDark ? AppTheme.darkText : Colors.white,
            ),
            onPressed: () => _showHistoryDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'AI-Powered Interview Simulator',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ace your next',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            Text(
              'tech interview.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter any topic and face 5 real interview questions. Type or speak your answer — scored instantly by AI.',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                ),
              ),
              child: TextField(
                controller: _topicController,
                style: TextStyle(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Flutter Development, React, DSA...',
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.topic,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                onSubmitted: (_) => _startInterview(),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTopics.map((t) => _TopicChip(
                label: t,
                isDark: isDark,
                onTap: () => setState(() => _topicController.text = t),
              )).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startInterview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'START INTERVIEW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.quiz_outlined,
                    label: '5 Questions',
                    sub: 'AI generated',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.mic_outlined,
                    label: 'Voice Input',
                    sub: 'Speak answers',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.videocam_outlined,
                    label: 'Proctored',
                    sub: 'Face monitor',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}