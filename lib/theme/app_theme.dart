import 'package:flutter/material.dart';

import 'us_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final baseColorScheme =
        const ColorScheme.light(
          primary: AppColors.colorPrimary500,
          onPrimary: Colors.white,
          secondary: AppColors.colorPrimary500,
          onSecondary: Colors.white,
          error: AppColors.colorError,
          onError: Colors.white,
        ).copyWith(
          surface: AppColors.colorSurface,
          onSurface: AppColors.colorTextBody,
          surfaceTint: Colors.transparent,
          outline: AppColors.colorGray300,
          surfaceContainer: AppColors.colorBackgroundDefault,
          surfaceContainerLow: AppColors.colorBackgroundDefault,
          surfaceContainerLowest: AppColors.colorBackgroundDefault,
          surfaceContainerHigh: AppColors.colorSurface,
          surfaceContainerHighest: AppColors.colorSurface,
        );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'SpoqaHanSansNeo',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: baseColorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.colorBackgroundDefault,
      cardTheme: CardThemeData(
        color: AppColors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _textTheme(
        base.textTheme,
        AppColors.colorTextBody,
        AppColors.colorTextCaption,
      ),
      iconTheme: const IconThemeData(size: 24, color: AppColors.colorTextBody),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.colorBackgroundDefault,
        elevation: 0,
        foregroundColor: AppColors.colorTextBody,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          ),
          foregroundColor: Colors.white,
          backgroundColor: AppColors.colorPrimary500,
          overlayColor: AppColors.colorPrimary600.withValues(alpha: 0.12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          foregroundColor: AppColors.colorPrimary500,
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.colorSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          borderSide: const BorderSide(color: AppColors.colorGray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          borderSide: const BorderSide(color: AppColors.colorGray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          borderSide: const BorderSide(color: AppColors.colorPrimary500),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          borderSide: const BorderSide(color: AppColors.colorError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          borderSide: const BorderSide(color: AppColors.colorError),
        ),
        errorStyle: base.textTheme.bodySmall?.copyWith(
          color: AppColors.colorError,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.colorSurface,
        selectedItemColor: AppColors.colorPrimary500,
        unselectedItemColor: AppColors.colorTextCaption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: AppColors.colorGray300,
    );
  }

  static TextTheme _textTheme(
    TextTheme base,
    Color bodyColor,
    Color captionColor,
  ) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: bodyColor),
      displayMedium: base.displayMedium?.copyWith(color: bodyColor),
      displaySmall: base.displaySmall?.copyWith(color: bodyColor),
      headlineLarge: base.headlineLarge?.copyWith(color: bodyColor),
      headlineMedium: base.headlineMedium?.copyWith(color: bodyColor),
      headlineSmall: base.headlineSmall?.copyWith(color: bodyColor),
      titleLarge: base.titleLarge?.copyWith(color: bodyColor),
      titleMedium: base.titleMedium?.copyWith(color: bodyColor),
      titleSmall: base.titleSmall?.copyWith(color: bodyColor),
      bodyLarge: base.bodyLarge?.copyWith(color: bodyColor),
      bodyMedium: base.bodyMedium?.copyWith(color: bodyColor),
      bodySmall: base.bodySmall?.copyWith(color: captionColor),
      labelLarge: base.labelLarge?.copyWith(color: bodyColor),
      labelMedium: base.labelMedium?.copyWith(color: captionColor),
      labelSmall: base.labelSmall?.copyWith(color: captionColor),
    );
  }
}
