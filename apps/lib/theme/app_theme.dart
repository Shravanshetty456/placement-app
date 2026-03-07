import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors (keep these the same for both themes)
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFF00B894);
  static const Color errorColor = Color(0xFFD63031);
  static const Color warningColor = Color(0xFFFDCB6E);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextLight = Color(0xFF636E72);
  static const Color lightDivider = Color(0xFFDFE6E9);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextLight = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // For backward compatibility - these will be used in screens
  static const Color backgroundColor = lightBackground;
  static const Color surfaceColor = lightSurface;
  static const Color textColor = lightText;
  static const Color textLightColor = lightTextLight;
  static const Color dividerColor = lightDivider;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: lightSurface,
      background: lightBackground,
    ),

    scaffoldBackgroundColor: lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDivider),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDivider),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      
      labelStyle: const TextStyle(color: lightTextLight),
      hintStyle: const TextStyle(color: lightTextLight),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightText,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightText,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: lightText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: lightTextLight,
      ),
    ),
    
    cardColor: lightSurface,
    dividerColor: lightDivider,
    iconTheme: const IconThemeData(color: lightText),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: darkSurface,
      background: darkBackground,
    ),

    scaffoldBackgroundColor: darkBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: darkText),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDivider),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDivider),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      
      labelStyle: const TextStyle(color: darkTextLight),
      hintStyle: const TextStyle(color: darkTextLight),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: darkText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: darkTextLight,
      ),
    ),
    
    cardColor: darkSurface,
    dividerColor: darkDivider,
    iconTheme: const IconThemeData(color: darkText),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextLight,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}

// Theme provider class to manage theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
  
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}










// import 'package:flutter/material.dart';

// class AppTheme {

//   static const Color primaryColor = Color(0xFF6C5CE7);
//   static const Color secondaryColor = Color(0xFF00B894);
//   static const Color errorColor = Color(0xFFD63031);
//   static const Color warningColor = Color(0xFFFDCB6E);
//   static const Color backgroundColor = Color(0xFFF5F6FA);
//   static const Color surfaceColor = Colors.white;
//   static const Color textColor = Color(0xFF2D3436);
//   static const Color textLightColor = Color(0xFF636E72);
//   static const Color dividerColor = Color(0xFFDFE6E9);

//   static ThemeData lightTheme = ThemeData(

//     useMaterial3: true,

//     colorScheme: ColorScheme.fromSeed(
//       seedColor: primaryColor,
//       brightness: Brightness.light,
//     ),

//     scaffoldBackgroundColor: backgroundColor,

//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryColor,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//     ),

//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),

//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: primaryColor,
//       ),
//     ),

//     inputDecorationTheme: InputDecorationTheme(

//       filled: true,
//       fillColor: Colors.white,

//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: dividerColor),
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: dividerColor),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: primaryColor, width: 2),
//       ),

//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(
//           color: Color.fromARGB(255, 255, 209, 209),
//         ),
//       ),

//       labelStyle: const TextStyle(color: textLightColor),
//       hintStyle: const TextStyle(color: textLightColor),
//     ),

//     textTheme: const TextTheme(

//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),

//       displayMedium: TextStyle(
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),

//       titleLarge: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),

//       titleMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: textColor,
//       ),

//       bodyLarge: TextStyle(
//         fontSize: 16,
//         color: textColor,
//       ),

//       bodyMedium: TextStyle(
//         fontSize: 14,
//         color: textColor,
//       ),

//       bodySmall: TextStyle(
//         fontSize: 12,
//         color: textLightColor,
//       ),
//     ),
//   );
// }