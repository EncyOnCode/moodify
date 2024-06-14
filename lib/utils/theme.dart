import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: const Color(0xFF1DB954),
      scaffoldBackgroundColor: const Color(0xFF191414),
      cardColor: const Color(0xFF2C2C2C),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16),
        labelLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),
        ),
      ),
    );
  }
}
