import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final Function(String?) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  static const methods = [
    {'name': 'Efectivo', 'icon': Icons.money},
    {'name': 'Tarjeta', 'icon': Icons.credit_card},
    {'name': 'Transferencia', 'icon': Icons.account_balance},
    {'name': 'Yape', 'icon': Icons.phone_android},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: AppTextStyles.heading3(context).copyWith(fontSize: isMobile ? 16 : null),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Wrap(
          spacing: AppDimensions.spacingSmall,
          runSpacing: AppDimensions.spacingSmall,
          children: methods.map((method) {
            final isSelected = selectedMethod == method['name'];
            return GestureDetector(
              onTap: () => onMethodSelected(method['name'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.light,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: isMobile ? 16 : 18,
                      color: isSelected ? AppColors.white : AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      method['name'] as String,
                      style: AppTextStyles.body(context).copyWith(
                        color: isSelected ? AppColors.white : AppColors.textLight,
                        fontSize: isMobile ? 12 : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}