import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Primary brand gradient (AppBar, buttons, header)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Reversed / vivid variant
  static const LinearGradient primaryGradientVivid = LinearGradient(
    colors: [Color(0xFF0070FF), Color(0xFF5B6BFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dark-mode header gradient
  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF1A2A4A), Color(0xFF0D1A30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle card shimmer (light)
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle card shimmer (dark)
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1C2430), Color(0xFF161B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Danger gradient (delete / reset actions)
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Amber / warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Full-screen background gradient (light)
  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFF4F6F8), Color(0xFFEAF0FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Full-screen background gradient (dark)
  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
