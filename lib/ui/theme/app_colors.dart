import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Main text
  static const Color textSecondary = Color(
    0xFF6A6A6A,
  ); // Subtitles, hints (Updated from 8E8E93)
  static const Color textTertiary = Color(0xFFC7C7CC); // Disabled, placeholders
  static const Color textInverse = Color(0xFFFFFFFF);

  // Brand/Action Colors
  static const Color primary = Color(0xFF2C2C2C); // Soft Black
  static const Color primaryLight = Color(0xFF4A4A4A);
  static const Color accent = Color(0xFF6200EE); // Keep for specific highlights

  // UI Elements
  static const Color divider = Color(0xFFF0F0F0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000); // 10% Black

  // Input Fields
  static const Color inputBackground = Color(0xFFF8F8F8);
  static const Color inputHint = Color(0xFFB4B4B4);

  // Functional Colors
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF32D74B);

  // Pastel Colors (for Groups/Tags)
  static const Color pastelRed = Color(0xFFFFE9E9);
  static const Color pastelOrange = Color(0xFFFFECD7);
  static const Color pastelYellow = Color(0xFFFFF7C7);
  static const Color pastelGreen = Color(0xFFDFFFC7);
  static const Color pastelCyan = Color(0xFFD6FAFF);
  static const Color pastelBlue = Color(0xFFC0DCFF);
  static const Color pastelPurple = Color(0xFFEED3FF);
  static const Color pastelGray = Color(0xFFD9D9D9);

  // Group Specific Colors (Mapped to logical names)
  static const Color groupFamily = pastelRed;
  static const Color groupFriend = pastelYellow;
  static const Color groupWork = pastelBlue;
  static const Color groupEtc = pastelGray;
}
