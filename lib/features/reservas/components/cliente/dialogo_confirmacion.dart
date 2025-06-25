import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class ReservationConfirmationDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onDismiss;

  const ReservationConfirmationDialog({
    super.key,
    required this.isSuccess,
    required this.message,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isSuccess,
    required String message,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReservationConfirmationDialog(
        isSuccess: isSuccess,
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<ReservationConfirmationDialog> createState() => _ReservationConfirmationDialogState();
}

class _ReservationConfirmationDialogState extends State<ReservationConfirmationDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animación o ícono
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.isSuccess 
                      // ignore: deprecated_member_use
                      ? AppColors.success.withOpacity(0.1)
                      // ignore: deprecated_member_use
                      : AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isSuccess 
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 60,
                  color: widget.isSuccess 
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Título
              Text(
                widget.isSuccess 
                    ? '¡Reserva Confirmada!' 
                    : 'Error en la Reserva',
                style: AppTextStyles.h2.copyWith(
                  color: widget.isSuccess 
                      ? AppColors.success
                      : AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.paddingMedium),
              
              // Mensaje
              Text(
                widget.message,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Botón
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isSuccess 
                      ? AppColors.primary 
                      : AppColors.error,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
                child: Text(
                  widget.isSuccess ? 'Continuar' : 'Cerrar',
                  style: AppTextStyles.button1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}