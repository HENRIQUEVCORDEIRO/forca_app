import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFE6E6FA);
  static const Color accent = Color(0xFF8A2BE2);
  static const Color onAccent = Colors.white;
  static const Color keyboardButton = Color(0xFF808080);
  static const Color keyboardLetter = Colors.white;
}

class AppTextStyles {
  const AppTextStyles._();

  static const String screamFontFamily = 'HangmanFont';

  static const TextStyle title = TextStyle(
    fontFamily: screamFontFamily,
    color: AppColors.accent,
    fontWeight: FontWeight.bold,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: AppColors.accent)
        .copyWith(
          primary: AppColors.accent,
          onPrimary: AppColors.onAccent,
          secondary: AppColors.accent,
          onSecondary: AppColors.onAccent,
          surface: AppColors.background,
          onSurface: AppColors.accent,
          outline: AppColors.accent,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.accent,
        displayColor: AppColors.accent,
      ),
    );
  }
}
