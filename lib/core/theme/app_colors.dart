import 'package:flutter/material.dart';

/// App color palette designed for high aesthetic appeal in both Light and Dark themes.
class AppColors {
  AppColors._();

  // Primary Branding
  static const Color primary = Color(0xFF4F46E5); // Modern Indigo
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryContainerLight = Color(0xFFEEF2FF);
  static const Color primaryContainerDark = Color(0xFF312E81);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Category Colors
  static const Color categoryWork = Color(0xFF6366F1);
  static const Color categoryPersonal = Color(0xFFEC4899);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryFinance = Color(0xFFF59E0B);
  static const Color categoryEducation = Color(0xFF8B5CF6);
  static const Color categoryShopping = Color(0xFF06B6D4);
  static const Color categoryTravel = Color(0xFFF97316);
  static const Color categoryOthers = Color(0xFF64748B);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);
}
