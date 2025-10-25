import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Màu dùng chung
  static const Color primaryColor = Color(0xFF6E3AE3);
  static const Color secondaryColor = Color(0xFFFF8700);
  static const Color successColor = Color(0xFF00B894);
  static const Color dangerColor = Color(0xFFFF4757);
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color darkBackground = Color(0xFF121212);

  // 🌞 Chủ đề sáng
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );

  // 🌙 Chủ đề tối
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );

  // 🌈 Trang trí card trắng (light mode)
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  // 🌈 Gradient
  static BoxDecoration gradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryColor, Color(0xFF9B6DFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
