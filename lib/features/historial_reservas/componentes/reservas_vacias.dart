import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class EmptyReservations extends StatelessWidget {
  final String statusFilter;
  final VoidCallback? onExplore;

  const EmptyReservations({
    super.key,
    required this.statusFilter,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 80,
              // ignore: deprecated_member_use
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Text(
              _getTitle(),
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              _getMessage(),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (statusFilter == 'Todas' && onExplore != null) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      'Explorar Canchas',
                      style: AppTextStyles.button1,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (statusFilter) {
      case 'Pendiente':
        return Icons.hourglass_empty;
      case 'Confirmada':
        return Icons.check_circle_outline;
      case 'Rechazada':
        return Icons.cancel_outlined;
      case 'Cancelada':
        return Icons.block;
      default:
        return Icons.event_note;
    }
  }

  String _getTitle() {
    switch (statusFilter) {
      case 'Pendiente':
        return 'No hay reservas pendientes';
      case 'Confirmada':
        return 'No hay reservas confirmadas';
      case 'Rechazada':
        return 'No hay reservas rechazadas';
      case 'Cancelada':
        return 'No hay reservas canceladas';
      default:
        return 'No tienes reservas aún';
    }
  }

  String _getMessage() {
    switch (statusFilter) {
      case 'Pendiente':
        return 'Las reservas pendientes aparecerán aquí mientras esperan confirmación.';
      case 'Confirmada':
        return 'Las reservas confirmadas y listas para jugar aparecerán aquí.';
      case 'Rechazada':
        return 'Las reservas que no pudieron ser confirmadas aparecerán aquí.';
      case 'Cancelada':
        return 'Las reservas que hayas cancelado aparecerán aquí.';
      default:
        return '¡Empieza a reservar canchas y disfruta del deporte!';
    }
  }
}