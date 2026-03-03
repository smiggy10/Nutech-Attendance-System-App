import 'package:flutter/material.dart';

class AppTheme {
  static const Color teal = Color(0xFF0A8B90);
  static const Color tealSoft = Color(0xFFD6F1F1);
  static const Color danger = Color(0xFF8F0A00);
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0xFFB9C2C7);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: teal,
        secondary: teal,
        error: danger,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: ink),
        headlineMedium: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
        bodyLarge: const TextStyle(fontSize: 16, color: ink),
        bodyMedium: const TextStyle(fontSize: 14, color: ink),
        bodySmall: const TextStyle(fontSize: 12, color: muted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: teal, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: teal, width: 1.0),
        ),
      ),
    );
  }
}
