import 'package:apps/providers/theme_provider.dart';
import 'package:apps/screens/feature1/todo_screen.dart';
import 'package:apps/screens/feature2/profile_screen.dart';
import 'package:apps/screens/feature3/mcq_screen.dart';
import 'package:apps/screens/feature4/stats_screen.dart';
import 'package:apps/screens/feature5/mock_interview_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _statsRefreshKey = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const TodoScreen();
      case 1:
        return const MCQScreen();
      case 2:
        return StatsScreen(key: ValueKey(_statsRefreshKey));
      case 3:
        return const ProfileScreen();
     case 4:
      return const MockInterviewHome();
      default:
        return const TodoScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 2) {
                  _statsRefreshKey++;
                }
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: isDarkMode
                ? AppTheme.darkTextLight
                : Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt, size: 24),
                label: 'Todo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz, size: 24),
                label: 'MCQ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, size: 24),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 24),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.psychology, size: 24),
                label: 'Interview',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

