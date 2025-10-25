import 'package:flutter/material.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  static void toggleTheme(bool isDarkMode) {
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
}
