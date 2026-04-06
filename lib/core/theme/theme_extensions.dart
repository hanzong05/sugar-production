import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_gradients.dart';

// ============================================================
//  HELPER EXTENSION  —  Theme-aware gradient / color getters
//  Usage:  context.gradients.primary
//          context.appColors.background
// ============================================================

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  _AppGradients get gradients => _AppGradients(isDark);
  _AppColors get appColors => _AppColors(isDark);
}

class _AppGradients {
  final bool dark;
  const _AppGradients(this.dark);

  LinearGradient get primary => AppGradients.primaryGradient;
  LinearGradient get header =>
      dark ? AppGradients.darkHeaderGradient : AppGradients.primaryGradient;
  LinearGradient get card =>
      dark ? AppGradients.darkCardGradient : AppGradients.lightCardGradient;
  LinearGradient get background =>
      dark ? AppGradients.darkBgGradient : AppGradients.lightBgGradient;
  LinearGradient get danger => AppGradients.dangerGradient;
  LinearGradient get warning => AppGradients.warningGradient;
}

class _AppColors {
  final bool dark;
  const _AppColors(this.dark);

  Color get background =>
      dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface => dark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceAlt =>
      dark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
  Color get border => dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textPrimary =>
      dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textHint => dark ? AppColors.darkTextHint : AppColors.lightTextHint;
  Color get primary => dark ? AppColors.primaryLight : AppColors.primary;
}
