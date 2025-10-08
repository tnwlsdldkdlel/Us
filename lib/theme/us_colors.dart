import 'package:flutter/material.dart';

/// Global color tokens derived from the documented design system.
class AppColors {
  static const Color colorPrimary500 = Color(0xFF10B981);
  static const Color colorPrimary600 = Color(0xFF059669);
  static const Color colorPrimary400 = Color(0xFF34D399);

  static const Color colorBackgroundDefault = Color(0xFFF9FAFB);
  static const Color colorSurface = Colors.white;

  static const Color colorGray300 = Color(0xFFD1D5DB);
  static const Color colorTextBody = Color(0xFF4B5563);
  static const Color colorTextCaption = Color(0xFF9CA3AF);

  static const Color colorError = Color(0xFFFF4D7E);
  static const Color colorWarning = Color(0xFFFBBF24);
}

/// Spacing tokens (dp) based on the 4px grid defined in the design codex.
class AppSpacing {
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
}

/// Corner radius tokens standardised for the project.
class AppRadius {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 24.0;
}

/// Legacy shim to keep existing imports compiling while migrating to [AppColors].
class UsColors {
  static const Color primary = AppColors.colorPrimary500;
  static const Color primaryLight = AppColors.colorPrimary400;
  static const Color accent = Color(0xFFFF8A34);
}
