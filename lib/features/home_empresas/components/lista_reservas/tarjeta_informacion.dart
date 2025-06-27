import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/models/cancha.dart';

class FieldInfoCard extends StatelessWidget {
  final CourtModel court;

  const FieldInfoCard({super.key, required this.court});

  Widget _buildMetaItem(BuildContext context,
      {required IconData icon, required String text}) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 14 : 16, color: AppColors.textLight),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: isMobile ? 12 : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppDimensions.mobileBreakpoint;
    final imageSize = isMobile ? 60.0 : 80.0;

    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile
            ? AppDimensions.paddingSmall
            : AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
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
            SizedBox(
                width: isMobile
                    ? AppDimensions.spacingSmall
                    : AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: AppTextStyles.heading3(context).copyWith(
                      fontSize: isMobile ? 16 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: AppDimensions.spacingSmall,
                    runSpacing: AppDimensions.spacingXSmall,
                    children: [
                      _buildMetaItem(
                        context,
                        icon: Icons.group,
                        text: '${court.teamCapacity}v${court.teamCapacity}',
                      ),
                      _buildMetaItem(
                        context,
                        icon: Icons.attach_money,
                        text: '${court.dayPrice.toStringAsFixed(0)}/h',
                      ),
                      _buildMetaItem(
                        context,
                        icon: Icons.roofing,
                        text: court.hasRoof ? 'Cubierta' : 'Sin techo',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}