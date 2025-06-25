import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class ReservationActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onNavigate;
  final bool isReservationComplete;

  const ReservationActions({
    super.key,
    required this.onShare,
    required this.onNavigate,
    required this.isReservationComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isReservationComplete) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿Qué deseas hacer?',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Botón compartir
          _ActionButton(
            onPressed: onShare,
            icon: Icons.share,
            label: 'Compartir Reserva',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),

          // Botón cómo llegar
          _ActionButton(
            onPressed: onNavigate,
            icon: Icons.directions,
            label: 'Cómo llegar',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            borderColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 2)
              : BorderSide.none,
        ),
        elevation: borderColor != null ? 0 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            label,
            style: AppTextStyles.button1.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}