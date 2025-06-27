import 'package:flutter/material.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/models/reserva.dart';
import 'package:sintetico/models/cancha.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final CourtModel? court;
  final CompanyModel? company;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.court,
    this.company,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');
    final duration = reservation.endTime.difference(reservation.startTime).inHours;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
          children: [
            // Header con estado
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: _getStatusColor(reservation.status).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.borderRadius),
                  topRight: Radius.circular(AppDimensions.borderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reservation.status),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                    ),
                    child: Text(
                      _getStatusText(reservation.status),
                      style: AppTextStyles.caption1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // ID de reserva
                  Text(
                    'ID: ${reservation.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la cancha
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Expanded(
                        child: Text(
                          court?.name ?? 'Cargando...',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingSmall),
                  
                  // Empresa
                  if (company != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            company!.name,
                            style: AppTextStyles.caption1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                  ],

                  // Fecha y hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        dateFormat.format(reservation.startTime),
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        '${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}',
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        ' ($duration ${duration > 1 ? "horas" : "hora"})',
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total pagado:',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'S/ ${reservation.totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Botón de cancelar si aplica
                  if (onCancel != null && _canShowCancelButton()) ...[
                    const SizedBox(height: AppDimensions.paddingMedium),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                          ),
                        ),
                        child: const Text('Cancelar Reserva'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canShowCancelButton() {
    return (reservation.status == 'Pendiente' || reservation.status == 'Confirmada') &&
           reservation.startTime.isAfter(DateTime.now());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return AppColors.warning;
      case 'Confirmada':
        return AppColors.success;
      case 'Rechazada':
        return AppColors.error;
      case 'Cancelada':
        return AppColors.textSecondary;
      case 'Completada':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pendiente':
        return 'Pendiente';
      case 'Confirmada':
        return 'Confirmada';
      case 'Rechazada':
        return 'Rechazada';
      case 'Cancelada':
        return 'Cancelada';
      case 'Completada':
        return 'Completada';
      default:
        return status;
    }
  }
}