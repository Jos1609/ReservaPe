import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Escala el tamaño de fuente según el ancho de la pantalla
  static double _scaleFont(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    // Factor de escala: 1.0 para pantallas >= 768px, menor para pantallas más pequeñas
    final scale = width < 768 ? width / 768 : 1.0;
    return baseSize * scale.clamp(0.7, 1.0); // Limita la reducción al 70%
  }

  static TextStyle heading1(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 48),
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
      );

  static TextStyle heading2(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 32),
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      );

  static TextStyle heading3(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 16),
        color: AppColors.textLight,
        height: 1.7,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 16),
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

    static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.gray,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle bodyBold(BuildContext context) => TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: _scaleFont(context, 16),
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

    static TextStyle caption(BuildContext context) {
  return const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

 static final heading1card = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static final heading2card = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static final heading3card = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static final bodycard = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
  );

  static final bodyBoldcard = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static final captioncard = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Cuerpo de texto
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  // Otros estilos
  static const TextStyle button1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  static const TextStyle caption2 = TextStyle(
 fontSize: 10,
 fontWeight: FontWeight.w400,
 height: 1.2,
 letterSpacing: 0.4,
);

}