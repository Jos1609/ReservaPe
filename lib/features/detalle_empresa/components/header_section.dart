// lib/features/companies/components/company_header_section.dart

import 'package:flutter/material.dart';
import 'package:sintetico/models/empresa.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/dimensions.dart';

class CompanyHeaderSection extends StatelessWidget {
  final CompanyModel company;

  const CompanyHeaderSection({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // ignore: deprecated_member_use
            AppColors.primary.withOpacity(0.7),
            AppColors.primary,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          if (company.logo != null && company.logo!.isNotEmpty)
            Opacity(
              opacity: 0.3,
              child: Image.network(
                company.logo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary,
                    child: Icon(
                      Icons.business,
                      size: 80,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.3),
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Icon(
                Icons.business,
                size: 80,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.3),
              ),
            ),

          // Degradado oscuro para mejorar la legibilidad
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Logo en el centro (si existe)
          if (company.logo != null && company.logo!.isNotEmpty)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  child: Image.network(
                    company.logo!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business,
                        size: 50,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}