import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/constants/strings_home.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/home/components/company_card.dart';
import 'package:sintetico/features/home/components/feature_card.dart';
import 'package:sintetico/features/home/components/responsive_header.dart';
import 'package:sintetico/features/home/components/step_card.dart';
import 'package:sintetico/features/home/controllers/home_controller.dart';
import 'package:sintetico/features/auth/components/login_screen.dart';
import '../../../components/ui/app_button.dart';
import '../../../components/ui/section_title.dart';
import '../../../components/composite/footer_column.dart';
import '../../../components/ui/social_link.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final _companiesSectionKey = GlobalKey();
  final _contactSectionKey = GlobalKey();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveHeader(
                title: AppStrings.headerTitle,
                description: AppStrings.headerDescription,
                navItems: [
                  {
                    'label': AppStrings.navCompanies,
                    'onPressed': () {
                      _scrollToSection(_companiesSectionKey, context);
                    }
                  },
                  {
                    'label': AppStrings.navContact,
                    'onPressed': () {
                      _scrollToSection(_contactSectionKey, context);
                    }
                  },
                  {
                    'label': AppStrings.buttonLogin,
                    'onPressed': () {
                      LoginDialog.show(context);
                    }
                  },
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildFeaturesSection(context)),
            SliverToBoxAdapter(
              key: _companiesSectionKey,
              child: _buildCompaniesSection(context),
            ),
            SliverToBoxAdapter(child: _buildHowItWorksSection(context)),
            SliverToBoxAdapter(
              key: _contactSectionKey,
              child: _buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  // Nueva función para desplazar a una sección
  void _scrollToSection(GlobalKey key, BuildContext context) {
    final sectionContext = key.currentContext;
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Resto del código (sin cambios en las secciones)
  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      color: Colors.white,
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.featuresTitle,
            description: AppStrings.featuresDescription,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final crossAxisCount = screenWidth > 1200
                  ? 4
                  : screenWidth > 768
                      ? 3
                      : screenWidth > 400
                          ? 2
                          : 1;
              final aspectRatio = screenWidth > 768
                  ? 0.9
                  : screenWidth > 400
                      ? 1.0
                      : 1.2;
              return Container(
                constraints: BoxConstraints(maxWidth: 1200),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: aspectRatio,
                  children: [
                    HomeFeatureCard(
                      icon: Icons.search,
                      title: AppStrings.featureSearchTitle,
                      description: AppStrings.featureSearchDescription,
                    ),
                    HomeFeatureCard(
                      icon: Icons.star,
                      title: AppStrings.featureReviewsTitle,
                      description: AppStrings.featureReviewsDescription,
                    ),
                    HomeFeatureCard(
                      icon: Icons.map,
                      title: AppStrings.featureLocationsTitle,
                      description: AppStrings.featureLocationsDescription,
                    ),
                    HomeFeatureCard(
                      icon: Icons.local_offer,
                      title: AppStrings.featureOffersTitle,
                      description: AppStrings.featureOffersDescription,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

 Widget _buildCompaniesSection(BuildContext context) {
  return Consumer<HomeController>(
    builder: (context, controller, child) {
      return Container(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        color: AppColors.background,
        child: Column(
          children: [
            SectionTitle(
              title: AppStrings.companiesTitle,
              description: AppStrings.companiesDescription,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.error.isNotEmpty
                    ? Center(
                        child: Text(controller.error,
                            style: AppTextStyles.body(context)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;
                          final crossAxisCount = screenWidth > 1200
                              ? 4
                              : screenWidth > 768
                                  ? 3
                                  : screenWidth > 400
                                      ? 2
                                      : 1;
                          final aspectRatio = screenWidth > 768 ? 0.60 : 0.7;
                          return Container(
                            constraints: BoxConstraints(maxWidth: 1200),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppDimensions.paddingMedium,
                              mainAxisSpacing: AppDimensions.paddingMedium,
                              childAspectRatio: aspectRatio,
                              children: controller.companies
                                  .map((company) => HomeCompanyCard(
                                        company: company,
                                        onPressed: () {
                                          // Navegar al detalle de la empresa
                                          // Navigator.push(...);
                                        },
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      ),
            SizedBox(height: AppDimensions.paddingMedium),
            AppButton(
              text: AppStrings.viewMoreCompaniesButton,
              onPressed: () {},
            ),
          ],
        ),
      );
    },
  );
}
  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      color: Colors.white,
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.howItWorksTitle,
            description: AppStrings.howItWorksDescription,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final crossAxisCount = screenWidth > 1200
                  ? 3
                  : screenWidth > 768
                      ? 3
                      : screenWidth > 400
                          ? 2
                          : 1;
              final aspectRatio = screenWidth > 768
                  ? 1.0
                  : screenWidth > 400
                      ? 1.1
                      : 1.3;
              return Container(
                constraints: BoxConstraints(maxWidth: 1200),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: aspectRatio,
                  children: [
                    HomeStepCard(
                      number: 1,
                      title: AppStrings.stepSearchTitle,
                      description: AppStrings.stepSearchDescription,
                    ),
                    HomeStepCard(
                      number: 2,
                      title: AppStrings.stepCompareTitle,
                      description: AppStrings.stepCompareDescription,
                    ),
                    HomeStepCard(
                      number: 3,
                      title: AppStrings.stepBookTitle,
                      description: AppStrings.stepBookDescription,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      color: AppColors.secondary,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 768
                  ? 3
                  : (constraints.maxWidth > 400 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppDimensions.paddingMedium,
                mainAxisSpacing: AppDimensions.paddingMedium,
                childAspectRatio: 1.2,
                children: [
                  FooterColumn(
                    title: AppStrings.footerTitle,
                    items: [
                      {'label': AppStrings.footerDescription},
                      {'label': '', 'icon': null, 'onPressed': null},
                      {'label': '', 'icon': null, 'onPressed': null},
                      {'label': '', 'icon': null, 'onPressed': null},
                      {'label': '', 'icon': null, 'onPressed': null},
                    ],
                  ),
                  FooterColumn(
                    title: AppStrings.navCompanies,
                    items: [
                      {
                        'label': AppStrings.footerCompanyRegister,
                        'onPressed': () {}
                      },
                      {
                        'label': AppStrings.footerCompanyPlans,
                        'onPressed': () {}
                      },
                      {
                        'label': AppStrings.footerHelpCenter,
                        'onPressed': () {}
                      },
                    ],
                  ),
                  FooterColumn(
                    title: AppStrings.navContact,
                    items: [
                      {
                        'label': AppStrings.footerAddress,
                        'icon': Icons.location_on
                      },
                      {'label': AppStrings.footerPhone, 'icon': Icons.phone},
                      {'label': AppStrings.footerEmail, 'icon': Icons.email},
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            alignment: WrapAlignment.center,
            children: [
              SocialLink(icon: Icons.facebook, onPressed: () {}),
              SocialLink(icon: Icons.camera_alt, onPressed: () {}),
            ],
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          // ignore: deprecated_member_use
          Divider(color: Colors.white.withOpacity(0.1)),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            AppStrings.copyright,
            style: AppTextStyles.body(context).copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}




