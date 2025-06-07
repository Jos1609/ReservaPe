import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 16, // Tamaño base, widgets usarán estilos dinámicos
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
            minimumSize: const Size(0, 0), // Permite botones más pequeños
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 16,
            color: AppColors.textLight,
            height: 1.7,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).apply(
          fontFamily: 'Segoe UI',
        ),
      );

  
}