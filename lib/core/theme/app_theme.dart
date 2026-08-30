import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF345995);
  static const secondary = Color(0xFF5B7DB1);
  static const surface = Color(0xFFF7F9FC);
  static const text = Color(0xFF172033);
  static const mutedText = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
}

abstract final class AppTextStyles {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.text,
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineSmall: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
