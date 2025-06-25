import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/config/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:sintetico/features/admin_empresas/controllers/companies_controller.dart';
import 'package:sintetico/models/empresa.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CompaniesController>(context);
    final averageRating = controller.getAverageRating(company.id);

    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusSmall),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    company.logo ??
                        'https://as2.ftcdn.net/jpg/04/91/17/51/1000_F_491175182_AfXS8yKlF6QgO4phw1dsn2Htm9sp7BS4.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusSmall),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.1),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    company.name,
                    style: AppTextStyles.heading3(context).copyWith(color: AppColors.dark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.gray, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          company.address,
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.gray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.light),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(context, company.services.length.toString(), 'Servicios'),
                        _buildRatingStat(context, averageRating),
                        _buildStat(context, company.status, 'Estado'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.body(context).copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 10,
            color: AppColors.gray,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRatingStat(BuildContext context, double averageRating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          averageRating > 0 ? averageRating.toStringAsFixed(1) : 'Sin',
          style: AppTextStyles.body(context).copyWith(
            fontWeight: FontWeight.w700,
            color: averageRating > 0 ? AppColors.primaryDark : AppColors.gray,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          averageRating > 0 ? 'Calificaciones' : 'Calificaciones',
          style: AppTextStyles.body(context).copyWith(
            fontSize: 10,
            color: AppColors.gray,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}