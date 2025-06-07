import 'package:flutter/material.dart';
import '../../config/theme/text_styles.dart';
import '../../config/theme/dimensions.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String description;

  const SectionTitle({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.heading2(context),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppDimensions.paddingMedium),
        Text(
          description,
          style: AppTextStyles.body(context),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}