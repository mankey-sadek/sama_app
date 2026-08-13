import 'package:flutter/material.dart';

/// نفس ألوان النموذج الأولي (HTML Prototype) بالظبط، عشان تطبيق الموبايل
/// يطلع مطابق لما اتفقنا عليه في التصميم.
class AppColors {
  AppColors._();

  static const surface1 = Color(0xFF1A1A19);
  static const pagePlane = Color(0xFF0D0D0D);
  static const surfaceRaised = Color(0xFF232322);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFC3C2B7);
  static const textMuted = Color(0xFF898781);

  static const gridline = Color(0xFF2C2C2A);
  static const border = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)

  static const seriesBlue = Color(0xFF3987E5);
  static const seriesAqua = Color(0xFF199E70);
  static const seriesViolet = Color(0xFF9085E9);
  static const seriesOrange = Color(0xFFEB6834);

  static const statusGood = Color(0xFF0CA30C);
  static const statusWarning = Color(0xFFFAB219);
  static const statusSerious = Color(0xFFEC835A);
  static const statusCritical = Color(0xFFE66767);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.pagePlane,
      primaryColor: AppColors.seriesBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.seriesBlue,
        secondary: AppColors.seriesAqua,
        surface: AppColors.surface1,
        error: AppColors.statusCritical,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pagePlane,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.gridline,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
