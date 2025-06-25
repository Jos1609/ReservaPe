import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/dimensions.dart';
import '../../config/theme/text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isOpen;

  const StatusBadge({
    super.key,
    required this.status,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isOpen ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(
          color: isOpen ? AppColors.success : AppColors.error,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppDimensions.paddingXSmall),
          Text(
            status,
            style: AppTextStyles.caption1.copyWith(
              color: isOpen ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}