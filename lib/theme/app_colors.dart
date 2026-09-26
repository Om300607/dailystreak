import 'package:flutter/material.dart';

/// Shared "Midnight" palette: dark surfaces with a warm amber accent.
/// Centralizing these means every screen/widget stays visually consistent.
class AppColors {
  static const background1 = Color(0xFF161614);
  static const background2 = Color(0xFF232320);
  static const surface = Color(0xFF2B2B28);
  static const surfaceElevated = Color(0xFF39392F);
  static const border = Color(0xFF46453A);

  static const textPrimary = Color(0xFFF5F3EC);
  static const textSecondary = Color(0xFFB6B4A8);
  static const textMuted = Color(0xFF87867B);

  static const amber = Color(0xFFEF9F27);
  static const amberLight = Color(0xFFFAC775);
  static const amberDark = Color(0xFF854F0B);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background1, background2],
  );

  static const amberGradient = LinearGradient(
    colors: [amber, amberLight],
  );
}
