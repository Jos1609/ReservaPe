import 'package:flutter/material.dart';
import 'package:sintetico/config/theme/colors.dart';
import 'package:sintetico/config/theme/dimensions.dart';
import 'package:sintetico/models/empresa.dart';
import 'package:sintetico/views/cliente/detalles_empresa.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        return GestureDetector(
          onTap: () {
           Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CompanyDetailView(company: company),
    ),
  );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y estado
                _buildImageSection(isSmallScreen),
                
                // Información
                _buildInfoSection(isSmallScreen),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isSmallScreen) {
    return Stack(
      children: [
        Container(
          height: isSmallScreen ? 150 : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadius)
            ),
            image: DecorationImage(
              image: NetworkImage(company.logo ?? 'https://virtual.munisurquillo.gob.pe/assets/images/reserva/futbol1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(company.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              company.status,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre y rating
          _buildNameAndRating(isSmallScreen),
          
          SizedBox(height: 8),
          
          // Descripción
          _buildDescription(isSmallScreen),
          
          SizedBox(height: 12),
          
          // Detalles
          _buildDetails(isSmallScreen),
          
          SizedBox(height: 12),
          
          // Servicios
          _buildServices(isSmallScreen),
          
          SizedBox(height: 16),
          
        ],
      ),
    );
  }

  Widget _buildNameAndRating(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            company.name,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.star.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: AppColors.star, size: 14),
              SizedBox(width: 2),
              Text(
                '4.8',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(bool isSmallScreen) {
    return Text(
      company.description,
      style: TextStyle(
        color: AppColors.gray,
        fontSize: isSmallScreen ? 12 : 14,
        height: 1.3,
      ),
      maxLines: isSmallScreen ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetails(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailItem(Icons.location_on, company.address, isSmallScreen),
        SizedBox(height: 6),
        _buildDetailItem(Icons.access_time, '${company.openingTime} - ${company.closingTime}', isSmallScreen),
        SizedBox(height: 6),
        _buildDetailItem(Icons.attach_money, 'S/ 50 - S/ 130 por hora', isSmallScreen),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: isSmallScreen ? 16 : 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildServices(bool isSmallScreen) {
    if (company.services.isEmpty) return SizedBox.shrink();
    
    final maxServices = isSmallScreen ? 2 : 3;
    final visibleServices = company.services.take(maxServices).toList();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: visibleServices.map((service) {
            final displayText = service.length > 12 ? '${service.substring(0, 12)}...' : service;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        if (company.services.length > maxServices)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '+${company.services.length - maxServices} más',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'Abierto':
        return AppColors.primary;
      case 'Cerrado':
        return AppColors.error;
      case 'En mantenimiento':
        return AppColors.star;
      default:
        return AppColors.gray;
    }
  }
}