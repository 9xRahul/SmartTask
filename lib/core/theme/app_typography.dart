import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Clean, modern typography using Google Fonts (Inter).
class AppTypography {
  AppTypography._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimaryLight,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryLight,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondaryLight,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimaryDark,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
    ),
  );
}
