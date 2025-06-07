import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/text_styles.dart';
import '../../config/theme/dimensions.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ajustar padding según el tamaño de la pantalla
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isSmallScreen ? AppDimensions.paddingMedium : AppDimensions.paddingLarge;
    final verticalPadding = isSmallScreen ? AppDimensions.paddingSmall : AppDimensions.paddingMedium;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutline ? Colors.transparent : AppColors.accent,
        foregroundColor: isOutline ? Colors.white : AppColors.accent,
        side: BorderSide(
          color: isOutline ? Colors.white : AppColors.accent,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        elevation: isOutline ? 0 : AppDimensions.cardElevation,
      ),
      child: Text(
        text,
        style: AppTextStyles.button(context).copyWith(
          color: isOutline ? Colors.white : Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}