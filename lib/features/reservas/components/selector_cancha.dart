import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/models/cancha.dart';

class CourtSelector extends StatelessWidget {
  final CourtModel court;

  const CourtSelector({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppDimensions.paddingSmall : AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              width: isMobile ? 60.0 : 80.0,
              height: isMobile ? 60.0: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.gray,
                image: court.photos.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(court.photos.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            SizedBox(width: isMobile ? AppDimensions.spacingSmall : AppDimensions.spacingMedium),
            Expanded(
              child: Text(
                court.name,
                style: AppTextStyles.heading3(context).copyWith(
                  fontSize: isMobile ? 16 : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}