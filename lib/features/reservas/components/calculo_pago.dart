import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class PriceDisplay extends StatelessWidget {
  final double price;

  const PriceDisplay({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            'Precio Total',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.textLight,
              fontSize: isMobile ? 14 : null,
            ),
          ),
          Text(
            'S/ ${price.toStringAsFixed(2)}',
            style: AppTextStyles.heading3(context).copyWith(
              color: AppColors.primaryDark,
              fontSize: isMobile ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }
}