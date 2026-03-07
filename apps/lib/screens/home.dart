import 'package:apps/screens/feature1/todo_screen.dart';
import 'package:apps/screens/feature2/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TodoScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: _screens[_currentIndex],
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
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0 
                        ? (isDarkMode 
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : Colors.blue.shade50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.task_alt,
                    size: 24,
                    color: _currentIndex == 0 
                        ? AppTheme.primaryColor
                        : (isDarkMode ? AppTheme.darkTextLight : Colors.grey.shade400),
                  ),
                ),
                label: 'Todo',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1 
                        ? (isDarkMode 
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : Colors.blue.shade50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: _currentIndex == 1 
                        ? AppTheme.primaryColor
                        : (isDarkMode ? AppTheme.darkTextLight : Colors.grey.shade400),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:apps/screens/feature1/todo_screen.dart';
// import 'package:apps/screens/feature2/profile_screen.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
  
//   final List<Widget> _screens = [
//     const TodoScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade300,
//               blurRadius: 10,
//               offset: const Offset(0, -5),
//             ),
//           ],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           child: BottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Colors.white,
//             selectedItemColor: Colors.blue.shade700,
//             unselectedItemColor: Colors.grey.shade400,
//             selectedLabelStyle: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 12,
//             ),
//             items: [
//               BottomNavigationBarItem(
//                 icon: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: _currentIndex == 0 
//                         ? Colors.blue.shade50 
//                         : Colors.transparent,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.task_alt,
//                     size: 24,
//                     color: _currentIndex == 0 
//                         ? Colors.blue.shade700 
//                         : Colors.grey.shade400,
//                   ),
//                 ),
//                 label: 'Todo',
//               ),
//               BottomNavigationBarItem(
//                 icon: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: _currentIndex == 1 
//                         ? Colors.blue.shade50 
//                         : Colors.transparent,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: 24,
//                     color: _currentIndex == 1 
//                         ? Colors.blue.shade700 
//                         : Colors.grey.shade400,
//                   ),
//                 ),
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }