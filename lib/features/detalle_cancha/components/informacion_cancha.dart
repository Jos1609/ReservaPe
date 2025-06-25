import 'package:flutter/material.dart';
import 'package:sintetico/models/cancha.dart';
import 'package:sintetico/models/empresa.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/dimensions.dart';
import '../../../../config/theme/text_styles.dart';

class CourtInfoSection extends StatelessWidget {
  final CourtModel court;
  final CompanyModel? company; // Cambiado a CompanyModel

  const CourtInfoSection({
    super.key,
    required this.court,
    this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre de la cancha
          Text(
            court.name,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Información de la empresa
          if (company != null) ...[
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.paddingXSmall),
                Expanded(
                  child: Text(
                    company!.name,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            
            // Horario de atención
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.paddingXSmall),
                Text(
                  'Horario: ${company!.openingTime} - ${company!.closingTime}',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],

          // Características principales
          Row(
            children: [
              _buildFeatureChip(
                icon: _getSportIcon(court.sportType),
                label: court.sportType,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              _buildFeatureChip(
                icon: Icons.group,
                label: '${court.teamCapacity}v${court.teamCapacity}',
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              if (court.hasRoof)
                _buildFeatureChip(
                  icon: Icons.roofing,
                  label: 'Techada',
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Detalles adicionales
          _buildDetailRow(
            icon: Icons.grass,
            label: 'Material',
            value: court.material,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Precios
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo(
                  icon: Icons.wb_sunny,
                  label: 'Precio Día',
                  price: court.dayPrice,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                _buildPriceInfo(
                  icon: Icons.nightlight_round,
                  label: 'Precio Noche',
                  price: court.nightPrice,
                ),
              ],
            ),
          ),

          // Dirección
          if (company != null && company!.address.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    company!.address,
                    style: AppTextStyles.body2,
                  ),
                ),
              ],
            ),
          ],

          // Teléfono y email
          if (company != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            if (company!.phoneNumber != null)
              _buildContactRow(
                icon: Icons.phone,
                value: company!.phoneNumber!,
              ),
            if (company!.email != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              _buildContactRow(
                icon: Icons.email,
                value: company!.email!,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          value,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.paddingXSmall),
          Text(
            label,
            style: AppTextStyles.caption1.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          '$label:',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingXSmall),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo({
    required IconData icon,
    required String label,
    required double price,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.paddingXSmall),
            Text(
              label,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXSmall),
        Text(
          'S/ ${price.toStringAsFixed(2)}',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  IconData _getSportIcon(String sportType) {
    final sport = sportType.toLowerCase();
    
    if (sport.contains('fútbol') || sport.contains('futbol') || sport.contains('soccer')) {
      return Icons.sports_soccer;
    } else if (sport.contains('básquet') || sport.contains('basket')) {
      return Icons.sports_basketball;
    } else if (sport.contains('vóley') || sport.contains('voley') || sport.contains('volley')) {
      return Icons.sports_volleyball;
    } else if (sport.contains('tenis') || sport.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (sport.contains('padel') || sport.contains('paddle')) {
      return Icons.sports_tennis;
    }
    
    return Icons.sports;
  }
}