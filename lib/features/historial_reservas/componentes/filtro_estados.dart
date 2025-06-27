import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class ReservationStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final Map<String, int>? counts;

  const ReservationStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'value': 'Todas', 'label': 'Todas', 'color': AppColors.primary},
      {'value': 'Pendiente', 'label': 'Pendientes', 'color': AppColors.warning},
      {'value': 'Confirmada', 'label': 'Confirmadas', 'color': AppColors.success},
      {'value': 'Rechazada', 'label': 'Rechazadas', 'color': AppColors.error},
      {'value': 'Cancelada', 'label': 'Canceladas', 'color': AppColors.textSecondary},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = selectedStatus == status['value'];
          final count = counts?[status['value'] as String] ?? 0;

          return Padding(
            padding: EdgeInsets.only(
              right: index < statuses.length - 1 ? AppDimensions.paddingSmall : 0,
            ),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status['label'] as String,
                    style: AppTextStyles.caption1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            // ignore: deprecated_member_use
                            ? Colors.white.withOpacity(0.2)
                            // ignore: deprecated_member_use
                            : (status['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: AppTextStyles.caption2.copyWith(
                          color: isSelected ? Colors.white : status['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onStatusChanged(status['value'] as String),
              selectedColor: status['color'] as Color,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected 
                    ? status['color'] as Color 
                    : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
            ),
          );
        },
      ),
    );
  }
}