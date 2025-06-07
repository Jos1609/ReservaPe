import 'package:flutter/material.dart';
import 'package:sintetico/config/constants/strings_home.dart';
import '../../config/theme/text_styles.dart';
import '../../config/theme/dimensions.dart';

class AppNavbar extends StatelessWidget {
  final List<Map<String, dynamic>> navItems;

  const AppNavbar({
    super.key,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.7),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600; // Breakpoint ajustado para pantallas pequeñas
          return isMobile
              ? Column(
                  children: [
                    _buildLogo(context),
                    SizedBox(height: AppDimensions.paddingSmall),
                    _buildNavLinks(context, navItems, isMobile: true),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLogo(context),
                    _buildNavLinks(context, navItems),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Text(
      AppStrings.footerTitle,
      style: AppTextStyles.heading3(context).copyWith(
        color: Colors.white,
        fontSize: AppTextStyles.heading3(context).fontSize! + 4, // Ligeramente más grande
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNavLinks(BuildContext context, List<Map<String, dynamic>> items, {bool isMobile = false}) {
    return Wrap(
      spacing: isMobile ? AppDimensions.paddingSmall : AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingSmall,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
      children: items.map((item) {
        return TextButton(
          onPressed: item['onPressed'],
          child: Text(
            item['label'],
            style: AppTextStyles.button(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}