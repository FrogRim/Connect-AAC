// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFF6D63FF); // 부드러운 보라색
  static const Color secondaryColor = Color(0xFF7E89FD); // 밝은 보라색
  static const Color accentColor = Color(0xFFFFA26B); // 따뜻한 오렌지색
  static const Color backgroundColor = Color(0xFFF8F9FF); // 옅은 보라색 배경
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color textLightColor = Color(0xFF666666);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6D63FF), // 보라색 시작
    Color(0xFF5D8BF9), // 파란색으로 전환
  ];

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF5B4DDB);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFEEEEEE);

  // --- ThemeData Definitions ---

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    hintColor: accentColor, // Use accentColor for hintColor
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    fontFamily: 'Pretendard', // Example: Add default font family
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(color: textLightColor, fontSize: 16),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // For buttons
      // Define other text styles as needed
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black, // Adjust based on secondaryColor contrast
      onBackground: textColor,
      onSurface: textColor,
      error: Colors.redAccent,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      foregroundColor: Colors.white, // Ensures text/icons on AppBar are white
      elevation: 1,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Pretendard',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // background
            foregroundColor: Colors.white, // foreground (text)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textLightColor),
        hintStyle: const TextStyle(color: textLightColor)),
    // Add other theme properties like buttonTheme, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    hintColor: accentColor, // Use accentColor for hintColor
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    fontFamily: 'Pretendard',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(color: darkTextColor, fontSize: 16),
      labelLarge: TextStyle(color: darkTextColor, fontSize: 16, fontWeight: FontWeight.bold), // For buttons
      // Define other text styles as needed
    ),
     colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: secondaryColor, // You might want a different secondary for dark theme
      background: darkBackgroundColor,
      surface: darkCardColor,
      onPrimary: darkTextColor,
      onSecondary: darkTextColor,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
      error: Colors.red,
      onError: darkTextColor,
      brightness: Brightness.dark,
    ),
     appBarTheme: const AppBarTheme(
      color: darkPrimaryColor,
      foregroundColor: darkTextColor, // Ensures text/icons on AppBar are light
      elevation: 1,
       titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Pretendard',
      ),
    ),
     elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryColor, // background
            foregroundColor: darkTextColor, // foreground (text)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2), // Use accent color for focus in dark
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade400)),
    // Add other theme properties for dark theme
  );
}
