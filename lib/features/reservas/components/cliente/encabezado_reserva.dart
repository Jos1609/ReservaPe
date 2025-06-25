import 'package:flutter/material.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';
import 'package:intl/intl.dart';

class ReservationHeader extends StatelessWidget {
  final CourtModel court;
  final CompanyModel company;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;

  const ReservationHeader({
    super.key,
    required this.court,
    required this.company,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d \'de\' MMMM', 'es');
    final timeFormat = DateFormat('HH:mm');
    final duration = endTime.difference(startTime).inHours;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Resumen de Reserva',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Información de la cancha
          _buildInfoRow(
            icon: Icons.sports_soccer,
            label: 'Cancha',
            value: court.name,
            valueStyle: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Empresa
          _buildInfoRow(
            icon: Icons.business,
            label: 'Lugar',
            value: company.name,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Fecha
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Fecha',
            value: dateFormat.format(startTime),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Hora
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Horario',
            value: '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)} ($duration ${duration > 1 ? "horas" : "hora"})',
          ),

          const Divider(
            height: AppDimensions.paddingLarge * 2,
            color: AppColors.divider,
          ),

          // Información de pago
          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ?? AppTextStyles.body2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      children: [
        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total de la reserva',
              style: AppTextStyles.body1,
            ),
            Text(
              'S/ ${totalPrice.toStringAsFixed(2)}',
              style: AppTextStyles.h3,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Adelanto
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppDimensions.paddingXSmall),
                  Text(
                    'Adelanto (50%)',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'S/ ${depositAmount.toStringAsFixed(2)}',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Restante
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Por pagar en cancha',
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'S/ ${remainingAmount.toStringAsFixed(2)}',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}