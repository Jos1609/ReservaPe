// lib/features/companies/components/company_info_section.dart

import 'package:flutter/material.dart';
import 'package:sintetico/config/ui/estado_carga.dart';
import 'package:sintetico/config/ui/info_tarjeta.dart';
import 'package:sintetico/models/empresa.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';
import '../../../config/theme/text_styles.dart';

class CompanyInfoSection extends StatelessWidget {
  final CompanyModel company;

  const CompanyInfoSection({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado y horario
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                status: company.status,
                isOpen: company.status.toLowerCase() == 'abierto',
              ),
              Text(
                '${company.openingTime} - ${company.closingTime}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.paddingMedium),

          // Descripción
          if (company.description.isNotEmpty) ...[
            Text(
              'Descripción',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            Text(
              company.description,
              style: AppTextStyles.body1,
            ),
            SizedBox(height: AppDimensions.paddingLarge),
          ],
          

          // Servicios
          if (company.services.isNotEmpty) ...[
            Text(
              'Servicios',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildServicesGrid(),
            SizedBox(height: AppDimensions.paddingLarge),
          ],

          // Ubicación
          _buildLocationSection(),
        ],
      ),
    );
  }


  Widget _buildServicesGrid() {
    return Wrap(
      spacing: AppDimensions.paddingSmall,
      runSpacing: AppDimensions.paddingSmall,
      children: company.services.map((service) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
            border: Border.all(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getServiceIcon(service),
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: AppDimensions.paddingXSmall),
              Text(
                service,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: AppTextStyles.h3,
        ),
        SizedBox(height: AppDimensions.paddingMedium),
        InfoCard(
          icon: Icons.location_on,
          title: 'Dirección',
          content: company.address,
          
        ),
        SizedBox(height: AppDimensions.paddingMedium),
        
        // Mini mapa (placeholder)
        
      ],
    );
  }

  IconData _getServiceIcon(String service) {
    final serviceLower = service.toLowerCase();
    
    if (serviceLower.contains('estacionamiento') || serviceLower.contains('parking')) {
      return Icons.local_parking;
    } else if (serviceLower.contains('vestidor') || serviceLower.contains('vestuario')) {
      return Icons.checkroom;
    } else if (serviceLower.contains('cafetería') || serviceLower.contains('cafeteria')) {
      return Icons.local_cafe;
    } else if (serviceLower.contains('ducha') || serviceLower.contains('baño')) {
      return Icons.shower;
    } else if (serviceLower.contains('wifi')) {
      return Icons.wifi;
    } else if (serviceLower.contains('seguridad')) {
      return Icons.security;
    } else if (serviceLower.contains('iluminación') || serviceLower.contains('iluminacion')) {
      return Icons.light_mode;
    }
    
    return Icons.check_circle;
  }
}