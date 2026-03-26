import 'package:apps/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import 'mock_interview_home.dart';

class InterviewResults extends StatelessWidget {
  final String topic;
  final List<Map<String, dynamic>> results;
  final int totalScore;
  final int maxScore;

  const InterviewResults({
    super.key,
    required this.topic,
    required this.results,
    required this.totalScore,
    required this.maxScore,
  });

  String get _grade {
    final pct = totalScore / maxScore;
    if (pct >= 0.85) return '🏆 Excellent';
    if (pct >= 0.70) return '✅ Good';
    if (pct >= 0.50) return '⚡ Average';
    return '📚 Needs Work';
  }

  String get _gradeSub {
    final pct = totalScore / maxScore;
    if (pct >= 0.85) return "Outstanding — you're interview-ready!";
    if (pct >= 0.70) return 'Solid answers with room to polish.';
    if (pct >= 0.50) return 'You have the basics — keep practicing.';
    return 'Review the fundamentals and try again.';
  }

  double get _avg {
    if (results.isEmpty) return 0;
    return results.map((r) => (r['score'] as int)).reduce((a, b) => a + b) /
        results.length;
  }

  int get _best {
    if (results.isEmpty) return 0;
    return results
        .map((r) => (r['score'] as int))
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final pct = maxScore > 0 ? (totalScore / maxScore) : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppTheme.darkText : Colors.white,
          ),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
        title: Text(
          'Results',
          style: TextStyle(
            color: isDark ? AppTheme.darkText : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ScoreRing(
              score: totalScore,
              maxScore: maxScore,
              pct: pct,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            Text(
              _grade,
              style: TextStyle(
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _gradeSub,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _StatBox(
                  label: 'Topic',
                  value: topic.split(' ').first,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Avg / Q',
                  value: '${_avg.toStringAsFixed(1)}/10',
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Best',
                  value: '$_best/10',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 1,
              color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QUESTION REVIEW',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...results.asMap().entries.map(
              (e) => _ReviewItem(
                index: e.key,
                data: e.value,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MockInterviewHome(),
                  ),
                ),
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
                  'NEW INTERVIEW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score, maxScore;
  final double pct;
  final bool isDark;

  const _ScoreRing({
    required this.score,
    required this.maxScore,
    required this.pct,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 12,
              backgroundColor: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Text(
                'OUT OF $maxScore',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final bool isDark;

  const _StatBox({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatefulWidget {
  final int index;
  final Map<String, dynamic> data;
  final bool isDark;

  const _ReviewItem({
    required this.index,
    required this.data,
    required this.isDark,
  });

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final score = widget.data['score'] as int;
    final Color scoreColor = score >= 8
        ? AppTheme.secondaryColor
        : score >= 5
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Q${widget.index + 1}: ${widget.data['question']}',
                      style: TextStyle(
                        color: widget.isDark ? AppTheme.darkText : AppTheme.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: widget.isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
                  Text(
                    'YOUR ANSWER',
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['answer'],
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI FEEDBACK',
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['feedback'],
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}