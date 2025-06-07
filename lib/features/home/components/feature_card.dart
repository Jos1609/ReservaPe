import 'package:flutter/material.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/text_styles.dart';
import '../../../config/theme/dimensions.dart';

class HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const HomeFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Escalar el tamaño del ícono y el padding según el ancho de la pantalla
    final iconSize = screenWidth < 600
        ? AppDimensions.iconSizeLarge
        : AppDimensions.iconSizeLarge * 1.2; // 20% más grande en pantallas grandes
    final padding = screenWidth < 600
        ? AppDimensions.paddingLarge
        : AppDimensions.paddingLarge * 1.3; // Más padding en pantallas grandes

    return Container(
      width: screenWidth < 600 ? double.infinity : 300, // Limita el ancho en pantallas grandes
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.cardElevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: AppColors.primary,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            title,
            style: AppTextStyles.heading3(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            description,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}