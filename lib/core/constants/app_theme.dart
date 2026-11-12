import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.gold,
        surface: AppColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.navy,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ivory,
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.green,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8E1D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB54747)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB54747), width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    return theme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(theme.textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.ivory,
          minimumSize: const Size.fromHeight(56),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
