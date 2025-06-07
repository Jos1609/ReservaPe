import 'package:flutter/material.dart';
import 'package:sintetico/components/composite/app_navbar.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';

class ResponsiveHeader extends StatelessWidget {
  final String backgroundImageUrl;
  final String title;
  final String description;
  final List<Map<String, dynamic>> navItems;
  final VoidCallback? onExplorePressed;
  final VoidCallback? onHowItWorksPressed;

  const ResponsiveHeader({
    super.key,
    this.backgroundImageUrl =
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    required this.title,
    required this.description,
    required this.navItems,
    this.onExplorePressed,
    this.onHowItWorksPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;

    final headingScale = isSmallScreen ? 0.7 : isMediumScreen ? 0.85 : 1.0;
    final bodyScale = isSmallScreen ? 0.85 : 1.0;
    final horizontalPadding =
        isSmallScreen ? AppDimensions.paddingSmall : AppDimensions.paddingMedium;

    final titleMaxLines = isSmallScreen ? 2 : 3;
    final descriptionMaxLines = isSmallScreen ? 2 : 4;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImageUrl),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: AppNavbar(navItems: navItems),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isSmallScreen ? AppDimensions.paddingSmall : AppDimensions.paddingMedium,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading1(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (AppTextStyles.heading1(context).fontSize ?? 32) * headingScale,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: isSmallScreen
                        ? AppDimensions.paddingXSmall * 0.2
                        : AppDimensions.paddingSmall),
                    Text(
                      description,
                      style: AppTextStyles.body(context).copyWith(
                        color: Colors.white,
                        fontSize: (AppTextStyles.body(context).fontSize ?? 16) * bodyScale,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: descriptionMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: isSmallScreen
                        ? AppDimensions.paddingXSmall * 0.2
                        : AppDimensions.paddingSmall),
                    Wrap(
                      spacing: isSmallScreen
                          ? AppDimensions.paddingXSmall
                          : AppDimensions.paddingSmall,
                      runSpacing: AppDimensions.paddingXSmall,
                      alignment: WrapAlignment.center,                      
                      
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 40 : 50),
        ],
      ),
    );
  }
}
