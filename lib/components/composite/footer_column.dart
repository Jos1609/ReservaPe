import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';
import '../../config/theme/text_styles.dart';
import '../../config/theme/dimensions.dart';

class FooterColumn extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const FooterColumn({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 200, // Ajusta si quieres que no se desborde horizontalmente
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ajuste automático de alto
        children: [
          Text(
            title,
            style:
                AppTextStyles.heading3(context).copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...items.map((item) {
            final hasIcon = item['icon'] != null;
            final hasOnPressed = item['onPressed'] != null;

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: hasIcon
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item['icon'],
                          color: AppColors.white,
                          size: 14,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            item['label'],
                            style: AppTextStyles.body(context).copyWith(
                              color: Colors.white70,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    )
                  : hasOnPressed
                      ? TextButton(
                          onPressed: item['onPressed'],
                          child: Text(
                            item['label'],
                            style: AppTextStyles.body(context).copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(
                          item['label'],
                          style: AppTextStyles.body(context).copyWith(
                            color: Colors.white70,
                          ),
                          softWrap: true,
                        ),
            );
          }),
        ],
      ),
    );
  }
}
