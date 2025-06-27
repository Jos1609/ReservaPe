import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/models/cancha.dart';

class ReservationHeader extends StatelessWidget {
  final CourtModel court;
  final VoidCallback onBackPressed;

  const ReservationHeader({
    super.key,
    required this.court,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          Text(
            'Reservas - ${court.name}',
            style: AppTextStyles.heading3(context).copyWith(
              color: AppColors.primary,
              fontSize: isMobile ? 18 : null,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [        
        Flexible(
          child: Text(
            'Reservas - ${court.name}',
            style: AppTextStyles.heading3(context)
                .copyWith(color: AppColors.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}