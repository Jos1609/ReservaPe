import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:sintetico/features/admin_empresas/components/company_card.dart';
import 'package:sintetico/features/admin_empresas/controllers/companies_controller.dart';
import 'package:sintetico/features/auth/services/auth_service.dart';
import 'package:sintetico/views/superAdm/registrar_empresas.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verifyUserAccess(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }       

        // Si el usuario tiene acceso, mostramos el contenido
        return ChangeNotifierProvider(
          create: (_) => CompaniesController()..loadCompanies(),
          child: const _CompaniesScreenContent(),
        );
      },
    );
  }

  Future<bool> _verifyUserAccess(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);    
      // 2. Verificar si pertenece a la colección SuperAdmin
      final userCollection = await authService.getUserCollection();
      return userCollection == 'SuperAdmin';
    } catch (e) {
      return false;
    }
  }
}

class _CompaniesScreenContent extends StatelessWidget {
  const _CompaniesScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CompaniesController>(context);

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empresas',
                      style: AppTextStyles.heading2(context),
                    ),
                    Text(
                      'Gestiona las empresas ',
                      style: AppTextStyles.body(context)
                          .copyWith(color: AppColors.gray),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    RegisterCompanyModal.show(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.white),
                  label:
                      Text('Agregar Empresa', style: AppTextStyles.buttonText),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Expanded(
              child: controller.companies.isEmpty
                  ? _buildEmptyState(context)
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: AppDimensions.paddingMedium,
                        mainAxisSpacing: AppDimensions.paddingMedium,
                      ),
                      itemCount: controller.companies.length,
                      itemBuilder: (context, index) {
                        return CompanyCard(
                            company: controller.companies[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.business,
            size: 50,
            color: AppColors.gray,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No hay empresas registradas',
            style:
                AppTextStyles.heading3(context).copyWith(color: AppColors.dark),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Comienza agregando tu primera empresa',
            style: AppTextStyles.body(context).copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ElevatedButton.icon(
            onPressed: () {
              RegisterCompanyModal.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text('Agregar Empresa', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}