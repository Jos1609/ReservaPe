import 'package:flutter/material.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';


class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30, // Mostrar 30 días
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 65,
              margin: EdgeInsets.only(
                right: AppDimensions.paddingSmall,
                left: index == 0 ? 0 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: AppTextStyles.caption2.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.h3.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMonthName(date),
                    style: AppTextStyles.caption2.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'HOY';
    } else if (_isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'MAÑ';
    }
    
    final dayNames = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return dayNames[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    final monthNames = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return monthNames[date.month - 1];
  }
}