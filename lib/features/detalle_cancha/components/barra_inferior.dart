import 'package:flutter/material.dart';
import 'package:sintetico/features/detalle_cancha/services/detalle_cancha_servicio.dart';
import 'package:sintetico/models/cancha.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:intl/intl.dart';

class BookingBottomBar extends StatelessWidget {
  final CourtModel court;
  final List<TimeSlot> selectedSlots; 
  final double totalPrice;
  final VoidCallback onBookingPressed;

  const BookingBottomBar({
    super.key,
    required this.court,
    required this.selectedSlots, 
    required this.totalPrice,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = selectedSlots.first.startTime;
    final endTime = selectedSlots.last.endTime;
    final totalHours = selectedSlots.length;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
        top: AppDimensions.paddingMedium,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Información de la reserva
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reserva seleccionada',
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM').format(startTime),
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$totalHours hora${totalHours > 1 ? 's' : ''}',
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'Total: S/ ${totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón de reservar
            ElevatedButton(
              onPressed: onBookingPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                elevation: 0,
              ),
              child: Text(
                'Reservar',
                style: AppTextStyles.button1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}