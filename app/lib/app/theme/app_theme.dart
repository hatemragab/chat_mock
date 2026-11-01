import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static const _fontFallbacks = ['NotoEmoji', 'NotoSansSymbols'];

  static ThemeData create(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final accent = dark ? AppColors.darkAccent : AppColors.lightAccent;
    final page = dark ? AppColors.darkPage : AppColors.lightPage;
    final text = dark ? AppColors.darkText : AppColors.lightText;
    final secondary = dark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final onAccent = dark ? AppColors.darkCanvas : Colors.white;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppGeometry.buttonRadius),
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      surface: dark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: text,
      onSurfaceVariant: secondary,
      outlineVariant: border,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      dividerColor: border,
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallbacks,
      textTheme: Typography.material2021(platform: TargetPlatform.android).black
          .apply(
            fontFamily: 'Roboto',
            bodyColor: text,
            displayColor: text,
            fontFamilyFallback: _fontFallbacks,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: page,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: AppGeometry.headerHeight,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkCanvas : AppColors.lightCanvas,
        hintStyle: TextStyle(color: secondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppGeometry.cardRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: page,
        indicatorColor: accent.withValues(alpha: .13),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(0, AppGeometry.buttonHeight),
          shape: buttonShape,
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppGeometry.buttonHeight),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, AppGeometry.buttonHeight),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, AppGeometry.iconTarget),
          shape: buttonShape,
        ),
      ),
    );
  }
}
