import 'package:flutter/material.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/text_styles.dart';
import '../../../config/theme/dimensions.dart';

class HomeStepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const HomeStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Escalar el tamaño del círculo según el ancho de la pantalla
    final circleSize = screenWidth < 600 ? 50.0 : 60.0; // Más grande en pantallas grandes
    final cardWidth = screenWidth < 600 ? double.infinity : 250.0; // Limita el ancho

    return SizedBox(
      width: cardWidth,
      child: Column(
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: AppTextStyles.button(context).copyWith(color: Colors.white),
              ),
            ),
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